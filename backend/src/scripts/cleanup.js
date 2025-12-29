/**
 * Cleanup Script - Remove all existing data and reseed with fresh data
 */

const { db } = require('../config/firebase');

const cleanupAndReseed = async () => {
    console.log('🧹 Cleaning up Firebase database...\n');

    const collectionsToClean = ['venues', 'products', 'communities', 'events', 'eventRegistrations', 'communityMemberships', 'bookings'];

    for (const collection of collectionsToClean) {
        try {
            const ref = db.ref(collection);
            await ref.remove();
            console.log(`✅ Cleaned: ${collection}`);
        } catch (error) {
            console.error(`❌ Error cleaning ${collection}:`, error.message);
        }
    }

    console.log('\n🎉 Cleanup complete! Now run: node src/scripts/firebase-seed.js');
};

cleanupAndReseed();
