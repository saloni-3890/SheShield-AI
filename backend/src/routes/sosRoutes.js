const express = require("express");

const {
    createSosAlert,
    getSosAlerts,
    resolveSosAlert,
} = require("../controllers/sosController");

const authenticateToken = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", authenticateToken, createSosAlert);

router.get("/", authenticateToken, getSosAlerts);

router.patch("/:id/resolve", authenticateToken, resolveSosAlert);

module.exports = router;