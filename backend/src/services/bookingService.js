/**
 * Booking Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { getAll, getById, create, update, remove, queryByChild } = require('../config/firebase');

const BOOKINGS_REF = 'bookings';
const VENUES_REF = 'venues';
const USERS_REF = 'users';

/**
 * Enrich booking with venue and user data
 */
const enrichBooking = async (booking) => {
    if (!booking) return null;

    // Get venue data
    const venue = await getById(VENUES_REF, booking.venueId);
    // Get user data
    const user = await getById(USERS_REF, booking.userId);

    return {
        ...booking,
        venueName: venue?.name || null,
        venueType: venue?.type || null,
        venueAddress: venue?.address || null,
        userName: user?.name || null,
        userEmail: user?.email || null,
    };
};

/**
 * Get all bookings (admin)
 */
const getBookings = async () => {
    const bookings = await getAll(BOOKINGS_REF);
    // Sort by createdAt DESC
    bookings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    // Enrich with venue and user data
    return Promise.all(bookings.map(enrichBooking));
};

/**
 * Get bookings by user
 */
const getBookingsByUser = async (userId) => {
    const bookings = await queryByChild(BOOKINGS_REF, 'userId', userId);
    // Sort by createdAt DESC
    bookings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    // Enrich with venue data only
    return Promise.all(bookings.map(async (booking) => {
        const venue = await getById(VENUES_REF, booking.venueId);
        return {
            ...booking,
            venueName: venue?.name || null,
            venueType: venue?.type || null,
        };
    }));
};

/**
 * Get booking by ID
 */
const getBookingById = async (id) => {
    const booking = await getById(BOOKINGS_REF, id);
    return enrichBooking(booking);
};

/**
 * Create a new booking
 */
const createBooking = async ({ venueId, userId, bookingDate, startTime, endTime, totalPrice, notes }) => {
    const id = uuidv4();
    const now = new Date().toISOString();

    const bookingData = {
        venueId,
        userId,
        bookingDate,
        startTime,
        endTime,
        totalPrice: Number(totalPrice),
        status: 'pending',
        notes: notes || null,
        adminNotes: null,
        createdAt: now,
        updatedAt: now,
    };

    await create(BOOKINGS_REF, id, bookingData);
    return getBookingById(id);
};

/**
 * Update booking status (approve/reject)
 */
const updateBookingStatus = async (id, status, adminNotes = null) => {
    const updateData = {
        status,
        updatedAt: new Date().toISOString(),
    };

    if (adminNotes) {
        updateData.adminNotes = adminNotes;
    }

    await update(BOOKINGS_REF, id, updateData);
    return getBookingById(id);
};

/**
 * Cancel booking (by user)
 */
const cancelBooking = async (id, userId) => {
    const booking = await getById(BOOKINGS_REF, id);

    if (!booking) {
        throw new Error('Booking not found');
    }

    if (booking.userId !== userId) {
        throw new Error('Not authorized to cancel this booking');
    }

    if (booking.status !== 'pending') {
        throw new Error('Only pending bookings can be cancelled');
    }

    await update(BOOKINGS_REF, id, { status: 'cancelled', updatedAt: new Date().toISOString() });
    return getBookingById(id);
};

/**
 * Delete booking (admin)
 */
const deleteBooking = async (id) => {
    return remove(BOOKINGS_REF, id);
};

/**
 * Get pending bookings count
 */
const getPendingBookingsCount = async () => {
    const bookings = await queryByChild(BOOKINGS_REF, 'status', 'pending');
    return bookings.length;
};

module.exports = {
    getBookings,
    getBookingsByUser,
    getBookingById,
    createBooking,
    updateBookingStatus,
    cancelBooking,
    deleteBooking,
    getPendingBookingsCount,
};
