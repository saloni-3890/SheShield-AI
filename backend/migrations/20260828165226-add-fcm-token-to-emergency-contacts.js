'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('emergency_contacts');

    if (!table.fcmToken) {
      await queryInterface.addColumn(
        'emergency_contacts',
        'fcmToken',
        {
          type: Sequelize.TEXT,
          allowNull: true,
        }
      );
    }
  },

  async down(queryInterface) {
    const table = await queryInterface.describeTable('emergency_contacts');

    if (table.fcmToken) {
      await queryInterface.removeColumn(
        'emergency_contacts',
        'fcmToken'
      );
    }
  },
};