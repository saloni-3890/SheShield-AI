const express = require("express");
const router = express.Router();

const { testGemini, analyzeProblem } = require("../services/aiService");

router.get("/test", async (req, res) => {
  try {
    const result = await testGemini();

    res.json({
      success: true,
      message: result,
    });
  } catch (error) {
    console.error("Gemini Test Error:", error);

    res.status(500).json({
      success: false,
      message: "Gemini API test failed",
      error: error.message,
    });
  }
});
router.post("/analyze", async (req, res) => {
  try {
    const { problem } = req.body;

    if (!problem || !problem.trim()) {
      return res.status(400).json({
        success: false,
        message: "Problem is required",
      });
    }

    const result = await analyzeProblem(problem);

    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("AI Analyze Error:", error);

    res.status(500).json({
      success: false,
      message: "Unable to analyze the problem",
      error: error.message,
    });
  }
});
module.exports = router;