const express = require("express");

const {
    startJourney,
    getActiveJourney,
    checkIn,
    completeJourney,
    cancelJourney,
} = require("../controllers/safeJourneyController");

const authenticateToken = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/start", authenticateToken, startJourney);

router.get("/active", authenticateToken, getActiveJourney);

router.post("/check-in", authenticateToken, checkIn);

router.post("/complete", authenticateToken, completeJourney);

router.post("/cancel", authenticateToken, cancelJourney);

module.exports = router;