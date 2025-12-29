/**
 * Firebase Admin SDK Configuration
 * Pengganti MySQL database configuration
 */

const admin = require('firebase-admin');
const path = require('path');

// Load service account from file
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT || './sporthub-d04b4-firebase.json';
const serviceAccount = require(path.resolve(__dirname, '../../', serviceAccountPath));

// Initialize Firebase Admin
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: process.env.FIREBASE_DATABASE_URL || 'https://sporthub-d04b4-default-rtdb.asia-southeast1.firebasedatabase.app'
    });
}

// Get Realtime Database reference
const db = admin.database();

/**
 * Helper function to convert Firebase snapshot to array
 */
const snapshotToArray = (snapshot) => {
    const result = [];
    snapshot.forEach((child) => {
        result.push({ id: child.key, ...child.val() });
    });
    return result;
};

/**
 * Helper function to get all data from a reference
 */
const getAll = async (refPath) => {
    const snapshot = await db.ref(refPath).once('value');
    return snapshotToArray(snapshot);
};

/**
 * Helper function to get data by ID
 */
const getById = async (refPath, id) => {
    const snapshot = await db.ref(`${refPath}/${id}`).once('value');
    if (!snapshot.exists()) return null;
    return { id: snapshot.key, ...snapshot.val() };
};

/**
 * Helper function to create data
 */
const create = async (refPath, id, data) => {
    await db.ref(`${refPath}/${id}`).set(data);
    return { id, ...data };
};

/**
 * Helper function to update data
 */
const update = async (refPath, id, data) => {
    await db.ref(`${refPath}/${id}`).update(data);
    return getById(refPath, id);
};

/**
 * Helper function to delete data
 */
const remove = async (refPath, id) => {
    await db.ref(`${refPath}/${id}`).remove();
    return { success: true };
};

/**
 * Helper function to query data with filter
 */
const queryByChild = async (refPath, childKey, value) => {
    const snapshot = await db.ref(refPath)
        .orderByChild(childKey)
        .equalTo(value)
        .once('value');
    return snapshotToArray(snapshot);
};

/**
 * Initialize database (placeholder for compatibility)
 */
const initializeDatabase = async () => {
    try {
        // Test connection
        await db.ref('.info/connected').once('value');
        console.log('✅ Firebase Realtime Database connected');
        return true;
    } catch (error) {
        console.error('❌ Firebase connection failed:', error.message);
        throw error;
    }
};

module.exports = {
    db,
    admin,
    snapshotToArray,
    getAll,
    getById,
    create,
    update,
    remove,
    queryByChild,
    initializeDatabase,
};
