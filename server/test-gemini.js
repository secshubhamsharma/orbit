/**
 * Standalone AI provider diagnostic — run from server directory:
 *   node test-gemini.js
 *
 * Tests Gemini and OpenRouter (if configured). Exit 0 = at least one works.
 */
require("dotenv").config();
const { GoogleGenerativeAI } = require("@google/generative-ai");

const geminiKey   = process.env.GEMINI_API_KEY;
const geminiModel = process.env.GEMINI_MODEL || "gemini-1.5-flash";
const orKey       = process.env.OPENROUTER_API_KEY;
const orModel     = process.env.OPENROUTER_MODEL || "meta-llama/llama-3.1-8b-instruct:free";

console.log("─────────────────────────────────────────");
console.log("AI Provider Diagnostic");
console.log("─────────────────────────────────────────");
console.log(`Gemini key    : ${geminiKey ? geminiKey.slice(0, 12) + "..." : "NOT SET ⚠️"}`);
console.log(`Gemini model  : ${geminiModel}`);
console.log(`OpenRouter key: ${orKey ? orKey.slice(0, 12) + "..." : "NOT SET"}`);
console.log(`OpenRouter mdl: ${orModel}`);
console.log("─────────────────────────────────────────");

async function testGemini() {
  if (!geminiKey) {
    console.log("⏭  Gemini: skipped (no key)");
    return false;
  }
  process.stdout.write("🔍 Gemini: testing... ");
  try {
    const genAI = new GoogleGenerativeAI(geminiKey);
    const model = genAI.getGenerativeModel({
      model: geminiModel,
      generationConfig: { temperature: 0.1, maxOutputTokens: 16 },
    });
    const result = await model.generateContent("Reply with the single word: ok");
    const text   = result.response.text().trim();
    console.log(`✅ OK — replied: "${text}"`);
    return true;
  } catch (err) {
    const status  = err.status || err.statusCode || "unknown";
    const message = err.message || String(err);
    console.log(`❌ FAILED (status=${status})`);
    console.log(`   Message: ${message}`);
    if (String(status) === "429") {
      console.log("   → Daily quota (RPD) exhausted on this Google project.");
      console.log("     Creating a new project under the SAME Google account won't help.");
      console.log("     Fix: Use a DIFFERENT Google account at aistudio.google.com");
      console.log("          OR set OPENROUTER_API_KEY as a fallback (openrouter.ai, free).");
    } else if (String(status) === "400") {
      console.log("   → Model name may be wrong. Try: gemini-1.5-flash");
    } else if (String(status) === "403") {
      console.log("   → Invalid API key or Gemini API not enabled for this project.");
    }
    return false;
  }
}

async function testOpenRouter() {
  if (!orKey) {
    console.log("⏭  OpenRouter: not configured (set OPENROUTER_API_KEY to enable free fallback)");
    return false;
  }
  process.stdout.write("🔍 OpenRouter: testing... ");
  try {
    const res = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method:  "POST",
      headers: {
        Authorization:  `Bearer ${orKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model:       orModel,
        messages:    [{ role: "user", content: "Reply with the single word: ok" }],
        max_tokens:  16,
        temperature: 0.1,
      }),
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error?.message || `HTTP ${res.status}`);
    const text = data.choices?.[0]?.message?.content?.trim() || "(empty)";
    console.log(`✅ OK — replied: "${text}"`);
    return true;
  } catch (err) {
    console.log(`❌ FAILED: ${err.message}`);
    return false;
  }
}

(async () => {
  const geminiOk = await testGemini();
  const orOk     = await testOpenRouter();

  console.log("─────────────────────────────────────────");
  if (geminiOk || orOk) {
    console.log("✅ PDF upload will work (at least one provider is available)");
    process.exit(0);
  } else {
    console.log("❌ No AI provider is working. PDF upload will fail.");
    console.log("   Quick fix: go to openrouter.ai, create a free account,");
    console.log("   get an API key, add OPENROUTER_API_KEY=sk-or-... to .env,");
    console.log("   then restart PM2.");
    process.exit(1);
  }
})();
