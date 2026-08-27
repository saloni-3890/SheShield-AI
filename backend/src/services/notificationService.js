const sendSosNotification = async (contacts, alert) => {
    try {
        for (const contact of contacts) {
            console.log(
                `🚨 SOS notification prepared for ${contact.name} (${contact.phone})`
            );

            console.log(
                `Location: ${alert.latitude}, ${alert.longitude}`
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