const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const { getFirestore } = require('../utils/firebase');

const router = express.Router();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// ─── POST /api/flashcards/generate ────────────────────────────────────────────
router.post('/generate', async (req, res) => {
  const { topicId, topicName, domainId, subjectId, examTags = [], difficulty = 'mixed' } = req.body;

  if (!topicId || !topicName || !domainId || !subjectId) {
    return res.status(400).json({
      success: false,
      message: 'topicId, topicName, domainId and subjectId are required.',
    });
  }

  const db = getFirestore();
  const cardsRef = db
    .collection('domains')
    .doc(domainId)
    .collection('subjects')
    .doc(subjectId)
    .collection('topics')
    .doc(topicId)
    .collection('flashcards');

  // ── Check if cards already exist ───────────────────────────────────────────
  // Use limit(1) instead of count() for broader Firebase Admin SDK compatibility
  const existing = await cardsRef.limit(1).get();
  if (!existing.empty) {
    // Fetch actual count for the response
    const allExisting = await cardsRef.select().get();
    return res.json({
      success: true,
      cardCount: allExisting.size,
      generated: false,
      message: 'Cards already exist for this topic.',
    });
  }

  // ── Build Gemini prompt ────────────────────────────────────────────────────
  const examContext = examTags.length > 0
    ? `This topic is relevant for: ${examTags.join(', ')}.`
    : '';

  const prompt = `
You are an expert educator creating high-quality study flashcards for the topic: "${topicName}".
${examContext}

Generate exactly 30 flashcards as a JSON array. Use a mix of these types:
- "flashcard": classic term/definition or question/answer (15 cards)
- "mcq": multiple choice with 4 options (10 cards)
- "fill_blank": sentence with a blank to fill (3 cards)
- "true_false": true or false statement (2 cards)

Difficulty distribution: ${difficulty === 'mixed' ? '10 easy, 12 medium, 8 hard' : `all ${difficulty}`}.

Return ONLY a valid JSON array with no markdown, no explanation, no code fences. Each object must have:
{
  "type": "flashcard" | "mcq" | "fill_blank" | "true_false",
  "front": "question or term or statement with ___",
  "back": "answer or definition",
  "options": ["A", "B", "C", "D"],   // only for mcq
  "correctOption": 0,                 // 0-indexed, only for mcq
  "explanation": "brief explanation", // optional, include for hard cards
  "difficulty": "easy" | "medium" | "hard",
  "tags": ["subtopic1", "subtopic2"]  // 1-2 relevant subtopics
}

Rules:
- front must be a clear, standalone question — no ambiguity
- back must be concise and accurate
- MCQ distractors must be plausible but clearly wrong
- Tags must be specific subtopics within "${topicName}"
- No duplicate questions
- Content must be factually accurate
`.trim();

  // ── Call Gemini ────────────────────────────────────────────────────────────
  let cards;
  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    const result = await model.generateContent(prompt);
    const text = result.response.text().trim();

    // Strip markdown code fences if Gemini adds them despite instructions
    const cleaned = text.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '');
    cards = JSON.parse(cleaned);

    if (!Array.isArray(cards)) throw new Error('Response is not an array');
  } catch (err) {
    console.error('[GEMINI]', err.message);
    return res.status(500).json({
      success: false,
      message: 'AI generation failed. Please try again.',
    });
  }

  // ── Validate and write to Firestore ───────────────────────────────────────
  const validTypes = ['flashcard', 'mcq', 'fill_blank', 'true_false'];
  const validDifficulties = ['easy', 'medium', 'hard'];
  const now = new Date().toISOString();

  const batch = db.batch();
  let written = 0;

  cards.forEach((card, index) => {
    if (!card.front || !card.back) return; // skip malformed cards
    if (!validTypes.includes(card.type)) card.type = 'flashcard';
    if (!validDifficulties.includes(card.difficulty)) card.difficulty = 'medium';

    const ref = cardsRef.doc();
    const data = {
      id: ref.id,
      topicId,
      type: card.type,
      front: String(card.front).trim(),
      back: String(card.back).trim(),
      options: card.type === 'mcq' && Array.isArray(card.options) ? card.options : [],
      correctOption: card.type === 'mcq' ? (card.correctOption ?? 0) : null,
      explanation: card.explanation ? String(card.explanation).trim() : null,
      difficulty: card.difficulty,
      tags: Array.isArray(card.tags) ? card.tags.slice(0, 3) : [],
      createdAt: now,
      generatedByAI: true,
      order: index,
    };
    batch.set(ref, data);
    written++;
  });

  await batch.commit();

  // ── Update totalCards on topic document ────────────────────────────────────
  const topicRef = db
    .collection('domains')
    .doc(domainId)
    .collection('subjects')
    .doc(subjectId)
    .collection('topics')
    .doc(topicId);

  await topicRef.update({ totalCards: written });

  console.log(`[FLASHCARDS] Generated ${written} cards for topic "${topicName}"`);

  res.json({ success: true, cardCount: written, generated: true });
});

module.exports = router;
