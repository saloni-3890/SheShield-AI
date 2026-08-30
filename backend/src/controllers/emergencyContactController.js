const EmergencyContact = require("../models/EmergencyContact");
const User = require("../models/User");

// Add Emergency Contact
const addContact = async (req, res) => {
    try {
        const { name, phone, relation } = req.body;

        if (!name || !phone) {
            return res.status(400).json({
                success: false,
                message: "Name and phone are required",
            });
        }

        const contact = await EmergencyContact.create({
            userId: req.user.id,
            name,
            phone,
            relation,
        });

        return res.status(201).json({
            success: true,
            message: "Emergency contact added successfully",
            contact,
        });

    } catch (error) {
        console.error("Add contact error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// Get Emergency Contacts
const getContacts = async (req, res) => {
    try {
        const contacts = await EmergencyContact.findAll({
            where: {
                userId: req.user.id,
            },
            order: [["createdAt", "DESC"]],
        });

        return res.status(200).json({
            success: true,
            contacts,
        });

    } catch (error) {
        console.error("Get contacts error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// Delete Emergency Contact
const deleteContact = async (req, res) => {
    try {
        const { id } = req.params;

        const contact = await EmergencyContact.findOne({
            where: {
                id,
                userId: req.user.id,
            },
        });

        if (!contact) {
            return res.status(404).json({
                success: false,
                message: "Emergency contact not found",
            });
        }

        await contact.destroy();

        return res.status(200).json({
            success: true,
            message: "Emergency contact deleted successfully",
        });

    } catch (error) {
        console.error("Delete contact error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};
const updateContact = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, phone, relation } = req.body;

        const contact = await EmergencyContact.findOne({
            where: {
                id,
                userId: req.user.id,
            },
        });

        if (!contact) {
            return res.status(404).json({
                success: false,
                message: "Emergency contact not found",
            });
        }

        if (name !== undefined) contact.name = name;
        if (phone !== undefined) contact.phone = phone;
        if (relation !== undefined) contact.relation = relation;

        await contact.save();

        return res.status(200).json({
            success: true,
            message: "Emergency contact updated successfully",
            contact,
        });

    } catch (error) {
        console.error("Update contact error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};
// Save FCM Token for Emergency Contact
const saveContactFcmToken = async (req, res) => {
    try {
        const { id } = req.params;
        const { fcmToken } = req.body;

        if (!fcmToken) {
            return res.status(400).json({
                success: false,
                message: "FCM token is required",
            });
        }

        const contact = await EmergencyContact.findOne({
            where: {
                id,
                userId: req.user.id,
            },
        });

        if (!contact) {
            return res.status(404).json({
                success: false,
                message: "Emergency contact not found",
            });
        }

        contact.fcmToken = fcmToken;

        await contact.save();

        return res.status(200).json({
            success: true,
            message: "FCM token saved successfully",
        });

    } catch (error) {
        console.error("Save contact FCM token error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};
// Link emergency contact to an existing SheShield user
const linkContactUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { contactUserId } = req.body;

        if (!contactUserId) {
            return res.status(400).json({
                success: false,
                message: "contactUserId is required",
            });
        }

        // Find the emergency contact belonging to logged-in user
        const contact = await EmergencyContact.findOne({
            where: {
                id,
                userId: req.user.id,
            },
        });

        if (!contact) {
            return res.status(404).json({
                success: false,
                message: "Emergency contact not found",
            });
        }

        // Prevent linking yourself
        if (Number(contactUserId) === Number(req.user.id)) {
            return res.status(400).json({
                success: false,
                message: "You cannot link yourself as an emergency contact",
            });
        }

        // Find the actual SheShield user
        const contactUser = await User.findByPk(contactUserId);

        if (!contactUser) {
            return res.status(404).json({
                success: false,
                message: "Contact user not found",
            });
        }

        // Link user and copy their current FCM token
        contact.contactUserId = contactUser.id;
        contact.fcmToken = contactUser.fcmToken || null;

        await contact.save();

        return res.status(200).json({
            success: true,
            message: "Emergency contact linked successfully",
            contact: {
                id: contact.id,
                name: contact.name,
                phone: contact.phone,
                relation: contact.relation,
                contactUserId: contact.contactUserId,
                fcmToken: contact.fcmToken,
            },
        });

    } catch (error) {
        console.error("Link contact user error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};

module.exports = {
    addContact,
    getContacts,
    updateContact,
    deleteContact,
    saveContactFcmToken,
    linkContactUser,
};
