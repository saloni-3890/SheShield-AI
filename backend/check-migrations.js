require("dotenv").config();

const { Client } = require("pg");

async function check() {
    const client = new Client({
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
    });

    try {
        await client.connect();

        const result = await client.query(
            'SELECT * FROM "SequelizeMeta" ORDER BY name'
        );

        console.log(result.rows);
    } catch (error) {
        console.error(error);
    } finally {
        await client.end();
    }
}

check();