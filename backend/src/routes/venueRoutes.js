const express = require('express');
const {
    listVenues,
    getVenueHandler,
    createVenueHandler,
    updateVenueHandler,
    removeVenue,
} = require('../controllers/venueController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

// Public routes
router.get('/', listVenues);
router.get('/:id', getVenueHandler);

// Admin only routes
router.post('/', authenticate, authorizeRoles('admin'), createVenueHandler);
router.put('/:id', authenticate, authorizeRoles('admin'), updateVenueHandler);
router.delete('/:id', authenticate, authorizeRoles('admin'), removeVenue);

module.exports = router;
