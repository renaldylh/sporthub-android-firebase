const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/database');

/**
 * Get all bookings (admin)
 */
const getBookings = async () => {
    const [rows] = await query(`
    SELECT b.*, v.name as venueName, v.type as venueType, u.name as userName, u.email as userEmail
    FROM bookings b
    LEFT JOIN venues v ON b.venueId = v.id
    LEFT JOIN users u ON b.userId = u.id
    ORDER BY b.createdAt DESC
  `);
    return rows;
};

/**
 * Get bookings by user
 */
const getBookingsByUser = async (userId) => {
    const [rows] = await query(`
    SELECT b.*, v.name as venueName, v.type as venueType
    FROM bookings b
    LEFT JOIN venues v ON b.venueId = v.id
    WHERE b.userId = ?
    ORDER BY b.createdAt DESC
  `, [userId]);
    return rows;
};

/**
 * Get booking by ID
 */
const getBookingById = async (id) => {
    const [rows] = await query(`
    SELECT b.*, v.name as venueName, v.type as venueType, v.address as venueAddress,
           u.name as userName, u.email as userEmail
    FROM bookings b
    LEFT JOIN venues v ON b.venueId = v.id
    LEFT JOIN users u ON b.userId = u.id
    WHERE b.id = ?
  `, [id]);
    return rows.length > 0 ? rows[0] : null;
};

/**
 * Create a new booking
 */
const createBooking = async ({ venueId, userId, bookingDate, startTime, endTime, totalPrice, notes }) => {
    const id = uuidv4();
    const now = new Date().toISOString();

    await query(
        `INSERT INTO bookings (id, venueId, userId, bookingDate, startTime, endTime, totalPrice, notes, createdAt, updatedAt)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [id, venueId, userId, bookingDate, startTime, endTime, totalPrice, notes, now, now]
    );

    return getBookingById(id);
};

/**
 * Update booking status (approve/reject)
 */
const updateBookingStatus = async (id, status, adminNotes = null) => {
    const updates = ['status = ?'];
    const values = [status];

    if (adminNotes) {
        updates.push('adminNotes = ?');
        values.push(adminNotes);
    }

    values.push(id);
    await query(`UPDATE bookings SET ${updates.join(', ')} WHERE id = ?`, values);

    return getBookingById(id);
};

/**
 * Cancel booking (by user)
 */
const cancelBooking = async (id, userId) => {
    const booking = await getBookingById(id);

    if (!booking) {
        throw new Error('Booking not found');
    }

    if (booking.userId !== userId) {
        throw new Error('Not authorized to cancel this booking');
    }

    if (booking.status !== 'pending') {
        throw new Error('Only pending bookings can be cancelled');
    }

    await query('UPDATE bookings SET status = ? WHERE id = ?', ['cancelled', id]);
    return getBookingById(id);
};

/**
 * Delete booking (admin)
 */
const deleteBooking = async (id) => {
    await query('DELETE FROM bookings WHERE id = ?', [id]);
    return { success: true };
};

/**
 * Get pending bookings count
 */
const getPendingBookingsCount = async () => {
    const [rows] = await query("SELECT COUNT(*) as count FROM bookings WHERE status = 'pending'");
    return rows[0].count;
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
