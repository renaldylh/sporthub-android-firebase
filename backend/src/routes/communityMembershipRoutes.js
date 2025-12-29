const express = require('express');
const communityMembershipService = require('../services/communityMembershipService');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

// User routes
// Join community
router.post('/:communityId/join', authenticate, async (req, res) => {
    try {
        const { communityId } = req.params;
        const userId = req.user.id;
        const membership = await communityMembershipService.join(communityId, userId);
        res.status(201).json({
            message: 'Berhasil bergabung dengan komunitas',
            membership
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Get user's communities
router.get('/my-communities', authenticate, async (req, res) => {
    try {
        const memberships = await communityMembershipService.findByUser(req.user.id);
        res.json({ memberships });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Check if user is member
router.get('/:communityId/check', authenticate, async (req, res) => {
    try {
        const { communityId } = req.params;
        const isMember = await communityMembershipService.isMember(communityId, req.user.id);
        res.json({ isMember });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Leave community
router.post('/:id/leave', authenticate, async (req, res) => {
    try {
        const { id } = req.params;
        await communityMembershipService.leave(id, req.user.id);
        res.json({ message: 'Berhasil keluar dari komunitas' });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Admin routes
// Get all memberships
router.get('/', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const memberships = await communityMembershipService.findAll();
        res.json({ memberships });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get members by community
router.get('/community/:communityId', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const { communityId } = req.params;
        const memberships = await communityMembershipService.findByCommunity(communityId);
        res.json({ memberships });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Update membership role
router.patch('/:id/role', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;
        const membership = await communityMembershipService.updateRole(id, role);
        res.json({ membership });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
});

// Delete membership
router.delete('/:id', authenticate, authorizeRoles('admin'), async (req, res) => {
    try {
        const { id } = req.params;
        await communityMembershipService.delete(id);
        res.json({ message: 'Keanggotaan berhasil dihapus' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Get member count for community
router.get('/:communityId/count', async (req, res) => {
    try {
        const { communityId } = req.params;
        const count = await communityMembershipService.getCountByCommunity(communityId);
        res.json({ count });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
