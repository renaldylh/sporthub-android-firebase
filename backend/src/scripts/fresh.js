/**
 * Fresh Migration Script
 * Like Laravel: php artisan migrate:fresh --seed
 * 
 * Run: npm run migrate:fresh
 * 
 * This script will:
 * 1. Drop all tables
 * 2. Run all migrations
 * 3. Seed the database
 */

const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const { execSync } = require('child_process');

dotenv.config();

const config = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
};

const dbName = process.env.DB_NAME || 'sporthub';

const freshMigration = async () => {
    console.log('🗑️  Starting fresh migration...\n');

    let connection;

    try {
        connection = await mysql.createConnection(config);
        console.log(`✓ Connected to MySQL server`);

        // Drop database if exists
        await connection.execute(`DROP DATABASE IF EXISTS \`${dbName}\``);
        console.log(`✓ Dropped database '${dbName}'`);

        await connection.end();
        console.log('\n📦 Running migrations...\n');

        // Run migrate script
        execSync('node src/scripts/migrate.js', {
            cwd: process.cwd(),
            stdio: 'inherit',
        });

        console.log('\n🌱 Running seeders...\n');

        // Run seed script
        execSync('node src/scripts/seed.js', {
            cwd: process.cwd(),
            stdio: 'inherit',
        });

        console.log('\n🎉 Fresh migration with seeding completed!');
    } catch (error) {
        console.error('\n❌ Fresh migration failed:', error.message);

        if (error.code === 'ECONNREFUSED') {
            console.error('\n💡 Tip: Make sure MySQL is running!');
        }

        process.exit(1);
    }
};

freshMigration();
