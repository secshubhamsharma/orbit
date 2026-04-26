const express = require('express');
const Groq = require('groq-sdk');
const { getFirestore } = require('../utils/firebase');

const router = express.Router();
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// ─── POST /api/flashcards/generate ────────────────────────────────────────────
router.post('/generate', async (req, res) => {
  const {
    topicId,
    topicName,
    domainId,
    subjectId,
    examTags = [],
    difficulty = 'mixed',
  } = req.body;

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
  const existing = await cardsRef.limit(1).get();
  if (!existing.empty) {
    const allExisting = await cardsRef.select().get();
    return res.json({
      success: true,
      cardCount: allExisting.size,
      generated: false,
      message: 'Cards already exist for this topic.',
    });
  }

  // ── Build prompt ───────────────────────────────────────────────────────────
  const examContext =
    examTags.length > 0
      ? `This topic is relevant for: ${examTags.join(', ')}.`
      : '';

  const difficultyBreakdown =
    difficulty === 'mixed'
      ? '10 easy, 12 medium, 8 hard'
      : `all ${difficulty}`;

  const prompt = `
You are an expert educator creating MCQ questions for the topic: "${topicName}".
${examContext}

Generate exactly 30 multiple-choice questions as a JSON array.

Every question MUST have exactly 4 options and one correct answer.

Return ONLY a valid JSON array — no markdown, no code fences, no explanation.
Each object must follow this exact shape:
{
  "front": "The question text",
  "back": "The correct answer text (must match the correct option exactly)",
  "options": ["Option A text", "Option B text", "Option C text", "Option D text"],
  "correctOption": 0,
  "explanation": "Brief explanation of why this answer is correct",
  "difficulty": "easy"
}

Rules:
- "correctOption" is 0-indexed (0 = first option, 1 = second, etc.)
- Difficulty distribution: ${difficultyBreakdown}
- Each question must be clear and standalone — no ambiguous wording
- All 4 options must be plausible; wrong options must be clearly incorrect on reflection
- No duplicate questions
- "back" must be the exact text of the correct option
- Content must be factually accurate for "${topicName}"
- Tags must be specific subtopics within "${topicName}"
`.trim();

  // ── Call Groq ──────────────────────────────────────────────────────────────
  let cards;
  try {
    const completion = await groq.chat.completions.create({
      model: 'llama-3.3-70b-versatile',
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.6,
      max_tokens: 8192,
    });

    const text = completion.choices[0].message.content.trim();
    const cleaned = text
      .replace(/^```(?:json)?\s*/i, '')
      .replace(/\s*```\s*$/, '')
      .trim();

    cards = JSON.parse(cleaned);
    if (!Array.isArray(cards)) throw new Error('Response is not an array');
  } catch (err) {
    console.error('[GROQ flashcards]', err.message);
    return res.status(500).json({
      success: false,
      message: 'AI generation failed. Please try again.',
    });
  }

  // ── Validate and write to Firestore ───────────────────────────────────────
  const validDifficulties = ['easy', 'medium', 'hard'];
  const now = new Date().toISOString();

  const batch = db.batch();
  let written = 0;

  cards.forEach((card, index) => {
    if (!card.front || !Array.isArray(card.options) || card.options.length < 2) return;

    // Shuffle options so the correct answer is not always in the same position.
    const rawOptions   = card.options.map(String).slice(0, 4);
    const rawCorrect   = typeof card.correctOption === 'number' ? card.correctOption : 0;
    const correctText  = rawOptions[rawCorrect] ?? rawOptions[0];
    const shuffled     = rawOptions.sort(() => Math.random() - 0.5);
    const correctIndex = shuffled.indexOf(correctText);

    const ref = cardsRef.doc();
    batch.set(ref, {
      id: ref.id,
      topicId,
      type: 'mcq',
      front: String(card.front).trim(),
      back: correctText.trim(),
      options: shuffled,
      correctOption: correctIndex >= 0 ? correctIndex : 0,
      explanation: card.explanation ? String(card.explanation).trim() : null,
      difficulty: validDifficulties.includes(card.difficulty)
        ? card.difficulty
        : 'medium',
      tags: Array.isArray(card.tags) ? card.tags.slice(0, 3) : [],
      createdAt: now,
      generatedByAI: true,
      order: index,
    });
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

  console.log(`[FLASHCARDS] Generated ${written} MCQ cards for topic "${topicName}"`);
  res.json({ success: true, cardCount: written, generated: true });
});

module.exports = router;
