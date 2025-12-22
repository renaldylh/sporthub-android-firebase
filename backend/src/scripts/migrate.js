/**
 * Database Migration Script
 * Like Laravel: php artisan migrate
 * 
 * Run: npm run migrate
 * 
 * This script will:
 * 1. Create the database if not exists
 * 2. Create all tables
 * 3. Show migration status
 */

const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

// Database configuration
const config = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
};

const dbName = process.env.DB_NAME || 'sporthub';

// Migration definitions
const migrations = [
    {
        name: '001_create_users_table',
        up: `
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(36) PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        name VARCHAR(255) NOT NULL,
        role ENUM('user', 'admin') DEFAULT 'user',
        passwordHash VARCHAR(255) NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_email (email)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS users',
    },
    {
        name: '002_create_products_table',
        up: `
      CREATE TABLE IF NOT EXISTS products (
        id VARCHAR(36) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(12, 2) NOT NULL,
        stock INT NOT NULL DEFAULT 0,
        description TEXT,
        imageUrl VARCHAR(500),
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS products',
    },
    {
        name: '003_create_orders_table',
        up: `
      CREATE TABLE IF NOT EXISTS orders (
        id VARCHAR(36) PRIMARY KEY,
        userId VARCHAR(36) NOT NULL,
        totalAmount DECIMAL(12, 2) NOT NULL,
        status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
        paymentMethod VARCHAR(50),
        shippingAddress TEXT,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_userId (userId),
        INDEX idx_status (status)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS orders',
    },
    {
        name: '004_create_order_items_table',
        up: `
      CREATE TABLE IF NOT EXISTS order_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        orderId VARCHAR(36) NOT NULL,
        productId VARCHAR(36),
        name VARCHAR(255) NOT NULL,
        price DECIMAL(12, 2) NOT NULL,
        quantity INT NOT NULL,
        INDEX idx_orderId (orderId),
        FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS order_items',
    },
    {
        name: '005_create_migrations_table',
        up: `
      CREATE TABLE IF NOT EXISTS migrations (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        batch INT NOT NULL,
        migratedAt DATETIME DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS migrations',
    },
    {
        name: '006_create_communities_table',
        up: `
      CREATE TABLE IF NOT EXISTS communities (
        id VARCHAR(36) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        memberCount INT DEFAULT 0,
        imageUrl VARCHAR(500),
        category VARCHAR(100),
        isActive BOOLEAN DEFAULT true,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_name (name),
        INDEX idx_category (category)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS communities',
    },
    {
        name: '007_create_venues_table',
        up: `
      CREATE TABLE IF NOT EXISTS venues (
        id VARCHAR(36) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        type VARCHAR(100) NOT NULL,
        pricePerHour DECIMAL(12, 2) NOT NULL,
        address TEXT,
        description TEXT,
        imageUrl VARCHAR(500),
        isAvailable BOOLEAN DEFAULT true,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_name (name),
        INDEX idx_type (type)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS venues',
    },
    {
        name: '008_create_bookings_table',
        up: `
      CREATE TABLE IF NOT EXISTS bookings (
        id VARCHAR(36) PRIMARY KEY,
        venueId VARCHAR(36) NOT NULL,
        userId VARCHAR(36) NOT NULL,
        bookingDate DATE NOT NULL,
        startTime TIME NOT NULL,
        endTime TIME NOT NULL,
        totalPrice DECIMAL(12, 2) NOT NULL,
        status ENUM('pending', 'approved', 'rejected', 'cancelled', 'completed') DEFAULT 'pending',
        notes TEXT,
        adminNotes TEXT,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_venueId (venueId),
        INDEX idx_userId (userId),
        INDEX idx_status (status),
        INDEX idx_bookingDate (bookingDate)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS bookings',
    },
    {
        name: '009_create_events_table',
        up: `
      CREATE TABLE IF NOT EXISTS events (
        id VARCHAR(36) PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        eventDate DATE NOT NULL,
        location VARCHAR(500),
        imageUrl VARCHAR(500),
        isActive BOOLEAN DEFAULT true,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_eventDate (eventDate),
        INDEX idx_isActive (isActive)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `,
        down: 'DROP TABLE IF EXISTS events',
    },
    {
        name: '010_add_order_payment_columns',
        up: `
      ALTER TABLE orders 
        ADD COLUMN IF NOT EXISTS expiresAt DATETIME,
        ADD COLUMN IF NOT EXISTS paymentProof VARCHAR(500),
        MODIFY COLUMN status ENUM('pending', 'paid', 'delivery', 'completed', 'cancelled', 'expired') DEFAULT 'pending'
    `,
        down: `
      ALTER TABLE orders 
        DROP COLUMN IF EXISTS expiresAt,
        DROP COLUMN IF EXISTS paymentProof
    `,
    },
];

const runMigrations = async () => {
    console.log('🚀 Starting database migration...\n');

    let connection;

    try {
        // Connect without database first
        connection = await mysql.createConnection(config);
        console.log(`✓ Connected to MySQL server`);

        // Create database if not exists
        await connection.execute(
            `CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
        );
        console.log(`✓ Database '${dbName}' ready`);

        // Switch to the database
        await connection.changeUser({ database: dbName });
        console.log(`✓ Using database '${dbName}'\n`);

        // Create migrations table first if not exists
        await connection.execute(migrations[4].up);

        // Get already run migrations
        const [existingMigrations] = await connection.execute(
            'SELECT name FROM migrations'
        );
        const ranMigrations = new Set(existingMigrations.map((m) => m.name));

        // Get current batch number
        const [batchResult] = await connection.execute(
            'SELECT COALESCE(MAX(batch), 0) + 1 as nextBatch FROM migrations'
        );
        const batch = batchResult[0].nextBatch;

        // Run pending migrations
        let migratedCount = 0;

        for (const migration of migrations) {
            if (ranMigrations.has(migration.name)) {
                console.log(`  ⏭️  Skipped: ${migration.name} (already migrated)`);
                continue;
            }

            try {
                await connection.execute(migration.up);
                await connection.execute(
                    'INSERT INTO migrations (name, batch) VALUES (?, ?)',
                    [migration.name, batch]
                );
                console.log(`  ✅ Migrated: ${migration.name}`);
                migratedCount++;
            } catch (error) {
                console.error(`  ❌ Failed: ${migration.name}`);
                console.error(`     Error: ${error.message}`);
                throw error;
            }
        }

        console.log('\n' + '─'.repeat(50));
        if (migratedCount > 0) {
            console.log(`\n🎉 Migration completed! ${migratedCount} migration(s) run.`);
        } else {
            console.log('\n✨ Nothing to migrate. All migrations are up to date.');
        }

        // Show migration status
        console.log('\n📋 Migration Status:');
        const [allMigrations] = await connection.execute(
            'SELECT name, batch, migratedAt FROM migrations ORDER BY id'
        );

        if (allMigrations.length > 0) {
            console.log('─'.repeat(60));
            console.log(
                '| ' +
                'Migration'.padEnd(35) +
                '| ' +
                'Batch'.padEnd(7) +
                '| ' +
                'Migrated At'.padEnd(12) +
                '|'
            );
            console.log('─'.repeat(60));

            for (const m of allMigrations) {
                const date = new Date(m.migratedAt).toLocaleDateString();
                console.log(
                    '| ' +
                    m.name.padEnd(35) +
                    '| ' +
                    String(m.batch).padEnd(7) +
                    '| ' +
                    date.padEnd(12) +
                    '|'
                );
            }
            console.log('─'.repeat(60));
        }
    } catch (error) {
        console.error('\n❌ Migration failed:', error.message);

        if (error.code === 'ECONNREFUSED') {
            console.error('\n💡 Tip: Make sure MySQL is running!');
            console.error('   Start XAMPP and enable MySQL service.');
        }

        process.exit(1);
    } finally {
        if (connection) {
            await connection.end();
        }
    }
};

runMigrations();
