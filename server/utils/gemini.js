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
 * gemini-1.5-flash is used as the default because it is stable across all
 * SDK versions and available on the free tier without additional setup.
 * Set GEMINI_MODEL=gemini-2.0-flash in .env to use the newer model.
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
