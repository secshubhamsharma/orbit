const express = require("express");
const multer = require("multer");
const fs = require("fs");
const pdfParse = require("pdf-parse");
const Groq = require("groq-sdk");
const { getFirestore } = require("../utils/firebase");

const router = express.Router();
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

const UPLOAD_DIR = "/tmp/orbit-uploads";
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const upload = multer({
  dest: UPLOAD_DIR,
  limits: { fileSize: 20 * 1024 * 1024 }, // 20 MB
  fileFilter: (_req, file, cb) => {
    if (file.mimetype === "application/pdf") {
      cb(null, true);
    } else {
      cb(new Error("Only PDF files are accepted."));
    }
  },
});

// Model is configurable via env so you can override without redeploying code.
// Default: llama-3.1-8b-instant (131,072 TPM free tier — handles large PDFs).
// llama-3.3-70b-versatile has only 6,000 TPM and fails on files > ~1 MB.
const PDF_MODEL = process.env.GROQ_PDF_MODEL || "llama-3.1-8b-instant";

// Token budget breakdown for Groq on_demand tier (6,000 TPM limit):
//   Prompt template overhead : ~400 tokens
//   PDF text (8,000 chars)   : ~2,000 tokens
//   max_tokens output         : 3,200 tokens
//   Total                     : ~5,600 tokens  ← safely under 6,000 TPM
// If the account is upgraded to Dev Tier (131,072 TPM), raise these freely.
const MAX_TEXT_CHARS = 8000;
const MAX_CHAPTERS = 5;
const MIN_CHAPTERS = 2;
const CARDS_PER_CHAPTER_MIN = 3;
const CARDS_PER_CHAPTER_MAX = 6;

// ─── Groq connectivity test (auth-protected) ─────────────────────────────────
// Hit GET /api/pdf/test-groq to verify the key and model without uploading a file.
router.get("/test-groq", async (_req, res) => {
  try {
    const completion = await groq.chat.completions.create({
      model: PDF_MODEL,
      messages: [{ role: "user", content: "Reply with the single word: ok" }],
      temperature: 0,
      max_tokens: 5,
    });
    const reply = completion.choices[0].message.content.trim();
    res.json({ success: true, model: PDF_MODEL, reply });
  } catch (err) {
    const status = err.status || err.statusCode || "unknown";
    console.error(`[GROQ-TEST] failed (${status}):`, err.message);
    res.status(500).json({
      success: false,
      model: PDF_MODEL,
      status,
      message: err.message,
    });
  }
});

// ─── Multer error handler wrapper ─────────────────────────────────────────────
// multer calls next(err) on LIMIT_FILE_SIZE etc., bypassing our route handler.
// We intercept it here so the response shape stays consistent.
function uploadWithErrorHandling(req, res, next) {
  upload.single("pdf")(req, res, (err) => {
    if (!err) return next();
    console.error("[PDF] Multer error:", err.code, err.message);
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(413).json({
        success: false,
        message: "File is too large. Please upload a PDF under 20 MB.",
      });
    }
    return res.status(400).json({
      success: false,
      message: err.message || "File upload failed.",
    });
  });
}

router.post("/process", uploadWithErrorHandling, async (req, res) => {
  const { uploadId, topicName, domainId } = req.body;
  const filePath = req.file?.path;

  if (!uploadId || !topicName || !domainId) {
    cleanupFile(filePath);
    return res.status(400).json({
      success: false,
      message: "uploadId, topicName and domainId are required.",
    });
  }
  if (!req.file) {
    return res
      .status(400)
      .json({ success: false, message: "PDF file is required." });
  }

  const db = getFirestore();
  const uploadRef = db.collection("uploads").doc(uploadId);

  try {
    await uploadRef.update({ status: "processing" });

    const buffer = fs.readFileSync(filePath);
    const parsed = await pdfParse(buffer);
    const pageCount = parsed.numpages;
    const rawText = parsed.text?.trim() || "";

    if (rawText.length < 100) {
      await markFailed(
        uploadRef,
        "Could not extract readable text from this PDF. Make sure it is not a scanned image-only PDF.",
      );
      return res.status(422).json({
        success: false,
        message: "Could not extract readable text from the PDF.",
      });
    }

    const text = rawText.slice(0, MAX_TEXT_CHARS);

    // Attempt generation. If the first try hits a rate/size limit, retry once
    // with half the text — large PDFs sometimes push past burst limits.
    let chapters;
    try {
      chapters = await generateChapters(topicName, text);
    } catch (aiErr) {
      const details = aiErr.message || "Unknown AI error";
      // aiErr is a plain Error we threw — status is embedded in the message
      // e.g. "Groq API error 429: ..." or "Groq API error 400: ..."
      const statusMatch = details.match(/Groq API error (\d+)/);
      const statusCode = statusMatch ? statusMatch[1] : "";
      console.error(`[PDF] Groq attempt 1 failed (status=${statusCode || "unknown"}):`, details);

      // 400 / 403 with "restricted" means the account is banned — not retryable.
      const isAccountBanned =
        (statusCode === "400" || statusCode === "403") &&
        (details.toLowerCase().includes("restricted") ||
          details.toLowerCase().includes("forbidden") ||
          details.toLowerCase().includes("deactivated"));

      if (isAccountBanned) {
        console.error("[PDF] Groq account appears to be restricted. Check your API key / org.");
        await markFailed(uploadRef, "AI service account is restricted. Please contact support.");
        return res.status(500).json({
          success: false,
          message: "AI service account is restricted. Please contact support.",
        });
      }

      // 413 = Groq "Request too large" (on_demand TPM exceeded per-request)
      // 429 = Groq standard rate limit (TPM exceeded per minute window)
      const isRetryable =
        statusCode === "429" ||
        statusCode === "413" ||
        details.toLowerCase().includes("rate") ||
        details.toLowerCase().includes("too large") ||
        details.toLowerCase().includes("context length") ||
        details.toLowerCase().includes("tokens per minute") ||
        details.toLowerCase().includes("reduce your message");

      if (isRetryable) {
        console.log("[PDF] Retrying with reduced text (half length)...");
        try {
          await new Promise((r) => setTimeout(r, 3000)); // 3 s back-off
          chapters = await generateChapters(topicName, text.slice(0, MAX_TEXT_CHARS / 2));
        } catch (retryErr) {
          const retryDetails = retryErr.message || "Unknown AI error";
          console.error("[PDF] Groq attempt 2 failed:", retryDetails);
          await markFailed(uploadRef, "AI is overloaded. Please try again in a few minutes.");
          return res.status(500).json({
            success: false,
            message: "AI is overloaded. Please try again in a few minutes.",
          });
        }
      } else {
        await markFailed(uploadRef, "AI could not process this PDF. Please try again.");
        return res.status(500).json({
          success: false,
          message: "AI could not process this PDF. Please try again.",
        });
      }
    }

    if (!chapters || chapters.length === 0) {
      await markFailed(
        uploadRef,
        "AI could not identify any study content in this PDF.",
      );
      return res
        .status(422)
        .json({ success: false, message: "No study content found in PDF." });
    }

    const { totalCards } = await writeChaptersToFirestore(
      db,
      uploadRef,
      uploadId,
      chapters,
    );

    // ── 5. Mark completed ────────────────────────────────────────────────────
    await uploadRef.update({
      status: "completed",
      pageCount,
      generatedCardCount: totalCards,
      completedAt: new Date().toISOString(),
    });

    console.log(
      `[PDF] ${uploadId}: ${chapters.length} chapters, ${totalCards} MCQ cards`,
    );
    res.json({
      success: true,
      cardCount: totalCards,
      pageCount,
      chapterCount: chapters.length,
    });
  } catch (err) {
    console.error("[PDF] Unexpected error:", err.message);
    await markFailed(uploadRef, err.message || "Processing failed").catch(
      () => {},
    );
    res.status(500).json({
      success: false,
      message: "PDF processing failed. Please try again.",
    });
  } finally {
    cleanupFile(filePath);
  }
});

async function generateChapters(topicName, text) {
  const prompt = `
You are an expert educator. A student uploaded a PDF titled "${topicName}".

Analyze the text and:
1. Identify ${MIN_CHAPTERS}–${MAX_CHAPTERS} logical chapters or sections based on the content.
2. For each chapter generate ${CARDS_PER_CHAPTER_MIN}–${CARDS_PER_CHAPTER_MAX} multiple-choice questions.

Every question MUST have exactly 4 options and one correct answer.

Return ONLY a valid JSON object — no markdown, no code fences, no explanation:
{
  "chapters": [
    {
      "title": "Chapter or section title",
      "order": 0,
      "cards": [
        {
          "front": "The question text",
          "back": "The correct answer text (must match the correct option exactly)",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correctOption": 0,
          "explanation": "Brief explanation of why this answer is correct",
          "difficulty": "easy"
        }
      ]
    }
  ]
}

Rules:
- "correctOption" is 0-indexed (0 = first option, 1 = second, etc.)
- Difficulty: mix of "easy", "medium", and "hard" across each chapter
- Each question must be clear and standalone — no ambiguous wording
- All 4 options must be plausible; wrong options must be clearly incorrect on reflection
- No duplicate questions across chapters
- "back" must be the exact text of the correct option
- Each chapter's questions must be about that chapter's content
- Content must be based on the PDF text provided

PDF TEXT:
${text}
`.trim();

  let responseText;
  try {
    const completion = await groq.chat.completions.create({
      model: PDF_MODEL,
      messages: [{ role: "user", content: prompt }],
      temperature: 0.4,
      max_tokens: 3200,
    });
    responseText = completion.choices[0].message.content.trim();
  } catch (err) {
    // Surface the real Groq error status so the caller can log it properly
    const status = err.status || err.statusCode || "unknown";
    throw new Error(`Groq API error ${status}: ${err.message}`);
  }

  const cleaned = responseText
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```\s*$/, "")
    .trim();

  let parsed;
  try {
    parsed = JSON.parse(cleaned);
  } catch (_) {
    const match = cleaned.match(/\{[\s\S]*\}/);
    if (!match) throw new Error("AI returned non-JSON response");
    parsed = JSON.parse(match[0]);
  }

  if (!parsed.chapters || !Array.isArray(parsed.chapters)) {
    throw new Error("AI response missing chapters array");
  }

  return parsed.chapters
    .filter((ch) => ch.title && Array.isArray(ch.cards) && ch.cards.length > 0)
    .slice(0, MAX_CHAPTERS)
    .map((ch, i) => ({
      title: String(ch.title).trim(),
      order: i,
      cards: sanitizeCards(ch.cards),
    }));
}

function sanitizeCards(rawCards) {
  const validDiffs = ["easy", "medium", "hard"];

  return rawCards
    .filter((c) => c.front && Array.isArray(c.options) && c.options.length >= 2)
    .slice(0, CARDS_PER_CHAPTER_MAX)
    .map((c, index) => {
      const rawCorrect =
        typeof c.correctOption === "number" ? c.correctOption : 0;
      const rawOptions = c.options.map(String).slice(0, 4);
      const correctText = rawOptions[rawCorrect] ?? rawOptions[0];

      const options = rawOptions.sort(() => Math.random() - 0.5);
      const correctOption = Math.max(0, options.indexOf(correctText));
      return {
        type: "mcq",
        front: String(c.front).trim(),
        back: correctText.trim(),
        options,
        correctOption,
        explanation: c.explanation ? String(c.explanation).trim() : null,
        difficulty: validDiffs.includes(c.difficulty) ? c.difficulty : "medium",
        tags: [],
        order: index,
        generatedByAI: true,
      };
    });
}

// ─── Write chapters + cards to Firestore ──────────────────────────────────────
// Rolling batch — commits every 200 ops to stay well under Firestore's 500 limit.
async function writeChaptersToFirestore(db, uploadRef, uploadId, chapters) {
  const now = new Date().toISOString();
  let totalCards = 0;

  let batch = db.batch();
  let opsInBatch = 0;

  const commitBatch = async () => {
    if (opsInBatch > 0) {
      await batch.commit();
      batch = db.batch();
      opsInBatch = 0;
    }
  };

  const addToBatch = (ref, data) => {
    batch.set(ref, data);
    opsInBatch++;
  };

  for (const chapter of chapters) {
    const chapterRef = uploadRef.collection("chapters").doc();
    const chapterId = chapterRef.id;

    addToBatch(chapterRef, {
      id: chapterId,
      uploadId,
      title: chapter.title,
      cardCount: chapter.cards.length,
      order: chapter.order,
    });

    for (const card of chapter.cards) {
      const cardRef = chapterRef.collection("cards").doc();
      addToBatch(cardRef, {
        ...card,
        id: cardRef.id,
        topicId: chapterId,
        createdAt: now,
      });
      totalCards++;
    }

    if (opsInBatch >= 200) await commitBatch();
  }

  await commitBatch();
  return { totalCards };
}

async function markFailed(uploadRef, error) {
  return uploadRef.update({ status: "failed", error }).catch(() => {});
}

function cleanupFile(filePath) {
  if (filePath && fs.existsSync(filePath)) {
    try {
      fs.unlinkSync(filePath);
    } catch (_) {}
  }
}

module.exports = router;
