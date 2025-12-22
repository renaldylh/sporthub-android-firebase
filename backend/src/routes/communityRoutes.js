const express = require('express');
const {
    listCommunities,
    getCommunity,
    createCommunityHandler,
    updateCommunityHandler,
    removeCommunity,
} = require('../controllers/communityController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

// Public routes
router.get('/', listCommunities);
router.get('/:id', getCommunity);

// Admin only routes
router.post('/', authenticate, authorizeRoles('admin'), createCommunityHandler);
router.put('/:id', authenticate, authorizeRoles('admin'), updateCommunityHandler);
router.delete('/:id', authenticate, authorizeRoles('admin'), removeCommunity);

module.exports = router;
