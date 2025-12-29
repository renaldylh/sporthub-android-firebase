/**
 * Firebase Seed Script
 * Membuat akun admin dan user untuk testing
 * 
 * Run: node src/scripts/firebase-seed.js
 */

require('dotenv').config();

const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { db, create } = require('../config/firebase');

const seedUsers = async () => {
    console.log('🌱 Seeding users to Firebase...\n');

    const now = new Date().toISOString();

    // Admin user - password: admin123
    const adminPasswordHash = await bcrypt.hash('admin123', 10);
    const adminId = uuidv4();
    const adminUser = {
        email: 'admin@sporthub.com',
        name: 'Admin SportHub',
        role: 'admin',
        passwordHash: adminPasswordHash,
        createdAt: now,
    };

    // Regular user - password: user123
    const userPasswordHash = await bcrypt.hash('user123', 10);
    const userId = uuidv4();
    const regularUser = {
        email: 'user@sporthub.com',
        name: 'User SportHub',
        role: 'user',
        passwordHash: userPasswordHash,
        createdAt: now,
    };

    try {
        await create('users', adminId, adminUser);
        console.log('✅ Admin created:', adminUser.email);

        await create('users', userId, regularUser);
        console.log('✅ User created:', regularUser.email);

        console.log('\n📋 Login Credentials:');
        console.log('─'.repeat(40));
        console.log('ADMIN:');
        console.log('  Email   : admin@sporthub.com');
        console.log('  Password: admin123');
        console.log('');
        console.log('USER:');
        console.log('  Email   : user@sporthub.com');
        console.log('  Password: user123');
        console.log('─'.repeat(40));
    } catch (error) {
        console.error('❌ Seeding failed:', error.message);
    }
};

const seedProducts = async () => {
    console.log('\n🌱 Seeding sample products...\n');
    const now = new Date().toISOString();

    const products = [
        {
            name: 'Bola Futsal Mikasa',
            price: 250000,
            stock: 15,
            description: 'Bola futsal original Mikasa, cocok untuk pertandingan resmi',
            imageUrl: 'https://i.ibb.co/placeholder/bola-futsal.jpg',
            createdAt: now,
            updatedAt: now,
        },
        {
            name: 'Jersey Bola Nike',
            price: 450000,
            stock: 25,
            description: 'Jersey bola Nike Dri-FIT, nyaman dan breathable',
            imageUrl: 'https://i.ibb.co/placeholder/jersey-nike.jpg',
            createdAt: now,
            updatedAt: now,
        },
        {
            name: 'Sepatu Badminton Yonex',
            price: 850000,
            stock: 10,
            description: 'Sepatu badminton Yonex Power Cushion, grip maksimal',
            imageUrl: 'https://i.ibb.co/placeholder/sepatu-yonex.jpg',
            createdAt: now,
            updatedAt: now,
        },
    ];

    for (const product of products) {
        const id = uuidv4();
        await create('products', id, product);
        console.log('✅ Product:', product.name);
    }
};

const seedVenues = async () => {
    console.log('\n🌱 Seeding sample venues...\n');
    const now = new Date().toISOString();

    const venues = [
        {
            name: 'Lapangan Futsal Purwokerto',
            type: 'futsal',
            pricePerHour: 100000,
            address: 'Jl. Jenderal Soedirman No. 123, Purwokerto',
            description: 'Lapangan futsal indoor dengan rumput sintetis berkualitas',
            imageUrl: 'https://i.ibb.co/placeholder/futsal.jpg',
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
        },
        {
            name: 'GOR Satria Purwokerto',
            type: 'badminton',
            pricePerHour: 75000,
            address: 'Jl. Komisaris Bambang Suprapto, Purwokerto',
            description: 'Gedung olahraga dengan 4 lapangan badminton standar BWF',
            imageUrl: 'https://i.ibb.co/placeholder/badminton.jpg',
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
        },
    ];

    for (const venue of venues) {
        const id = uuidv4();
        await create('venues', id, venue);
        console.log('✅ Venue:', venue.name);
    }
};

const seedCommunities = async () => {
    console.log('\n🌱 Seeding sample communities...\n');
    const now = new Date().toISOString();

    const communities = [
        {
            name: 'Komunitas Futsal Banyumas',
            description: 'Komunitas para pecinta futsal di Banyumas',
            category: 'futsal',
            memberCount: 150,
            imageUrl: 'https://i.ibb.co/placeholder/futsal-community.jpg',
            isActive: true,
            createdAt: now,
            updatedAt: now,
        },
        {
            name: 'Banyumas Runners Club',
            description: 'Komunitas lari dan jogging untuk kesehatan',
            category: 'running',
            memberCount: 200,
            imageUrl: 'https://i.ibb.co/placeholder/running-club.jpg',
            isActive: true,
            createdAt: now,
            updatedAt: now,
        },
    ];

    for (const community of communities) {
        const id = uuidv4();
        await create('communities', id, community);
        console.log('✅ Community:', community.name);
    }
};

const runSeeding = async () => {
    console.log('🔥 Firebase Seeding Started\n');
    console.log('='.repeat(50));

    try {
        await seedUsers();
        await seedProducts();
        await seedVenues();
        await seedCommunities();

        console.log('\n' + '='.repeat(50));
        console.log('🎉 Seeding completed successfully!');
        console.log('\nAnda sekarang bisa login dengan:');
        console.log('  Admin: admin@sporthub.com / admin123');
        console.log('  User : user@sporthub.com / user123');
        process.exit(0);
    } catch (error) {
        console.error('\n❌ Seeding failed:', error);
        process.exit(1);
    }
};

runSeeding();
