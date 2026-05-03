const express = require("express");
const multer = require("multer");
const fs = require("fs");
const pdfParse = require("pdf-parse");
const { getModel } = require("../utils/gemini");
const { getFirestore } = require("../utils/firebase");

const router = express.Router();

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

// Gemini 2.0 Flash free tier: 1,000,000 TPM — no rate-limit issues on any PDF size.
// These limits are set for quality, not rate limits.
const MAX_TEXT_CHARS = 50000; // ~12,500 tokens — covers most 10 MB PDFs well
const MAX_CHAPTERS = 8;
const MIN_CHAPTERS = 2;
const CARDS_PER_CHAPTER_MIN = 5;
const CARDS_PER_CHAPTER_MAX = 8; // 8 chapters × 8 cards = 64 max cards (~6,400 output tokens)

// ─── Gemini connectivity test ─────────────────────────────────────────────────
// GET /api/pdf/test-gemini — verify the key works before uploading a PDF.
router.get("/test-gemini", async (_req, res) => {
  try {
    const model = getModel();
    const result = await model.generateContent(
      'Reply with the single word: ok'
    );
    const reply = result.response.text().trim();
    res.json({
      success: true,
      model: process.env.GEMINI_MODEL || "gemini-2.0-flash",
      reply,
    });
  } catch (err) {
    const status = err.status || err.statusCode || "unknown";
    console.error(`[GEMINI-TEST] failed (${status}):`, err.message);
    res.status(500).json({
      success: false,
      model: process.env.GEMINI_MODEL || "gemini-2.0-flash",
      status,
      message: err.message,
    });
  }
});

// ─── Multer error handler wrapper ─────────────────────────────────────────────
// multer calls next(err) on LIMIT_FILE_SIZE etc., bypassing the route handler.
// We intercept it so the response shape stays consistent.
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

// ─── POST /api/pdf/process ────────────────────────────────────────────────────
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

    // ── 1. Extract text from PDF ─────────────────────────────────────────────
    const buffer = fs.readFileSync(filePath);
    const parsed = await pdfParse(buffer);
    const pageCount = parsed.numpages;
    const rawText = parsed.text?.trim() || "";

    if (rawText.length < 100) {
      await markFailed(
        uploadRef,
        "Could not extract readable text from this PDF. Make sure it is not a scanned image-only PDF."
      );
      return res.status(422).json({
        success: false,
        message:
          "Could not extract readable text from the PDF. Make sure it is not a scanned image-only file.",
      });
    }

    const text = rawText.slice(0, MAX_TEXT_CHARS);

    // ── 2. Generate chapters via Gemini ──────────────────────────────────────
    let chapters;
    try {
      chapters = await generateChapters(topicName, text);
    } catch (aiErr) {
      const status = aiErr.status || aiErr.statusCode || "unknown";
      const details = aiErr.message || "Unknown AI error";
      console.error(`[PDF] Gemini attempt 1 failed (status=${status}):`, details);

      // 429 = rate limit (shouldn't happen on free tier, but handle gracefully)
      const isRetryable =
        String(status) === "429" ||
        details.toLowerCase().includes("rate") ||
        details.toLowerCase().includes("quota");

      if (isRetryable) {
        console.log("[PDF] Rate limit hit — retrying with reduced text after 5s...");
        try {
          await new Promise((r) => setTimeout(r, 5000));
          chapters = await generateChapters(topicName, text.slice(0, MAX_TEXT_CHARS / 2));
        } catch (retryErr) {
          console.error("[PDF] Gemini attempt 2 failed:", retryErr.message);
          await markFailed(uploadRef, "AI is busy. Please try again in a moment.");
          return res.status(500).json({
            success: false,
            message: "AI is busy. Please try again in a moment.",
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
        "AI could not identify any study content in this PDF."
      );
      return res
        .status(422)
        .json({ success: false, message: "No study content found in PDF." });
    }

    // ── 3. Write chapters + cards to Firestore ───────────────────────────────
    const { totalCards } = await writeChaptersToFirestore(
      db,
      uploadRef,
      uploadId,
      chapters
    );

    // ── 4. Mark completed ────────────────────────────────────────────────────
    await uploadRef.update({
      status: "completed",
      pageCount,
      generatedCardCount: totalCards,
      completedAt: new Date().toISOString(),
    });

    console.log(
      `[PDF] ${uploadId}: ${chapters.length} chapters, ${totalCards} cards`
    );
    res.json({
      success: true,
      cardCount: totalCards,
      pageCount,
      chapterCount: chapters.length,
    });
  } catch (err) {
    console.error("[PDF] Unexpected error:", err.message);
    await markFailed(uploadRef, err.message || "Processing failed").catch(() => {});
    res.status(500).json({
      success: false,
      message: "PDF processing failed. Please try again.",
    });
  } finally {
    cleanupFile(filePath);
  }
});

// ─── AI generation ────────────────────────────────────────────────────────────
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

  const model = getModel();
  const result = await model.generateContent(prompt);
  const raw = result.response.text().trim();

  const cleaned = raw
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

// ─── Firestore batch write ────────────────────────────────────────────────────
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

// ─── Helpers ──────────────────────────────────────────────────────────────────
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
