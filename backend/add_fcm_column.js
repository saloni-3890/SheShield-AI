const sequelize = require("./src/config/database");

async function addFcmColumn() {
    try {
        await sequelize.authenticate();

        console.log("Database connected.");

        await sequelize.query(`
            ALTER TABLE users
            ADD COLUMN IF NOT EXISTS "fcmToken" TEXT;
        `);

        console.log("✅ fcmToken column added successfully.");

    } catch (error) {
        console.error("❌ Error:", error);
    } finally {
        await sequelize.close();
    }
}

addFcmColumn();