require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { initFirebase } = require('./utils/firebase');
const authMiddleware = require('./middleware/auth');

const flashcardsRouter = require('./routes/flashcards');
const pdfRouter = require('./routes/pdf');
const notificationsRouter = require('./routes/notifications');
const leaderboardRouter = require('./routes/leaderboard');

// ─── Init ──────────────────────────────────────────────────────────────────────
initFirebase();

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Security & logging ────────────────────────────────────────────────────────
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));

// ─── Rate limiting ─────────────────────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use('/api/', limiter);

// ─── Body parsing ──────────────────────────────────────────────────────────────
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── Health check (no auth) ────────────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─── Protected API routes ──────────────────────────────────────────────────────
app.use('/api/flashcards', authMiddleware, flashcardsRouter);
app.use('/api/pdf',        authMiddleware, pdfRouter);
app.use('/api/notifications', authMiddleware, notificationsRouter);
app.use('/api/leaderboard',   authMiddleware, leaderboardRouter);

// ─── 404 ───────────────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found.' });
});

// ─── Global error handler ─────────────────────────────────────────────────────
app.use((err, req, res, _next) => {
  console.error('[ERROR]', err);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal server error.',
  });
});

// ─── Start ─────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`Orbit server running on port ${PORT}`);
});
