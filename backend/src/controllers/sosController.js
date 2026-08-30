const SosAlert = require("../models/SosAlert");
const EmergencyContact = require("../models/EmergencyContact");

const {
    sendSosNotification,
} = require("../services/notificationService");


// CREATE SOS ALERT
const createSosAlert = async (req, res) => {
    try {
        const { latitude, longitude } = req.body;

        // Validate latitude
        if (latitude !== undefined && latitude !== null) {
            if (latitude < -90 || latitude > 90) {
                return res.status(400).json({
                    success: false,
                    message: "Invalid latitude",
                });
            }
        }

        // Validate longitude
        if (longitude !== undefined && longitude !== null) {
            if (longitude < -180 || longitude > 180) {
                return res.status(400).json({
                    success: false,
                    message: "Invalid longitude",
                });
            }
        }

        const alert = await SosAlert.create({
            userId: req.user.id,
            latitude: latitude ?? null,
            longitude: longitude ?? null,
            status: "active",
        });

        const contacts = await EmergencyContact.findAll({
            where: {
                userId: req.user.id,
            },
            attributes: ["id", "name", "phone", "relation", "fcmToken"],
        });

        await sendSosNotification(contacts, alert);

        return res.status(201).json({
            success: true,
            message: "SOS alert activated",
            alert: {
                id: alert.id,
                latitude: alert.latitude,
                longitude: alert.longitude,
                status: alert.status,
                createdAt: alert.createdAt,
            },
            emergencyContacts: contacts,
        });

    } catch (error) {
        console.error("Create SOS error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// GET SOS ALERTS
const getSosAlerts = async (req, res) => {
    try {
        const alerts = await SosAlert.findAll({
            where: {
                userId: req.user.id,
            },
            order: [["createdAt", "DESC"]],
        });

        return res.status(200).json({
            success: true,
            alerts,
        });

    } catch (error) {
        console.error("Get SOS alerts error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// RESOLVE SOS ALERT
const resolveSosAlert = async (req, res) => {
    try {
        const { id } = req.params;

        const alert = await SosAlert.findOne({
            where: {
                id,
                userId: req.user.id,
            },
        });

        if (!alert) {
            return res.status(404).json({
                success: false,
                message: "SOS alert not found",
            });
        }

        alert.status = "resolved";

        await alert.save();

        return res.status(200).json({
            success: true,
            message: "SOS alert resolved",
            alert,
        });

    } catch (error) {
        console.error("Resolve SOS error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


module.exports = {
    createSosAlert,
    getSosAlerts,
    resolveSosAlert,
};