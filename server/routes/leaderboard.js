const express = require('express');
const { getFirestore } = require('../utils/firebase');

const router = express.Router();

// ─── POST /api/leaderboard/update ─────────────────────────────────────────────
// Recalculates weekly rankings. Called by Flutter after a session and by a
// server cron job every hour.
router.post('/update', async (req, res) => {
  try {
    const db = getFirestore();

    // Week ID: Monday-based ISO week (e.g. "2026-W17")
    const now = new Date();
    const weekId = getISOWeekId(now);

    // Fetch all users
    const usersSnap = await db.collection('users').get();
    const entries = [];

    usersSnap.forEach((doc) => {
      const u = doc.data();
      if (u.hideFromLeaderboard) return;
      entries.push({
        userId: doc.id,
        displayName: u.displayName || 'Orbit User',
        photoUrl: u.photoUrl || null,
        weeklyCardsReviewed: u.weeklyCardsReviewed || 0,
        weeklyAccuracy: u.overallAccuracy || 0,
        currentStreak: u.currentStreak || 0,
      });
    });

    // Sort by weekly cards desc, accuracy as tiebreaker
    entries.sort((a, b) => {
      if (b.weeklyCardsReviewed !== a.weeklyCardsReviewed) {
        return b.weeklyCardsReviewed - a.weeklyCardsReviewed;
      }
      return b.weeklyAccuracy - a.weeklyAccuracy;
    });

    // Write ranked entries in one batch
    const weekRef = db.collection('leaderboard').doc('weekly').collection(weekId);
    const batch = db.batch();
    const updatedAt = new Date().toISOString();

    entries.forEach((entry, index) => {
      const ref = weekRef.doc(entry.userId);
      batch.set(ref, { ...entry, rank: index + 1, updatedAt });
    });

    await batch.commit();

    res.json({ success: true, entryCount: entries.length, weekId });
  } catch (err) {
    console.error('[LEADERBOARD]', err.message);
    res.status(500).json({ success: false, message: 'Leaderboard update failed.' });
  }
});

// Returns "2026-W17" for a given date
function getISOWeekId(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const day = d.getUTCDay() || 7; // Mon=1 … Sun=7
  d.setUTCDate(d.getUTCDate() + 4 - day);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const week = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
  return `${d.getUTCFullYear()}-W${String(week).padStart(2, '0')}`;
}

module.exports = router;
