const { messaging } = require("../config/firebaseAdmin");

const sendSosNotification = async (contacts, alert) => {
    try {
        for (const contact of contacts) {

            // =========================
            // FCM Notification
            // =========================
            if (contact.fcmToken) {
                try {
                    const message = {
                        token: contact.fcmToken,

                        notification: {
                            title: "SOS ALERT",
                            body: `Emergency alert! Location: ${alert.latitude}, ${alert.longitude}`,
                        },

                        data: {
                            type: "SOS",
                            latitude: String(alert.latitude ?? ""),
                            longitude: String(alert.longitude ?? ""),
                            alertId: String(alert.id ?? ""),
                        },

                        android: {
                            priority: "high",
                            notification: {
                                channelId: "sos_alerts",
                            },
                        },
                    };

                    const response = await messaging.send(message);

                    console.log(
                        `FCM notification sent to ${contact.name}`
                    );

                    console.log(`FCM message ID: ${response}`);

                } catch (error) {
                    console.error(
                        `FCM failed for ${contact.name}:`,
                        error.message
                    );
                }
            }

            // =========================
            // SMS
            // =========================
            // SMS is handled by the Flutter Android app
            // using native Android SmsManager.
        }

        return true;

    } catch (error) {
        console.error("Notification service error:", error);

        return false;
    }
};

module.exports = {
    sendSosNotification,
};