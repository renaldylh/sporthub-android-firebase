const express = require('express');
const {
    listBookings,
    listMyBookings,
    getBookingHandler,
    createBookingHandler,
    updateStatusHandler,
    cancelBookingHandler,
    removeBooking,
} = require('../controllers/bookingController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

// User routes (authenticated)
router.get('/me', authenticate, listMyBookings);
router.post('/', authenticate, createBookingHandler);
router.post('/:id/cancel', authenticate, cancelBookingHandler);

// Admin routes
router.get('/', authenticate, authorizeRoles('admin'), listBookings);
router.get('/:id', authenticate, getBookingHandler);
router.patch('/:id/status', authenticate, authorizeRoles('admin'), updateStatusHandler);
router.delete('/:id', authenticate, authorizeRoles('admin'), removeBooking);

module.exports = router;
