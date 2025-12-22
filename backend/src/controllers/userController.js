const bcrypt = require('bcryptjs');
const {
  getUsers,
  getUserById,
  updateUserRole,
  updateUserProfile,
  changePassword,
} = require('../services/userService');

const listUsers = async (_req, res) => {
  try {
    const users = await getUsers();
    return res.json({ users });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getUser = async (req, res) => {
  try {
    const user = await getUserById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    return res.json({ user });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const updateRole = async (req, res) => {
  try {
    const { role } = req.body;
    if (!role) {
      return res.status(400).json({ message: 'Role is required' });
    }

    const user = await updateUserRole(req.params.userId, role);
    return res.json({ user });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// Update own profile
const updateProfile = async (req, res) => {
  try {
    const { name } = req.body;
    const userId = req.user.id;

    if (!name || name.trim() === '') {
      return res.status(400).json({ message: 'Name is required' });
    }

    const user = await updateUserProfile(userId, { name: name.trim() });
    return res.json({ user });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// Change own password
const changeUserPassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user.id;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: 'Current password and new password are required' });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ message: 'New password must be at least 6 characters' });
    }

    await changePassword(userId, currentPassword, newPassword);
    return res.json({ message: 'Password changed successfully' });
  } catch (error) {
    return res.status(400).json({ message: error.message });
  }
};

// Delete user (admin only)
const deleteUser = async (req, res) => {
  try {
    const { deleteUserById } = require('../services/userService');
    const userId = req.params.userId;

    // Prevent admin from deleting themselves
    if (userId === req.user.id) {
      return res.status(400).json({ message: 'Cannot delete your own account' });
    }

    await deleteUserById(userId);
    return res.json({ message: 'User deleted successfully' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

module.exports = {
  listUsers,
  getUser,
  updateRole,
  updateProfile,
  changeUserPassword,
  deleteUser,
};
