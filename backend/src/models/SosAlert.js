const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const SosAlert = sequelize.define(
    "SosAlert",
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

        latitude: {
            type: DataTypes.DECIMAL(10, 8),
            allowNull: true,
        },

        longitude: {
            type: DataTypes.DECIMAL(11, 8),
            allowNull: true,
        },

        status: {
            type: DataTypes.STRING,
            allowNull: false,
            defaultValue: "active",
        },
    },
    {
        tableName: "sos_alerts",
        timestamps: true,
    }
);

module.exports = SosAlert;