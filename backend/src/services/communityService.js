const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/database');

/**
 * Get all communities
 */
const getCommunities = async () => {
    const [rows] = await query('SELECT * FROM communities ORDER BY createdAt DESC');
    return rows;
};

/**
 * Get community by ID
 */
const getCommunityById = async (id) => {
    const [rows] = await query('SELECT * FROM communities WHERE id = ?', [id]);
    return rows.length > 0 ? rows[0] : null;
};

/**
 * Create a new community
 */
const createCommunity = async ({ name, description, category, imageUrl }) => {
    const id = uuidv4();
    const now = new Date().toISOString();

    await query(
        `INSERT INTO communities (id, name, description, category, imageUrl, createdAt, updatedAt)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [id, name, description, category, imageUrl, now, now]
    );

    return getCommunityById(id);
};

/**
 * Update community
 */
const updateCommunity = async (id, updates) => {
    const fields = [];
    const values = [];

    if (updates.name !== undefined) {
        fields.push('name = ?');
        values.push(updates.name);
    }
    if (updates.description !== undefined) {
        fields.push('description = ?');
        values.push(updates.description);
    }
    if (updates.category !== undefined) {
        fields.push('category = ?');
        values.push(updates.category);
    }
    if (updates.imageUrl !== undefined) {
        fields.push('imageUrl = ?');
        values.push(updates.imageUrl);
    }
    if (updates.memberCount !== undefined) {
        fields.push('memberCount = ?');
        values.push(updates.memberCount);
    }
    if (updates.isActive !== undefined) {
        fields.push('isActive = ?');
        values.push(updates.isActive);
    }

    if (fields.length === 0) return getCommunityById(id);

    values.push(id);
    await query(`UPDATE communities SET ${fields.join(', ')} WHERE id = ?`, values);

    return getCommunityById(id);
};

/**
 * Delete community
 */
const deleteCommunity = async (id) => {
    await query('DELETE FROM communities WHERE id = ?', [id]);
    return { success: true };
};

module.exports = {
    getCommunities,
    getCommunityById,
    createCommunity,
    updateCommunity,
    deleteCommunity,
};
