const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Story = sequelize.define(
    "Story",
    {
        id: {
            type: DataTypes.INTEGER,
            autoIncrement: true,
            primaryKey: true,
        },

        userId: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },

        title: {
            type: DataTypes.STRING,
            allowNull: false,
        },

        content: {
            type: DataTypes.TEXT,
            allowNull: false,
        },

        category: {
            type: DataTypes.ENUM(
                "SAFETY",
                "HARASSMENT",
                "TRAVEL",
                "COLLEGE",
                "WORKPLACE",
                "ONLINE_SAFETY",
                "OTHER"
            ),
            allowNull: false,
            defaultValue: "OTHER",
        },

        isAnonymous: {
            type: DataTypes.BOOLEAN,
            allowNull: false,
            defaultValue: true,
        },

        status: {
            type: DataTypes.ENUM(
                "PENDING",
                "APPROVED",
                "REJECTED"
            ),
            allowNull: false,
            defaultValue: "PENDING",
        },
    },
    {
        tableName: "stories",
        timestamps: true,
    }
);

module.exports = Story;