const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pdfParse = require('pdf-parse');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { getFirestore } = require('../utils/firebase');

const router = express.Router();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// ─── Temp upload directory ─────────────────────────────────────────────────────
const UPLOAD_DIR = '/tmp/orbit-uploads';
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

// ─── Multer config ─────────────────────────────────────────────────────────────
const upload = multer({
  dest: UPLOAD_DIR,
  limits: { fileSize: 20 * 1024 * 1024 }, // 20 MB
  fileFilter: (_req, file, cb) => {
    if (file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only PDF files are accepted.'));
    }
  },
});

// ─── Constants ─────────────────────────────────────────────────────────────────
const MAX_TEXT_CHARS = 40000;   // ~10,000 tokens — safe for Gemini 1.5 Flash
const MAX_CHAPTERS   = 8;
const MIN_CHAPTERS   = 2;
const CARDS_PER_CHAPTER_MIN = 5;
const CARDS_PER_CHAPTER_MAX = 12;

// ─── POST /api/pdf/process ────────────────────────────────────────────────────
router.post('/process', upload.single('pdf'), async (req, res) => {
  const { uploadId, topicName, domainId } = req.body;
  const filePath = req.file?.path;

  // ── Validation ────────────────────────────────────────────────────────────
  if (!uploadId || !topicName || !domainId) {
    cleanupFile(filePath);
    return res.status(400).json({
      success: false,
      message: 'uploadId, topicName and domainId are required.',
    });
  }
  if (!req.file) {
    return res.status(400).json({ success: false, message: 'PDF file is required.' });
  }

  const db = getFirestore();
  const uploadRef = db.collection('uploads').doc(uploadId);

  try {
    // ── 1. Mark as processing ─────────────────────────────────────────────
    await uploadRef.update({ status: 'processing' });

    // ── 2. Extract text from PDF ──────────────────────────────────────────
    const buffer = fs.readFileSync(filePath);
    const parsed = await pdfParse(buffer);
    const pageCount = parsed.numpages;
    const rawText = parsed.text?.trim() || '';

    if (rawText.length < 100) {
      await markFailed(uploadRef, 'Could not extract readable text from this PDF. Make sure it is not a scanned image-only PDF.');
      return res.status(422).json({
        success: false,
        message: 'Could not extract readable text from the PDF.',
      });
    }

    // Truncate but keep as much text as possible
    const text = rawText.slice(0, MAX_TEXT_CHARS);

    // ── 3. Generate chapter-wise flashcards with Gemini ───────────────────
    let chapters;
    try {
      chapters = await generateChapters(topicName, text);
    } catch (geminiErr) {
      console.error('[PDF] Gemini failed:', geminiErr.message);
      await markFailed(uploadRef, 'AI failed to process this PDF. Please try again.');
      return res.status(500).json({ success: false, message: 'AI generation failed. Please try again.' });
    }

    if (!chapters || chapters.length === 0) {
      await markFailed(uploadRef, 'AI could not identify any study content in this PDF.');
      return res.status(422).json({ success: false, message: 'No study content found in PDF.' });
    }

    // ── 4. Write chapters + cards to Firestore ────────────────────────────
    const { totalCards } = await writeChaptersToFirestore(db, uploadRef, uploadId, chapters);

    // ── 5. Mark completed ─────────────────────────────────────────────────
    await uploadRef.update({
      status: 'completed',
      pageCount,
      generatedCardCount: totalCards,
      completedAt: new Date().toISOString(),
    });

    console.log(`[PDF] ${uploadId}: ${chapters.length} chapters, ${totalCards} cards`);
    res.json({ success: true, cardCount: totalCards, pageCount, chapterCount: chapters.length });

  } catch (err) {
    console.error('[PDF] Unexpected error:', err.message);
    await markFailed(uploadRef, err.message || 'Processing failed').catch(() => {});
    res.status(500).json({ success: false, message: 'PDF processing failed. Please try again.' });
  } finally {
    cleanupFile(filePath);
  }
});

// ─── Gemini: detect chapters and generate flashcards ──────────────────────────
async function generateChapters(topicName, text) {
  const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

  const prompt = `
You are an expert educator. A student uploaded a PDF titled "${topicName}".

Analyze the text below and:
1. Identify ${MIN_CHAPTERS}–${MAX_CHAPTERS} logical chapters or sections based on the content structure.
2. For each chapter generate ${CARDS_PER_CHAPTER_MIN}–${CARDS_PER_CHAPTER_MAX} high-quality flashcards.

Return ONLY a valid JSON object — no markdown, no code fences, no explanation:
{
  "chapters": [
    {
      "title": "Chapter or section title",
      "order": 0,
      "cards": [
        {
          "type": "flashcard",
          "front": "Question or term",
          "back": "Answer or definition",
          "options": [],
          "correctOption": null,
          "explanation": "Optional explanation shown after answer",
          "difficulty": "easy"
        }
      ]
    }
  ]
}

Card type rules:
- "flashcard" — classic Q&A or term/definition (use for 50% of cards)
- "mcq" — multiple choice; options = 4 strings, correctOption = 0-indexed int (30% of cards)
- "fill_blank" — sentence with ___ to fill in (10% of cards)
- "true_false" — back must be "True" or "False" (10% of cards)

Difficulty rules:
- easy: recall of basic facts
- medium: application or comparison
- hard: analysis or multi-step reasoning

Quality rules:
- Each question must be clear and standalone
- MCQ distractors must be plausible but clearly wrong
- No duplicate questions across chapters
- Content must match the chapter title

PDF TEXT:
${text}
`.trim();

  let responseText;
  try {
    const result = await model.generateContent(prompt);
    responseText = result.response.text().trim();
  } catch (err) {
    throw new Error(`Gemini API error: ${err.message}`);
  }

  // Strip markdown fences if Gemini adds them despite instructions
  const cleaned = responseText
    .replace(/^```(?:json)?\s*/i, '')
    .replace(/\s*```\s*$/, '')
    .trim();

  let parsed;
  try {
    parsed = JSON.parse(cleaned);
  } catch (_) {
    // Try to extract JSON object from the response (sometimes Gemini adds preamble)
    const match = cleaned.match(/\{[\s\S]*\}/);
    if (!match) throw new Error('Gemini returned non-JSON response');
    parsed = JSON.parse(match[0]);
  }

  if (!parsed.chapters || !Array.isArray(parsed.chapters)) {
    throw new Error('Gemini response missing chapters array');
  }

  // Sanitize and validate
  return parsed.chapters
    .filter(ch => ch.title && Array.isArray(ch.cards) && ch.cards.length > 0)
    .slice(0, MAX_CHAPTERS)
    .map((ch, i) => ({
      title: String(ch.title).trim(),
      order: i,
      cards: sanitizeCards(ch.cards, `${i}`),
    }));
}

// ─── Sanitize individual card objects ─────────────────────────────────────────
function sanitizeCards(rawCards, chapterId) {
  const validTypes = ['flashcard', 'mcq', 'fill_blank', 'true_false'];
  const validDiffs  = ['easy', 'medium', 'hard'];

  return rawCards
    .filter(c => c.front && c.back)
    .slice(0, CARDS_PER_CHAPTER_MAX)
    .map((c, index) => ({
      type: validTypes.includes(c.type) ? c.type : 'flashcard',
      front: String(c.front).trim(),
      back: String(c.back).trim(),
      options: c.type === 'mcq' && Array.isArray(c.options)
        ? c.options.map(String).slice(0, 4)
        : [],
      correctOption: c.type === 'mcq' && typeof c.correctOption === 'number'
        ? c.correctOption
        : null,
      explanation: c.explanation ? String(c.explanation).trim() : null,
      difficulty: validDiffs.includes(c.difficulty) ? c.difficulty : 'medium',
      tags: [],
      order: index,
      generatedByAI: true,
      topicId: chapterId,
    }));
}

// ─── Write chapters + cards to Firestore ──────────────────────────────────────
// Firestore batch limit = 500 ops. With max 8 chapters × 12 cards = 96 + 8 = 104 — safe.
// But we split into batches of 200 for safety on very large sets.
async function writeChaptersToFirestore(db, uploadRef, uploadId, chapters) {
  const now = new Date().toISOString();
  let totalCards = 0;

  // Operations: 1 chapter doc + N card docs per chapter
  // Keep a rolling batch, commit every 200 ops
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
    // Create chapter document
    const chapterRef = uploadRef.collection('chapters').doc();
    const chapterId = chapterRef.id;

    addToBatch(chapterRef, {
      id: chapterId,
      uploadId,
      title: chapter.title,
      cardCount: chapter.cards.length,
      order: chapter.order,
    });

    // Create card documents under this chapter
    for (const card of chapter.cards) {
      const cardRef = chapterRef.collection('cards').doc();
      addToBatch(cardRef, {
        ...card,
        id: cardRef.id,
        topicId: chapterId,
        createdAt: now,
      });
      totalCards++;
    }

    // Commit if approaching batch limit
    if (opsInBatch >= 200) {
      await commitBatch();
    }
  }

  // Commit remaining ops
  await commitBatch();

  return { totalCards };
}

// ─── Helpers ───────────────────────────────────────────────────────────────────
async function markFailed(uploadRef, error) {
  return uploadRef.update({ status: 'failed', error }).catch(() => {});
}

function cleanupFile(filePath) {
  if (filePath && fs.existsSync(filePath)) {
    try { fs.unlinkSync(filePath); } catch (_) {}
  }
}

module.exports = router;
