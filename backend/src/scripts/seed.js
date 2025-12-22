/**
 * Database Seeder Script
 * Creates initial admin user and sample products
 * 
 * Run: npm run seed
 */

const dotenv = require('dotenv');
dotenv.config();

const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { pool, initializeDatabase, query } = require('../config/database');

const seedDatabase = async () => {
    console.log('🌱 Starting database seed...\n');

    try {
        // Initialize tables first
        await initializeDatabase();

        // Check if admin exists
        const [existingAdmin] = await query(
            'SELECT id FROM users WHERE email = ?',
            ['admin@sporthub.com']
        );

        if (existingAdmin.length === 0) {
            // Create admin user
            const adminId = uuidv4();
            const passwordHash = await bcrypt.hash('admin123', 10);
            const now = new Date().toISOString();

            await query(
                `INSERT INTO users (id, email, name, role, passwordHash, createdAt)
         VALUES (?, ?, ?, ?, ?, ?)`,
                [adminId, 'admin@sporthub.com', 'Administrator', 'admin', passwordHash, now]
            );

            console.log('✅ Admin user created:');
            console.log('   Email: admin@sporthub.com');
            console.log('   Password: admin123');
        } else {
            console.log('ℹ️  Admin user already exists');
        }

        // Check if regular user exists
        const [existingUser] = await query(
            'SELECT id FROM users WHERE email = ?',
            ['user@sporthub.com']
        );

        if (existingUser.length === 0) {
            // Create regular user
            const userId = uuidv4();
            const userPasswordHash = await bcrypt.hash('user123', 10);
            const now = new Date().toISOString();

            await query(
                `INSERT INTO users (id, email, name, role, passwordHash, createdAt)
         VALUES (?, ?, ?, ?, ?, ?)`,
                [userId, 'user@sporthub.com', 'User Demo', 'user', userPasswordHash, now]
            );

            console.log('✅ Regular user created:');
            console.log('   Email: user@sporthub.com');
            console.log('   Password: user123');
        } else {
            console.log('ℹ️  Regular user already exists');
        }

        // Check if sample products exist
        const [existingProducts] = await query('SELECT COUNT(*) as count FROM products');

        if (existingProducts[0].count === 0) {
            const now = new Date().toISOString();
            const sampleProducts = [
                {
                    id: uuidv4(),
                    name: 'Sepatu Olahraga Running',
                    price: 450000,
                    stock: 25,
                    description: 'Sepatu running ringan dan nyaman untuk olahraga harian',
                    imageUrl: null,
                },
                {
                    id: uuidv4(),
                    name: 'Bola Futsal Mikasa',
                    price: 185000,
                    stock: 50,
                    description: 'Bola futsal original berkualitas tinggi',
                    imageUrl: null,
                },
                {
                    id: uuidv4(),
                    name: 'Raket Badminton Yonex',
                    price: 320000,
                    stock: 15,
                    description: 'Raket badminton untuk pemain intermediate',
                    imageUrl: null,
                },
                {
                    id: uuidv4(),
                    name: 'Jersey Sepak Bola Tim Nasional',
                    price: 275000,
                    stock: 40,
                    description: 'Jersey resmi tim nasional Indonesia',
                    imageUrl: null,
                },
                {
                    id: uuidv4(),
                    name: 'Dumbbell Set 10kg',
                    price: 550000,
                    stock: 20,
                    description: 'Set dumbbell adjustable untuk home workout',
                    imageUrl: null,
                },
            ];

            for (const product of sampleProducts) {
                await query(
                    `INSERT INTO products (id, name, price, stock, description, imageUrl, createdAt, updatedAt)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                    [product.id, product.name, product.price, product.stock, product.description, product.imageUrl, now, now]
                );
            }

            console.log(`\n✅ ${sampleProducts.length} sample products created`);
        } else {
            console.log(`ℹ️  ${existingProducts[0].count} products already exist`);
        }

        // Check if sample communities exist
        const [existingCommunities] = await query('SELECT COUNT(*) as count FROM communities');

        if (existingCommunities[0].count === 0) {
            const now = new Date().toISOString();
            const sampleCommunities = [
                {
                    id: uuidv4(),
                    name: 'Banyumas Futsal Club',
                    description: 'Komunitas penggemar futsal dari berbagai kalangan, sering mengadakan sparring dan turnamen internal.',
                    category: 'Futsal',
                    memberCount: 230,
                },
                {
                    id: uuidv4(),
                    name: 'Runner Banyumas',
                    description: 'Komunitas lari yang rutin mengadakan fun run dan latihan bersama di Alun-Alun Banyumas setiap minggu pagi.',
                    category: 'Lari',
                    memberCount: 180,
                },
                {
                    id: uuidv4(),
                    name: 'Basket Lovers Purwokerto',
                    description: 'Tempat berkumpulnya para pecinta basket dari SMA hingga pekerja muda. Ada latihan bareng tiap Rabu malam!',
                    category: 'Basket',
                    memberCount: 95,
                },
                {
                    id: uuidv4(),
                    name: 'Badminton Squad Banyumas',
                    description: 'Komunitas bulu tangkis yang aktif mengadakan kejuaraan antar komunitas di wilayah Banyumas.',
                    category: 'Badminton',
                    memberCount: 145,
                },
            ];

            for (const community of sampleCommunities) {
                await query(
                    `INSERT INTO communities (id, name, description, category, memberCount, createdAt, updatedAt)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
                    [community.id, community.name, community.description, community.category, community.memberCount, now, now]
                );
            }

            console.log(`✅ ${sampleCommunities.length} sample communities created`);
        } else {
            console.log(`ℹ️  ${existingCommunities[0].count} communities already exist`);
        }

        // Check if sample venues exist
        const [existingVenues] = await query('SELECT COUNT(*) as count FROM venues');

        if (existingVenues[0].count === 0) {
            const now = new Date().toISOString();
            const sampleVenues = [
                {
                    id: uuidv4(),
                    name: 'Gor Satria Purwokerto',
                    type: 'Basket, Futsal',
                    pricePerHour: 120000,
                    address: 'Jl. Prof. Dr. Suharso, Purwokerto',
                    description: 'Gedung olahraga lengkap dengan fasilitas basket dan futsal',
                },
                {
                    id: uuidv4(),
                    name: 'Lapangan Sepak Bola Kedungwuluh',
                    type: 'Sepak Bola',
                    pricePerHour: 200000,
                    address: 'Kedungwuluh, Banyumas',
                    description: 'Lapangan sepak bola standar dengan rumput sintetis',
                },
                {
                    id: uuidv4(),
                    name: 'Badminton Arena Banyumas',
                    type: 'Bulu Tangkis',
                    pricePerHour: 80000,
                    address: 'Jl. Gatot Subroto, Banyumas',
                    description: 'Arena badminton dengan 4 lapangan indoor',
                },
                {
                    id: uuidv4(),
                    name: 'Lapangan Voli Karanglewas',
                    type: 'Voli',
                    pricePerHour: 90000,
                    address: 'Karanglewas, Banyumas',
                    description: 'Lapangan voli outdoor dengan pencahayaan malam',
                },
            ];

            for (const venue of sampleVenues) {
                await query(
                    `INSERT INTO venues (id, name, type, pricePerHour, address, description, createdAt, updatedAt)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                    [venue.id, venue.name, venue.type, venue.pricePerHour, venue.address, venue.description, now, now]
                );
            }

            console.log(`✅ ${sampleVenues.length} sample venues created`);
        } else {
            console.log(`ℹ️  ${existingVenues[0].count} venues already exist`);
        }

        console.log('\n🎉 Database seeding completed!');
    } catch (error) {
        console.error('Seeding failed:', error.message);
        console.error('Full error:', error);
        throw error;
    } finally {
        await pool.end();
    }
};

seedDatabase().catch((err) => {
    console.error('Error details:', err);
    process.exit(1);
});
