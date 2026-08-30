'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('users');

    if (!table.fcmToken) {
      await queryInterface.addColumn(
        'users',
        'fcmToken',
        {
          type: Sequelize.TEXT,
          allowNull: true,
        }
      );
    }
  },

  async down(queryInterface) {
    const table = await queryInterface.describeTable('users');

    if (table.fcmToken) {
      await queryInterface.removeColumn(
        'users',
        'fcmToken'
      );
    }
  },
};