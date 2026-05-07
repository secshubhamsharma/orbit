require("dotenv").config();

const admin = require("firebase-admin");
const fs = require("fs");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function upload() {
  const filePath = process.argv[2] || "./questions.json";

  if (!fs.existsSync(filePath)) {
    console.error(`\n❌ File not found: ${filePath}`);
    console.error("   Usage: node upload-questions.js questions.json\n");
    process.exit(1);
  }

  let chapters;
  try {
    chapters = JSON.parse(fs.readFileSync(filePath, "utf8"));
    if (!Array.isArray(chapters)) throw new Error("Root must be a JSON array");
  } catch (err) {
    console.error(`\n❌ Invalid JSON: ${err.message}\n`);
    process.exit(1);
  }

  console.log(`\n📤 Uploading questions for ${chapters.length} chapters...\n`);

  const validDiffs = ["beginner", "intermediate", "advanced"];
  let totalWritten = 0;
  let skipped = 0;

  for (const chapter of chapters) {
    const { domainId, subjectId, bookId, chapterId, chapterName, questions } = chapter;

    if (!domainId || !subjectId || !bookId || !chapterId) {
      console.warn(`  ⚠️  Skipping entry missing required IDs: ${JSON.stringify(chapter).slice(0, 80)}`);
      skipped++;
      continue;
    }

    if (!Array.isArray(questions) || questions.length === 0) {
      console.log(`  ⏭  ${chapterName || chapterId} — no questions in file`);
      skipped++;
      continue;
    }

    const chapterRef = db
      .collection("domains").doc(domainId)
      .collection("subjects").doc(subjectId)
      .collection("books").doc(bookId)
      .collection("chapters").doc(chapterId);

    const existing = await chapterRef.collection("flashcards").limit(1).get();
    if (!existing.empty) {
      console.log(`  ⏭  ${chapterName || chapterId} — already seeded, skipping`);
      skipped++;
      continue;
    }

    const now = new Date().toISOString();
    const batch = db.batch();
    let written = 0;

    questions.forEach((q, i) => {
      if (!q.front || !Array.isArray(q.options) || q.options.length < 2) return;

      const rawOptions = q.options.map(String).slice(0, 4);
      while (rawOptions.length < 4) rawOptions.push(`Option ${rawOptions.length + 1}`);

      const rawCorrect = typeof q.correctOption === "number"
        ? Math.min(q.correctOption, rawOptions.length - 1)
        : 0;
      const correctText = rawOptions[rawCorrect];

      // Shuffle so correct answer is at a random position
      const shuffled = [...rawOptions].sort(() => Math.random() - 0.5);
      const finalCorrect = shuffled.indexOf(correctText);

      const ref = chapterRef.collection("flashcards").doc();
      batch.set(ref, {
        id: ref.id,
        topicId: chapterId,
        type: "mcq",
        front: String(q.front).trim(),
        back: correctText.trim(),
        options: shuffled,
        correctOption: finalCorrect >= 0 ? finalCorrect : 0,
        explanation: q.explanation ? String(q.explanation).trim() : null,
        difficulty: validDiffs.includes(q.difficulty) ? q.difficulty : "intermediate",
        tags: Array.isArray(q.tags) ? q.tags.slice(0, 3) : [],
        createdAt: now,
        generatedByAI: true,
        order: i,
      });
      written++;
    });

    // Firestore batch limit is 500; flush if needed
    await batch.commit();
    await chapterRef.update({ totalCards: written });

    console.log(`  ✅ ${(chapterName || chapterId).padEnd(45)} ${written} questions`);
    totalWritten += written;
  }

  console.log(`\n✅ Done — ${totalWritten} questions uploaded, ${skipped} chapters skipped`);
  process.exit(0);
}

upload().catch((err) => {
  console.error("\n❌ Upload failed:", err.message);
  process.exit(1);
});
