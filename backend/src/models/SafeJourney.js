const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const SafeJourney = sequelize.define(
  "SafeJourney",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },

    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },

    destination: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    startTime: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW,
    },

    expectedArrival: {
      type: DataTypes.DATE,
      allowNull: false,
    },

    lastCheckIn: {
      type: DataTypes.DATE,
      allowNull: true,
    },

    status: {
      type: DataTypes.ENUM(
        "ACTIVE",
        "COMPLETED",
        "CANCELLED",
        "MISSED"
      ),
      allowNull: false,
      defaultValue: "ACTIVE",
    },
  },
  {
    tableName: "safe_journeys",
    timestamps: true,
  }
);

module.exports = SafeJourney;