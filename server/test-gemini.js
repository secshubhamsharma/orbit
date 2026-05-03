/**
 * Standalone Gemini diagnostic — run from server directory:
 *   node test-gemini.js
 *
 * Reads .env, prints key prefix + model, then makes a real Gemini call.
 * Exit 0 = working, Exit 1 = broken (shows exact error).
 */
require("dotenv").config();
const { GoogleGenerativeAI } = require("@google/generative-ai");

const key   = process.env.GEMINI_API_KEY;
const model = process.env.GEMINI_MODEL || "gemini-1.5-flash";

console.log("─────────────────────────────────────────");
console.log("Gemini Diagnostic");
console.log("─────────────────────────────────────────");
console.log(`API key : ${key ? key.slice(0, 12) + "..." : "NOT SET ⚠️"}`);
console.log(`Model   : ${model}`);
console.log("─────────────────────────────────────────");

if (!key) {
  console.error("❌ GEMINI_API_KEY is not set in .env");
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(key);
const m = genAI.getGenerativeModel({
  model,
  generationConfig: { temperature: 0.1, maxOutputTokens: 16 },
});

console.log("Calling Gemini...");

m.generateContent("Reply with the single word: ok")
  .then((result) => {
    const text = result.response.text().trim();
    console.log(`✅ SUCCESS — Gemini replied: "${text}"`);
    process.exit(0);
  })
  .catch((err) => {
    const status  = err.status || err.statusCode || "unknown";
    const message = err.message || String(err);
    console.error(`❌ FAILED`);
    console.error(`   HTTP status : ${status}`);
    console.error(`   Message     : ${message}`);
    if (String(status) === "429") {
      console.error("");
      console.error("   → Rate limit hit. Possible causes:");
      console.error("     1. Daily quota (RPD) exhausted on this project");
      console.error("     2. Per-minute limit (15 RPM) — wait 60s and retry");
      console.error("     3. Key from Cloud Console (quota=0) — use AI Studio key");
    } else if (String(status) === "400") {
      console.error("   → Model name may be wrong or not available for this key");
    } else if (String(status) === "403") {
      console.error("   → API not enabled for this project, or key is invalid");
    }
    process.exit(1);
  });
