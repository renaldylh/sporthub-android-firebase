/**
 * Event Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { getAll, getById, create, update, remove } = require('../config/firebase');

const EVENTS_REF = 'events';

class EventService {
    async findAll() {
        const events = await getAll(EVENTS_REF);
        // Sort by eventDate ASC
        events.sort((a, b) => new Date(a.eventDate) - new Date(b.eventDate));
        return events;
    }

    async findById(id) {
        return getById(EVENTS_REF, id);
    }

    async create(data) {
        const id = uuidv4();
        const { title, description, eventDate, location, imageUrl, isActive = true } = data;
        const now = new Date().toISOString();

        const eventData = {
            title,
            description: description || null,
            eventDate,
            location: location || null,
            imageUrl: imageUrl || null,
            isActive,
            createdAt: now,
            updatedAt: now,
        };

        return create(EVENTS_REF, id, eventData);
    }

    async update(id, data) {
        const { title, description, eventDate, location, imageUrl, isActive } = data;
        const updateData = { updatedAt: new Date().toISOString() };

        if (title !== undefined) updateData.title = title;
        if (description !== undefined) updateData.description = description;
        if (eventDate !== undefined) updateData.eventDate = eventDate;
        if (location !== undefined) updateData.location = location;
        if (imageUrl !== undefined) updateData.imageUrl = imageUrl;
        if (isActive !== undefined) updateData.isActive = isActive;

        return update(EVENTS_REF, id, updateData);
    }

    async delete(id) {
        await remove(EVENTS_REF, id);
        return { deleted: true };
    }
}

module.exports = new EventService();
