const express = require("express");

const {
    createStory,
    getStories,
    getMyStories,
    deleteStory,
} = require("../controllers/storyController");

const authenticateToken = require("../middleware/authMiddleware");

const router = express.Router();

// Submit a new story
router.post("/", authenticateToken, createStory);

// Get approved public stories
router.get("/", authenticateToken, getStories);

// Get logged-in user's stories
router.get("/my", authenticateToken, getMyStories);

// Delete user's own story
router.delete("/:id", authenticateToken, deleteStory);

module.exports = router;