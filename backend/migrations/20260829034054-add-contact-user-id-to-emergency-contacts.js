'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    const table = await queryInterface.describeTable('emergency_contacts');

    if (!table.contactUserId) {
      await queryInterface.addColumn(
        'emergency_contacts',
        'contactUserId',
        {
          type: Sequelize.INTEGER,
          allowNull: true,
          references: {
            model: 'users',
            key: 'id',
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
        }
      );
    }
  },

  async down(queryInterface) {
    const table = await queryInterface.describeTable('emergency_contacts');

    if (table.contactUserId) {
      await queryInterface.removeColumn(
        'emergency_contacts',
        'contactUserId'
      );
    }
  },
};