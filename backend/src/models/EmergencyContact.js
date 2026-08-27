const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const EmergencyContact = sequelize.define(
    "EmergencyContact",
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

        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },

        phone: {
            type: DataTypes.STRING,
            allowNull: false,
        },

        relation: {
            type: DataTypes.STRING,
            allowNull: true,
        },
    },
    {
        tableName: "emergency_contacts",
        timestamps: true,
    }
);

module.exports = EmergencyContact;