const express = require('express');
const eventRegistrationService = require('../services/eventRegistrationService');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

// User routes
// Register for event
router.post('/:eventId/register', authenticate, async (req, res) => {
    try {
        const { eventId } = req.params;
        const userId = req.user.id;
        const registration = await eventRegistrationService.register(eventId, userId);
        res.status(201).json({
            message: 'Berhasil mendaftar event',
            registration
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Get user's registrations
router.get('/my-registrations', authenticate, async (req, res) => {
    try {
        const registrations = await eventRegistrationService.findByUser(req.user.id);
        res.json({ registrations });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Check if user registered for event
router.get('/:eventId/check', authenticate, async (req, res) => {
    try {
        const { eventId } = req.params;
        const isRegistered = await eventRegistrationService.isRegistered(eventId, req.user.id);
        res.json({ isRegistered });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Cancel registration
router.post('/:id/cancel', authenticate, async (req, res) => {
    try {
        const { id } = req.params;
        await eventRegistrationService.cancel(id, req.user.id);
        res.json({ message: 'Pendaftaran berhasil dibatalkan' });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Admin routes
// Get all registrations
router.get('/', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const registrations = await eventRegistrationService.findAll();
        res.json({ registrations });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get registrations by event
router.get('/event/:eventId', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const { eventId } = req.params;
        const registrations = await eventRegistrationService.findByEvent(eventId);
        res.json({ registrations });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Update registration status
router.patch('/:id/status', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const registration = await eventRegistrationService.updateStatus(id, status);
        res.json({ registration });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete registration
router.delete('/:id', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const { id } = req.params;
        await eventRegistrationService.delete(id);
        res.json({ message: 'Pendaftaran berhasil dihapus' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get registration count for event
router.get('/:eventId/count', async (req, res) => {
    try {
        const { eventId } = req.params;
        const count = await eventRegistrationService.getCountByEvent(eventId);
        res.json({ count });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
