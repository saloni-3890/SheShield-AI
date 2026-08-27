const User = require("./User");
const EmergencyContact = require("./EmergencyContact");
const SosAlert = require("./SosAlert");

User.hasMany(EmergencyContact, {
    foreignKey: "userId",
    as: "emergencyContacts",
    onDelete: "CASCADE",
});

EmergencyContact.belongsTo(User, {
    foreignKey: "userId",
    as: "user",
});

User.hasMany(SosAlert, {
    foreignKey: "userId",
    as: "sosAlerts",
    onDelete: "CASCADE",
});

SosAlert.belongsTo(User, {
    foreignKey: "userId",
    as: "user",
});

module.exports = {
    User,
    EmergencyContact,
    SosAlert,
};