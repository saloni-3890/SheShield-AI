const express = require("express");
const sequelize = require("./config/database");

const User = require("./models/User");
const authRoutes = require("./routes/authRoutes");
const emergencyContactRoutes = require("./routes/emergencyContactRoutes");
require("./models/associations");
const sosRoutes = require("./routes/sosRoutes");
const app = express();

app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/emergency-contacts", emergencyContactRoutes);
app.use("/api/sos", sosRoutes);

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

module.exports = app;