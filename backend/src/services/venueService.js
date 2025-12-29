/**
 * Venue Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { getAll, getById, create, update, remove } = require('../config/firebase');

const VENUES_REF = 'venues';

/**
 * Get all venues
 */
const getVenues = async () => {
    const venues = await getAll(VENUES_REF);
    // Sort by createdAt DESC
    venues.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    return venues;
};

/**
 * Get venue by ID
 */
const getVenueById = async (id) => {
    return getById(VENUES_REF, id);
};

/**
 * Create a new venue
 */
const createVenue = async ({ name, type, pricePerHour, address, description, imageUrl }) => {
    const id = uuidv4();
    const now = new Date().toISOString();

    const venueData = {
        name,
        type,
        pricePerHour: Number(pricePerHour),
        address: address || null,
        description: description || null,
        imageUrl: imageUrl || null,
        isAvailable: true,
        createdAt: now,
        updatedAt: now,
    };

    return create(VENUES_REF, id, venueData);
};

/**
 * Update venue
 */
const updateVenue = async (id, updates) => {
    const updateData = { updatedAt: new Date().toISOString() };

    if (updates.name !== undefined) updateData.name = updates.name;
    if (updates.type !== undefined) updateData.type = updates.type;
    if (updates.pricePerHour !== undefined) updateData.pricePerHour = Number(updates.pricePerHour);
    if (updates.address !== undefined) updateData.address = updates.address;
    if (updates.description !== undefined) updateData.description = updates.description;
    if (updates.imageUrl !== undefined) updateData.imageUrl = updates.imageUrl;
    if (updates.isAvailable !== undefined) updateData.isAvailable = updates.isAvailable;

    return update(VENUES_REF, id, updateData);
};

/**
 * Delete venue
 */
const deleteVenue = async (id) => {
    return remove(VENUES_REF, id);
};

module.exports = {
    getVenues,
    getVenueById,
    createVenue,
    updateVenue,
    deleteVenue,
};
