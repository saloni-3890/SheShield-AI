const { messaging } = require("../config/firebaseAdmin");

const sendSosNotification = async (contacts, alert) => {
    try {
        for (const contact of contacts) {

            if (!contact.fcmToken) {
                console.log(
                    `No FCM token for ${contact.name} (${contact.phone})`
                );
                continue;
            }

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
                `SOS notification sent to ${contact.name}`
            );

            console.log(
                `FCM message ID: ${response}`
            );
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