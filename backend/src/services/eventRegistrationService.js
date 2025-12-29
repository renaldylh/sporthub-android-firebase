/**
 * Event Registration Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { getAll, getById, create, update, remove, queryByChild, db } = require('../config/firebase');

const REGISTRATIONS_REF = 'eventRegistrations';
const EVENTS_REF = 'events';
const USERS_REF = 'users';

class EventRegistrationService {
    /**
     * Get all registrations (admin)
     */
    async findAll() {
        const registrations = await getAll(REGISTRATIONS_REF);
        // Enrich with event and user data
        return Promise.all(registrations.map(async (reg) => {
            const event = await getById(EVENTS_REF, reg.eventId);
            const user = await getById(USERS_REF, reg.userId);
            return {
                ...reg,
                eventTitle: event?.title || null,
                eventDate: event?.eventDate || null,
                eventLocation: event?.location || null,
                userName: user?.name || null,
                userEmail: user?.email || null,
            };
        }));
    }

    /**
     * Get registrations by event
     */
    async findByEvent(eventId) {
        const registrations = await queryByChild(REGISTRATIONS_REF, 'eventId', eventId);
        return Promise.all(registrations.map(async (reg) => {
            const user = await getById(USERS_REF, reg.userId);
            return {
                ...reg,
                userName: user?.name || null,
                userEmail: user?.email || null,
            };
        }));
    }

    /**
     * Get registrations by user
     */
    async findByUser(userId) {
        const registrations = await queryByChild(REGISTRATIONS_REF, 'userId', userId);
        return Promise.all(registrations.map(async (reg) => {
            const event = await getById(EVENTS_REF, reg.eventId);
            return {
                ...reg,
                eventTitle: event?.title || null,
                eventDate: event?.eventDate || null,
                eventLocation: event?.location || null,
                eventImageUrl: event?.imageUrl || null,
            };
        }));
    }

    /**
     * Check if user is registered for event
     */
    async isRegistered(eventId, userId) {
        const registrations = await queryByChild(REGISTRATIONS_REF, 'eventId', eventId);
        return registrations.some(reg => reg.userId === userId);
    }

    /**
     * Register user for event
     */
    async register(eventId, userId) {
        // Check if already registered
        const isAlreadyRegistered = await this.isRegistered(eventId, userId);
        if (isAlreadyRegistered) {
            throw new Error('Anda sudah terdaftar di event ini');
        }

        const id = uuidv4();
        const now = new Date().toISOString();

        const registrationData = {
            eventId,
            userId,
            status: 'registered', // registered, attended, cancelled
            registeredAt: now,
            updatedAt: now,
        };

        await create(REGISTRATIONS_REF, id, registrationData);
        return { id, ...registrationData };
    }

    /**
     * Cancel registration
     */
    async cancel(id, userId) {
        const registration = await getById(REGISTRATIONS_REF, id);
        if (!registration) {
            throw new Error('Pendaftaran tidak ditemukan');
        }
        if (registration.userId !== userId) {
            throw new Error('Tidak memiliki akses untuk membatalkan pendaftaran ini');
        }

        await update(REGISTRATIONS_REF, id, {
            status: 'cancelled',
            updatedAt: new Date().toISOString()
        });
        return { success: true };
    }

    /**
     * Update registration status (admin)
     */
    async updateStatus(id, status) {
        await update(REGISTRATIONS_REF, id, {
            status,
            updatedAt: new Date().toISOString(),
        });
        return getById(REGISTRATIONS_REF, id);
    }

    /**
     * Delete registration (admin)
     */
    async delete(id) {
        await remove(REGISTRATIONS_REF, id);
        return { deleted: true };
    }

    /**
     * Get registration count for event
     */
    async getCountByEvent(eventId) {
        const registrations = await queryByChild(REGISTRATIONS_REF, 'eventId', eventId);
        return registrations.filter(r => r.status === 'registered').length;
    }
}

module.exports = new EventRegistrationService();
