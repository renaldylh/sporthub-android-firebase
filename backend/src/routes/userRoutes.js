const express = require('express');
const {
    listUsers,
    getUser,
    updateRole,
    updateProfile,
    changeUserPassword,
    deleteUser
} = require('../controllers/userController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

// User routes (authenticated)
router.put('/profile', authenticate, updateProfile);
router.post('/change-password', authenticate, changeUserPassword);

// Admin only routes
router.get('/', authenticate, authorizeRoles('admin'), listUsers);
router.get('/:userId', authenticate, authorizeRoles('admin'), getUser);
router.patch('/:userId/role', authenticate, authorizeRoles('admin'), updateRole);
router.delete('/:userId', authenticate, authorizeRoles('admin'), deleteUser);

module.exports = router;
