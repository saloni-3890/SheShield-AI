const express = require("express");
const sequelize = require("./config/database");
const aiRoutes = require("./routes/ai");
const safeJourneyRoutes = require("./routes/safeJourneyRoutes");
const User = require("./models/User");
const authRoutes = require("./routes/authRoutes");
const emergencyContactRoutes = require("./routes/emergencyContactRoutes");
require("./models/associations");
const sosRoutes = require("./routes/sosRoutes");
const app = express();
const storyRoutes = require("./routes/storyRoutes");
app.use(express.json());
const startJourneyMonitor = require("./services/journeyMonitor");

app.use("/api/auth", authRoutes);
app.use("/api/emergency-contacts", emergencyContactRoutes);
app.use("/api/sos", sosRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/stories", storyRoutes);
app.use("/api/safe-journey", safeJourneyRoutes);
app.get("/api/health", (req, res) => {
    res.json({
        success: true,
        message: "SheShield API is running",
    });
});

const testDatabase = async () => {
    try {
        await sequelize.authenticate();

        console.log("✅ PostgreSQL database connected successfully.");

        await sequelize.sync({ alter: true });
        console.log("✅ Database tables synchronized successfully.");
    } catch (error) {
        console.error("❌ Database connection failed:");
        console.error(error.message);
    }
};

testDatabase();

startJourneyMonitor();

module.exports = app;
