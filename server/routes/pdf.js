const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pdfParse = require('pdf-parse');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { getFirestore } = require('../utils/firebase');

const router = express.Router();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Store uploads in /tmp — cleaned up after processing
const upload = multer({
  dest: '/tmp/orbit-uploads/',
  limits: { fileSize: 20 * 1024 * 1024 }, // 20MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'application/pdf') {
      cb(null, true);
    } else {
      cb(new Error('Only PDF files are accepted.'));
    }
  },
});

// ─── POST /api/pdf/process ────────────────────────────────────────────────────
router.post('/process', upload.single('pdf'), async (req, res) => {
  const { uploadId, topicName, domainId } = req.body;
  const userId = req.user.uid;

  if (!uploadId || !topicName || !domainId) {
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
  const filePath = req.file.path;

  try {
    // ── Update status: processing ─────────────────────────────────────────
    await uploadRef.update({ status: 'processing' });

    // ── Extract text from PDF ─────────────────────────────────────────────
    const buffer = fs.readFileSync(filePath);
    const parsed = await pdfParse(buffer);
    const pageCount = parsed.numpages;
    const rawText = parsed.text.trim();

    if (!rawText || rawText.length < 100) {
      await uploadRef.update({ status: 'failed', error: 'Could not extract text from this PDF.' });
      return res.status(422).json({
        success: false,
        message: 'Could not extract readable text from the PDF.',
      });
    }

    // Truncate to ~12,000 chars to stay within Gemini context
    const text = rawText.slice(0, 12000);

    // ── Build Gemini prompt ───────────────────────────────────────────────
    const prompt = `
You are an expert educator. A student uploaded a PDF about "${topicName}".

Based on the following text extracted from the PDF, generate 25 high-quality study flashcards.

Use a mix of types:
- "flashcard": term/definition or question/answer (12 cards)
- "mcq": multiple choice with 4 options (8 cards)
- "fill_blank": sentence with a ___ blank (3 cards)
- "true_false": true or false (2 cards)

Return ONLY a JSON array with no markdown or explanation. Each card:
{
  "type": "flashcard" | "mcq" | "fill_blank" | "true_false",
  "front": "question or term",
  "back": "answer or definition",
  "options": ["A","B","C","D"],  // mcq only
  "correctOption": 0,            // 0-indexed, mcq only
  "explanation": "optional",
  "difficulty": "easy" | "medium" | "hard",
  "tags": ["tag1"]
}

PDF TEXT:
${text}
`.trim();

    // ── Call Gemini ───────────────────────────────────────────────────────
    let cards;
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    const result = await model.generateContent(prompt);
    const responseText = result.response.text().trim();
    const cleaned = responseText.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '');
    cards = JSON.parse(cleaned);

    if (!Array.isArray(cards)) throw new Error('Response is not an array');

    // ── Write cards to Firestore ──────────────────────────────────────────
    const cardsRef = uploadRef.collection('flashcards');
    const batch = db.batch();
    const now = new Date().toISOString();
    let written = 0;

    cards.forEach((card, index) => {
      if (!card.front || !card.back) return;
      const ref = cardsRef.doc();
      batch.set(ref, {
        id: ref.id,
        topicId: uploadId,
        type: card.type || 'flashcard',
        front: String(card.front).trim(),
        back: String(card.back).trim(),
        options: card.type === 'mcq' && Array.isArray(card.options) ? card.options : [],
        correctOption: card.type === 'mcq' ? (card.correctOption ?? 0) : null,
        explanation: card.explanation || null,
        difficulty: card.difficulty || 'medium',
        tags: Array.isArray(card.tags) ? card.tags.slice(0, 3) : [],
        createdAt: now,
        generatedByAI: true,
        order: index,
      });
      written++;
    });

    await batch.commit();

    // ── Mark upload as completed ──────────────────────────────────────────
    await uploadRef.update({
      status: 'completed',
      pageCount,
      generatedCardCount: written,
      completedAt: new Date().toISOString(),
    });

    res.json({ success: true, cardCount: written, pageCount });
  } catch (err) {
    console.error('[PDF]', err.message);
    await uploadRef.update({
      status: 'failed',
      error: err.message || 'Processing failed',
    }).catch(() => {});
    res.status(500).json({ success: false, message: 'PDF processing failed. Please try again.' });
  } finally {
    // Always clean up the temp file
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
  }
});

module.exports = router;
