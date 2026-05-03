require("dotenv").config();
const express = require("express");
const helmet = require("helmet");
const cors = require("cors");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");

const { initFirebase } = require("./utils/firebase");
const authMiddleware = require("./middleware/auth");

const flashcardsRouter = require("./routes/flashcards");
const pdfRouter = require("./routes/pdf");
const notificationsRouter = require("./routes/notifications");
const leaderboardRouter = require("./routes/leaderboard");

initFirebase();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(morgan("combined"));

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: {
    success: false,
    message: "Too many requests, please try again later.",
  },
});
app.use("/api/", limiter);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

app.use("/api/flashcards", authMiddleware, flashcardsRouter);
app.use("/api/pdf", authMiddleware, pdfRouter);
app.use("/api/notifications", authMiddleware, notificationsRouter);
app.use("/api/leaderboard", authMiddleware, leaderboardRouter);

app.use((req, res) => {
  res.status(404).json({ success: false, message: "Route not found." });
});

app.use((err, req, res, _next) => {
  console.error("[ERROR]", err);
  res.status(500).json({
    success: false,
    message: err.message || "Internal server error.",
  });
});

app.listen(PORT, () => {
  const model = process.env.GEMINI_MODEL || "gemini-2.0-flash";
  const key = process.env.GEMINI_API_KEY;
  console.log(`Orbit server running on port ${PORT}`);
  console.log(`AI model   : ${model}`);
  console.log(`Gemini key : ${key ? key.slice(0, 8) + "..." : "NOT SET ⚠️"}`);
});
