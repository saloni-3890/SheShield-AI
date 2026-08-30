const express = require("express");

const {
    register,
    login,
    getMe,
    saveFcmToken
} = require("../controllers/authController");

const authenticateToken = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/register", register);

router.post("/login", login);

router.get("/me", authenticateToken, getMe);
router.post(
    "/fcm-token",
    authenticateToken,
    saveFcmToken
);
module.exports = router;