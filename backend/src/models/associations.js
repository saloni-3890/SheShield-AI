const User = require("./User");
const EmergencyContact = require("./EmergencyContact");
const SosAlert = require("./SosAlert");
const SafeJourney = require("./SafeJourney");
const Story = require("./Story");
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
User.hasMany(SafeJourney, {
  foreignKey: "userId",
  as: "safeJourneys",
  onDelete: "CASCADE",
});

SafeJourney.belongsTo(User, {
  foreignKey: "userId",
  as: "user",
});
User.hasMany(Story, {
    foreignKey: "userId",
    as: "stories",
    onDelete: "SET NULL",
});

Story.belongsTo(User, {
    foreignKey: "userId",
    as: "user",
});
module.exports = {
    User,
    EmergencyContact,
    SosAlert,
     SafeJourney,
     Story,
};