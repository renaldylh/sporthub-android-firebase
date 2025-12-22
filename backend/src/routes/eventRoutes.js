const express = require('express');
const router = express.Router();
const eventController = require('../controllers/eventController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

// Public routes
router.get('/', eventController.getAll);
router.get('/:id', eventController.getById);

// Admin only routes
router.post('/', authenticate, authorizeRoles('admin'), eventController.create);
router.put('/:id', authenticate, authorizeRoles('admin'), eventController.update);
router.delete('/:id', authenticate, authorizeRoles('admin'), eventController.delete);

module.exports = router;
