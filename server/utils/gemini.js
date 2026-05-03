const { GoogleGenerativeAI } = require("@google/generative-ai");

let _client = null;

function getClient() {
  if (!_client) {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) throw new Error("GEMINI_API_KEY is not set in environment.");
    _client = new GoogleGenerativeAI(apiKey);
  }
  return _client;
}

/**
 * Returns a configured Gemini model instance.
 * Defaults to GEMINI_MODEL env var, falling back to gemini-1.5-flash.
 *
 * Free-tier daily limits (RPD):
 *   gemini-1.5-flash-8b → 4,000 RPD  ← recommended for production
 *   gemini-1.5-flash    → 1,500 RPD
 *   gemini-2.0-flash    → 1,500 RPD  (may be unstable on SDK v0.21)
 *
 * Set GEMINI_MODEL=gemini-1.5-flash-8b in .env for highest free-tier quota.
 */
function getModel(modelName) {
  const name = modelName || process.env.GEMINI_MODEL || "gemini-1.5-flash";
  return getClient().getGenerativeModel({
    model: name,
    generationConfig: {
      temperature: 0.4,
      maxOutputTokens: 8192,
    },
  });
}

module.exports = { getModel };
