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
   contactUserId: {
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
        model: "users",
        key: "id",
    },
    onUpdate: "CASCADE",
    onDelete: "SET NULL",
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
fcmToken: {
    type: DataTypes.TEXT,
    allowNull: true,
},

    },
    {
        tableName: "emergency_contacts",
        timestamps: true,
    }
);

module.exports = EmergencyContact;