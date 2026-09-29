const SafeJourney = require("../models/SafeJourney");


// START SAFE JOURNEY
const startJourney = async (req, res) => {
    try {
        const {
            destination,
            expectedArrival,
        } = req.body;

        // Validate destination
        if (!destination || !destination.trim()) {
            return res.status(400).json({
                success: false,
                message: "Destination is required",
            });
        }

        // Validate expected arrival
        if (!expectedArrival) {
            return res.status(400).json({
                success: false,
                message: "Expected arrival time is required",
            });
        }

        const arrivalTime = new Date(expectedArrival);

        if (isNaN(arrivalTime.getTime())) {
            return res.status(400).json({
                success: false,
                message: "Invalid expected arrival time",
            });
        }

        if (arrivalTime <= new Date()) {
            return res.status(400).json({
                success: false,
                message: "Expected arrival time must be in the future",
            });
        }

        // Check if user already has an active journey
        const activeJourney = await SafeJourney.findOne({
            where: {
                userId: req.user.id,
                status: "ACTIVE",
            },
        });

        if (activeJourney) {
            return res.status(409).json({
                success: false,
                message: "You already have an active safe journey",
                journey: activeJourney,
            });
        }

        // Create journey
        const journey = await SafeJourney.create({
            userId: req.user.id,
            destination: destination.trim(),
            startTime: new Date(),
            expectedArrival: arrivalTime,
            lastCheckIn: new Date(),
            status: "ACTIVE",
        });

        return res.status(201).json({
            success: true,
            message: "Safe journey started",
            journey,
        });

    } catch (error) {
        console.error("Start safe journey error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// GET ACTIVE JOURNEY
const getActiveJourney = async (req, res) => {
    try {
        const journey = await SafeJourney.findOne({
            where: {
                userId: req.user.id,
                status: "ACTIVE",
            },
        });

        return res.status(200).json({
            success: true,
            journey,
        });

    } catch (error) {
        console.error("Get active journey error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// CHECK-IN
const checkIn = async (req, res) => {
    try {
        const journey = await SafeJourney.findOne({
            where: {
                userId: req.user.id,
                status: "ACTIVE",
            },
        });

        if (!journey) {
            return res.status(404).json({
                success: false,
                message: "No active safe journey found",
            });
        }

        journey.lastCheckIn = new Date();

        await journey.save();

        return res.status(200).json({
            success: true,
            message: "Check-in successful. You are marked safe.",
            journey,
        });

    } catch (error) {
        console.error("Safe journey check-in error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// COMPLETE JOURNEY
const completeJourney = async (req, res) => {
    try {
        const journey = await SafeJourney.findOne({
            where: {
                userId: req.user.id,
                status: "ACTIVE",
            },
        });

        if (!journey) {
            return res.status(404).json({
                success: false,
                message: "No active safe journey found",
            });
        }

        journey.status = "COMPLETED";
        journey.lastCheckIn = new Date();

        await journey.save();

        return res.status(200).json({
            success: true,
            message: "Safe journey completed",
            journey,
        });

    } catch (error) {
        console.error("Complete safe journey error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


// CANCEL JOURNEY
const cancelJourney = async (req, res) => {
    try {
        const journey = await SafeJourney.findOne({
            where: {
                userId: req.user.id,
                status: "ACTIVE",
            },
        });

        if (!journey) {
            return res.status(404).json({
                success: false,
                message: "No active safe journey found",
            });
        }

        journey.status = "CANCELLED";

        await journey.save();

        return res.status(200).json({
            success: true,
            message: "Safe journey cancelled",
            journey,
        });

    } catch (error) {
        console.error("Cancel safe journey error:", error);

        return res.status(500).json({
            success: false,
            message: "Server error",
        });
    }
};


module.exports = {
    startJourney,
    getActiveJourney,
    checkIn,
    completeJourney,
    cancelJourney,
};