const { GoogleGenAI } = require("@google/genai");

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const analyzeProblem = async (problem) => {
  const prompt = `
You are SheShield AI, a responsible personal safety and problem-solving assistant.

Analyze the user's situation and provide practical, calm and actionable guidance.

USER'S PROBLEM:
${problem}

Return the response in exactly this JSON structure:

{
  "riskLevel": "LOW | MEDIUM | HIGH | CRITICAL",
  "summary": "Short explanation of the situation",
  "immediateActions": [
    "Action 1",
    "Action 2",
    "Action 3"
  ],
  "safetyPlan": [
    "Step 1",
    "Step 2",
    "Step 3"
  ],
  "whenToSeekHelp": "Explain when the user should contact a trusted person, emergency service, or use SOS",
  "supportMessage": "A short supportive message"
}

Rules:
- Keep advice practical and easy to understand.
- Never blame the user.
- Do not encourage confrontation or retaliation.
- If there is immediate danger, prioritize getting to a safe/public place and contacting trusted people or emergency services.
- Do not pretend to be a police officer, doctor, lawyer, or other professional.
- Do not invent facts about the user's situation.
- Return ONLY valid JSON. No markdown. No code fences.
`;

  const response = await ai.models.generateContent({
    model: "gemini-3.6-flash",
    contents: prompt,
  });

  const text = response.text.trim();

  try {
    return JSON.parse(text);
  } catch (error) {
    console.error("AI JSON Parse Error:", text);
    throw new Error("AI returned an invalid response format");
  }
};

const testGemini = async () => {
  const response = await ai.models.generateContent({
    model: "gemini-3.6-flash",
    contents: "Say hello from SheShield AI in one short sentence.",
  });

  return response.text;
};

module.exports = {
  testGemini,
  analyzeProblem,
};