/**
 * Database Rollback Script
 * Like Laravel: php artisan migrate:rollback
 * 
 * Run: npm run migrate:rollback
 * 
 * This script will rollback the last batch of migrations
 */

const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

const config = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'sporthub',
};

// Migration rollback definitions (in reverse order)
const rollbacks = {
    '004_create_order_items_table': 'DROP TABLE IF EXISTS order_items',
    '003_create_orders_table': 'DROP TABLE IF EXISTS orders',
    '002_create_products_table': 'DROP TABLE IF EXISTS products',
    '001_create_users_table': 'DROP TABLE IF EXISTS users',
};

const rollback = async () => {
    console.log('🔄 Starting migration rollback...\n');

    let connection;

    try {
        connection = await mysql.createConnection(config);
        console.log(`✓ Connected to database '${config.database}'\n`);

        // Get last batch
        const [batchResult] = await connection.execute(
            'SELECT MAX(batch) as lastBatch FROM migrations'
        );
        const lastBatch = batchResult[0].lastBatch;

        if (!lastBatch) {
            console.log('✨ Nothing to rollback.');
            return;
        }

        // Get migrations from last batch
        const [migrationsToRollback] = await connection.execute(
            'SELECT name FROM migrations WHERE batch = ? ORDER BY id DESC',
            [lastBatch]
        );

        if (migrationsToRollback.length === 0) {
            console.log('✨ Nothing to rollback.');
            return;
        }

        console.log(`Rolling back batch ${lastBatch}...\n`);

        for (const migration of migrationsToRollback) {
            const rollbackSql = rollbacks[migration.name];

            if (rollbackSql) {
                try {
                    await connection.execute(rollbackSql);
                    await connection.execute(
                        'DELETE FROM migrations WHERE name = ?',
                        [migration.name]
                    );
                    console.log(`  ✅ Rolled back: ${migration.name}`);
                } catch (error) {
                    console.error(`  ❌ Failed: ${migration.name}`);
                    console.error(`     Error: ${error.message}`);
                }
            }
        }

        console.log(`\n🎉 Rollback completed!`);
    } catch (error) {
        console.error('\n❌ Rollback failed:', error.message);

        if (error.code === 'ECONNREFUSED') {
            console.error('\n💡 Tip: Make sure MySQL is running!');
        }

        process.exit(1);
    } finally {
        if (connection) {
            await connection.end();
        }
    }
};

rollback();
