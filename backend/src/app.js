const express = require("express");
const cors = require("cors");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health Check
app.get("/api/health", (req, res) => {
    res.status(200).json({
        success: true,
        message: "SheShield AI Backend is running",
    });
});

module.exports = app;