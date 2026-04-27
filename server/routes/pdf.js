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

// llama-3.1-8b-instant: 131,072 TPM free tier — handles large PDFs without
// hitting rate limits. llama-3.3-70b-versatile only has 6,000 TPM free tier
// which is exceeded by any PDF larger than ~1 MB.
const PDF_MODEL = "llama-3.1-8b-instant";

const MAX_TEXT_CHARS = 24000; // ~6,000 tokens of PDF text — fits comfortably
const MAX_CHAPTERS = 8;
const MIN_CHAPTERS = 2;
const CARDS_PER_CHAPTER_MIN = 5;
const CARDS_PER_CHAPTER_MAX = 10;

router.post("/process", upload.single("pdf"), async (req, res) => {
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

    let chapters;
    try {
      chapters = await generateChapters(topicName, text);
    } catch (aiErr) {
      const details = aiErr.message || "Unknown AI error";
      const statusCode = aiErr.status || aiErr.statusCode || "";
      console.error(`[PDF] Groq failed (${statusCode}):`, details);
      await markFailed(uploadRef, `AI generation failed: ${details}`);
      return res.status(500).json({
        success: false,
        message: "AI could not process this PDF. Please try again later.",
        details,
      });
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
      max_tokens: 6000,
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
