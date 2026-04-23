const express = require('express');
const { getMessaging, getFirestore } = require('../utils/firebase');

const router = express.Router();

// ─── POST /api/notifications/send ─────────────────────────────────────────────
router.post('/send', async (req, res) => {
  const { targetUserId, title, body, data = {} } = req.body;

  if (!targetUserId || !title || !body) {
    return res.status(400).json({
      success: false,
      message: 'targetUserId, title and body are required.',
    });
  }

  try {
    // Fetch the target user's FCM token
    const db = getFirestore();
    const userDoc = await db.collection('users').doc(targetUserId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      return res.json({ success: true, message: 'User has no FCM token — skipped.' });
    }

    await getMessaging().send({
      token: fcmToken,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        priority: 'high',
        notification: { channelId: 'orbit_default' },
      },
      apns: {
        payload: { aps: { badge: 1, sound: 'default' } },
      },
    });

    res.json({ success: true });
  } catch (err) {
    console.error('[NOTIFY]', err.message);
    res.status(500).json({ success: false, message: 'Failed to send notification.' });
  }
});

module.exports = router;
