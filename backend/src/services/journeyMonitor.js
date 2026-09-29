const cron = require("node-cron");
const { Op } = require("sequelize");
const SafeJourney = require("../models/SafeJourney");
const { sendPushNotification } = require("./notificationService");
const EmergencyContact = require("../models/EmergencyContact");

const { sendJourneyMissedNotification } = require("./notificationService");
const startJourneyMonitor = () => {
  cron.schedule("* * * * *", async () => {
    try {
      const now = new Date();

      const missedJourneys = await SafeJourney.findAll({
        where: {
          status: "ACTIVE",
          expectedArrival: {
            [Op.lt]: now,
          },
        },
      });

     for (const journey of missedJourneys) {
    journey.status = "MISSED";
    await journey.save();

    console.log(
        `⚠️ Safe Journey MISSED: Journey ID ${journey.id}`
    );

    const contacts = await EmergencyContact.findAll({
        where: {
            userId: journey.userId,
        },
    });

    await sendJourneyMissedNotification(
        contacts,
        journey
    );
}
    } catch (error) {
      console.error(
        "Journey monitor error:",
        error.message
      );
    }
  });

  console.log("✅ Safe Journey monitor started");
};

module.exports = startJourneyMonitor;