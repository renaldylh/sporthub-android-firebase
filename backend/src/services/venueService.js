const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/database');

/**
 * Get all venues
 */
const getVenues = async () => {
    const [rows] = await query('SELECT * FROM venues ORDER BY createdAt DESC');
    return rows;
};

/**
 * Get venue by ID
 */
const getVenueById = async (id) => {
    const [rows] = await query('SELECT * FROM venues WHERE id = ?', [id]);
    return rows.length > 0 ? rows[0] : null;
};

/**
 * Create a new venue
 */
const createVenue = async ({ name, type, pricePerHour, address, description, imageUrl }) => {
    const id = uuidv4();
    const now = new Date().toISOString();

    await query(
        `INSERT INTO venues (id, name, type, pricePerHour, address, description, imageUrl, createdAt, updatedAt)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [id, name, type, pricePerHour, address, description, imageUrl, now, now]
    );

    return getVenueById(id);
};

/**
 * Update venue
 */
const updateVenue = async (id, updates) => {
    const fields = [];
    const values = [];

    if (updates.name !== undefined) {
        fields.push('name = ?');
        values.push(updates.name);
    }
    if (updates.type !== undefined) {
        fields.push('type = ?');
        values.push(updates.type);
    }
    if (updates.pricePerHour !== undefined) {
        fields.push('pricePerHour = ?');
        values.push(updates.pricePerHour);
    }
    if (updates.address !== undefined) {
        fields.push('address = ?');
        values.push(updates.address);
    }
    if (updates.description !== undefined) {
        fields.push('description = ?');
        values.push(updates.description);
    }
    if (updates.imageUrl !== undefined) {
        fields.push('imageUrl = ?');
        values.push(updates.imageUrl);
    }
    if (updates.isAvailable !== undefined) {
        fields.push('isAvailable = ?');
        values.push(updates.isAvailable);
    }

    if (fields.length === 0) return getVenueById(id);

    values.push(id);
    await query(`UPDATE venues SET ${fields.join(', ')} WHERE id = ?`, values);

    return getVenueById(id);
};

/**
 * Delete venue
 */
const deleteVenue = async (id) => {
    await query('DELETE FROM venues WHERE id = ?', [id]);
    return { success: true };
};

module.exports = {
    getVenues,
    getVenueById,
    createVenue,
    updateVenue,
    deleteVenue,
};
