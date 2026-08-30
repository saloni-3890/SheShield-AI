const express = require("express");

const {
    addContact,
    getContacts,
    updateContact,
    deleteContact,
    saveContactFcmToken,
 linkContactUser,
} = require("../controllers/emergencyContactController");

const authenticateToken = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", authenticateToken, addContact);
router.patch(
    "/:id/link-user",
    authenticateToken,
    linkContactUser
);

router.get("/", authenticateToken, getContacts);

router.delete("/:id", authenticateToken, deleteContact);
router.put("/:id", authenticateToken, updateContact);
router.patch(
    "/:id/fcm-token",
    authenticateToken,
    saveContactFcmToken
);
module.exports = router;