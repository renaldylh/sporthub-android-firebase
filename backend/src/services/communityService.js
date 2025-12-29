/**
 * Community Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { getAll, getById, create, update, remove } = require('../config/firebase');

const COMMUNITIES_REF = 'communities';

/**
 * Get all communities
 */
const getCommunities = async () => {
    const communities = await getAll(COMMUNITIES_REF);
    // Sort by createdAt DESC
    communities.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    return communities;
};

/**
 * Get community by ID
 */
const getCommunityById = async (id) => {
    return getById(COMMUNITIES_REF, id);
};

/**
 * Create a new community
 */
const createCommunity = async ({ name, description, category, imageUrl }) => {
    const id = uuidv4();
    const now = new Date().toISOString();

    const communityData = {
        name,
        description: description || null,
        category: category || null,
        imageUrl: imageUrl || null,
        memberCount: 0,
        isActive: true,
        createdAt: now,
        updatedAt: now,
    };

    return create(COMMUNITIES_REF, id, communityData);
};

/**
 * Update community
 */
const updateCommunity = async (id, updates) => {
    const updateData = { updatedAt: new Date().toISOString() };

    if (updates.name !== undefined) updateData.name = updates.name;
    if (updates.description !== undefined) updateData.description = updates.description;
    if (updates.category !== undefined) updateData.category = updates.category;
    if (updates.imageUrl !== undefined) updateData.imageUrl = updates.imageUrl;
    if (updates.memberCount !== undefined) updateData.memberCount = Number(updates.memberCount);
    if (updates.isActive !== undefined) updateData.isActive = updates.isActive;

    return update(COMMUNITIES_REF, id, updateData);
};

/**
 * Delete community
 */
const deleteCommunity = async (id) => {
    return remove(COMMUNITIES_REF, id);
};

module.exports = {
    getCommunities,
    getCommunityById,
    createCommunity,
    updateCommunity,
    deleteCommunity,
};
