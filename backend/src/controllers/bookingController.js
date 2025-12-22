const {
    getBookings,
    getBookingsByUser,
    getBookingById,
    createBooking,
    updateBookingStatus,
    cancelBooking,
    deleteBooking,
} = require('../services/bookingService');

// Get all bookings (admin)
const listBookings = async (_req, res) => {
    try {
        const bookings = await getBookings();
        return res.json({ bookings });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Get user's bookings
const listMyBookings = async (req, res) => {
    try {
        const bookings = await getBookingsByUser(req.user.id);
        return res.json({ bookings });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Get booking by ID
const getBookingHandler = async (req, res) => {
    try {
        const booking = await getBookingById(req.params.id);
        if (!booking) {
            return res.status(404).json({ message: 'Booking not found' });
        }
        return res.json({ booking });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Create booking (user)
const createBookingHandler = async (req, res) => {
    try {
        const { venueId, bookingDate, startTime, endTime, totalPrice, notes } = req.body;
        const userId = req.user.id;

        if (!venueId || !bookingDate || !startTime || !endTime || totalPrice == null) {
            return res.status(400).json({
                message: 'venueId, bookingDate, startTime, endTime, and totalPrice are required'
            });
        }

        const booking = await createBooking({
            venueId, userId, bookingDate, startTime, endTime, totalPrice, notes
        });
        return res.status(201).json({ booking });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Update booking status (admin - approve/reject)
const updateStatusHandler = async (req, res) => {
    try {
        const { status, adminNotes } = req.body;

        if (!status || !['pending', 'approved', 'rejected', 'cancelled', 'completed'].includes(status)) {
            return res.status(400).json({
                message: 'Valid status is required (pending, approved, rejected, cancelled, completed)'
            });
        }

        const booking = await updateBookingStatus(req.params.id, status, adminNotes);
        if (!booking) {
            return res.status(404).json({ message: 'Booking not found' });
        }
        return res.json({ booking });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

// Cancel booking (user)
const cancelBookingHandler = async (req, res) => {
    try {
        const booking = await cancelBooking(req.params.id, req.user.id);
        return res.json({ booking });
    } catch (error) {
        return res.status(400).json({ message: error.message });
    }
};

// Delete booking (admin)
const removeBooking = async (req, res) => {
    try {
        await deleteBooking(req.params.id);
        return res.json({ success: true });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

module.exports = {
    listBookings,
    listMyBookings,
    getBookingHandler,
    createBookingHandler,
    updateStatusHandler,
    cancelBookingHandler,
    removeBooking,
};
