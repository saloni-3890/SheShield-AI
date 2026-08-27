const express = require("express");

const {
    addContact,
    getContacts,
    updateContact,
    deleteContact,
} = require("../controllers/emergencyContactController");

const authenticateToken = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", authenticateToken, addContact);

router.get("/", authenticateToken, getContacts);

router.delete("/:id", authenticateToken, deleteContact);
router.put("/:id", authenticateToken, updateContact);

module.exports = router;