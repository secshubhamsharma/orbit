/**
 * AI text generation with automatic provider fallback.
 *
 * Priority order:
 *   1. Google Gemini  (GEMINI_API_KEY)
 *   2. OpenRouter     (OPENROUTER_API_KEY) — free Llama 3.1 fallback
 *
 * If Gemini is rate-limited / quota-exhausted and OPENROUTER_API_KEY is set,
 * the request is automatically retried on OpenRouter with no delay.
 *
 * Setup (server .env):
 *   GEMINI_API_KEY=AIza...          ← from aistudio.google.com
 *   GEMINI_MODEL=gemini-1.5-flash-8b
 *   OPENROUTER_API_KEY=sk-or-...    ← from openrouter.ai (free, no credit card)
 *   OPENROUTER_MODEL=meta-llama/llama-3.1-8b-instruct:free   ← default
 */

const { getModel } = require("./gemini");

// ─── Public API ───────────────────────────────────────────────────────────────

/**
 * Generate text from a prompt.
 * Tries Gemini first; falls back to OpenRouter on rate-limit errors.
 *
 * @param {string} prompt
 * @returns {Promise<string>}
 */
async function generateText(prompt) {
  // ── Try Gemini ─────────────────────────────────────────────────────────────
  try {
    const model  = getModel();
    const result = await model.generateContent(prompt);
    return result.response.text();
  } catch (err) {
    if (!isRateLimitError(err)) throw err;   // propagate non-rate-limit errors

    const orKey = process.env.OPENROUTER_API_KEY;
    if (!orKey) {
      // Mark so callers can show a helpful error instead of a generic one
      err._isRateLimit = true;
      throw err;
    }

    console.warn("[AI] Gemini rate-limited — switching to OpenRouter fallback");
    return _openRouterGenerate(prompt, orKey);
  }
}

/**
 * Returns true if the error is a quota / rate-limit response from any provider.
 */
function isRateLimitError(err) {
  const status  = String(err.status || err.statusCode || "");
  const message = (err.message || "").toLowerCase();
  return (
    status === "429" ||
    message.includes("rate") ||
    message.includes("quota") ||
    message.includes("exhausted") ||
    message.includes("resource has been")
  );
}

// ─── OpenRouter ───────────────────────────────────────────────────────────────

async function _openRouterGenerate(prompt, apiKey) {
  const model = process.env.OPENROUTER_MODEL
    || "meta-llama/llama-3.1-8b-instruct:free";

  console.log(`[AI/OpenRouter] Using model: ${model}`);

  const res = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization:  `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "https://orbitapp.io",
      "X-Title":      "Orbit Flashcard App",
    },
    body: JSON.stringify({
      model,
      messages: [{ role: "user", content: prompt }],
      max_tokens:  8192,
      temperature: 0.4,
    }),
  });

  if (!res.ok) {
    const body    = await res.json().catch(() => ({}));
    const message = body.error?.message || `HTTP ${res.status}`;
    const err     = new Error(`OpenRouter: ${message}`);
    err.status    = res.status;
    throw err;
  }

  const data = await res.json();
  const text = data.choices?.[0]?.message?.content;
  if (!text) throw new Error("OpenRouter returned an empty response");
  return text;
}

module.exports = { generateText, isRateLimitError };
