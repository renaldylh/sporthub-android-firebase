const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/database');

/**
 * Remove sensitive data from user object
 */
const sanitizeUser = (user) => {
  if (!user) return null;
  const { passwordHash, ...safeData } = user;
  return safeData;
};

/**
 * Create a new user
 */
const createUser = async ({ email, password, name, role = 'user' }) => {
  // Check if email already exists
  const [existing] = await query(
    'SELECT id FROM users WHERE email = ?',
    [email]
  );

  if (existing.length > 0) {
    throw new Error('Email already registered');
  }

  const id = uuidv4();
  const passwordHash = await bcrypt.hash(password, 10);
  const createdAt = new Date().toISOString();

  await query(
    `INSERT INTO users (id, email, name, role, passwordHash, createdAt)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [id, email, name, role, passwordHash, createdAt]
  );

  return sanitizeUser({ id, email, name, role, createdAt });
};

/**
 * Get user by email (includes passwordHash for authentication)
 */
const getUserByEmail = async (email) => {
  const [rows] = await query(
    'SELECT * FROM users WHERE email = ?',
    [email]
  );

  if (rows.length === 0) return null;
  return rows[0];
};

/**
 * Get all users (sanitized)
 */
const getUsers = async () => {
  const [rows] = await query('SELECT * FROM users ORDER BY createdAt DESC');
  return rows.map(sanitizeUser);
};

/**
 * Get user by ID (sanitized)
 */
const getUserById = async (userId) => {
  const [rows] = await query(
    'SELECT * FROM users WHERE id = ?',
    [userId]
  );

  if (rows.length === 0) return null;
  return sanitizeUser(rows[0]);
};

/**
 * Update user role
 */
const updateUserRole = async (userId, role) => {
  await query(
    'UPDATE users SET role = ? WHERE id = ?',
    [role, userId]
  );

  return getUserById(userId);
};

/**
 * Update user profile (name only for now)
 */
const updateUserProfile = async (userId, updates) => {
  const { name } = updates;

  if (name) {
    await query(
      'UPDATE users SET name = ? WHERE id = ?',
      [name, userId]
    );
  }

  return getUserById(userId);
};

/**
 * Change user password
 */
const changePassword = async (userId, currentPassword, newPassword) => {
  // Get user with password hash
  const [rows] = await query(
    'SELECT * FROM users WHERE id = ?',
    [userId]
  );

  if (rows.length === 0) {
    throw new Error('User not found');
  }

  const user = rows[0];

  // Verify current password
  const isValid = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!isValid) {
    throw new Error('Current password is incorrect');
  }

  // Hash new password
  const newPasswordHash = await bcrypt.hash(newPassword, 10);

  // Update password
  await query(
    'UPDATE users SET passwordHash = ? WHERE id = ?',
    [newPasswordHash, userId]
  );

  return true;
};

/**
 * Delete user by ID
 */
const deleteUserById = async (userId) => {
  await query('DELETE FROM users WHERE id = ?', [userId]);
  return { success: true };
};

module.exports = {
  createUser,
  getUserByEmail,
  getUsers,
  getUserById,
  updateUserRole,
  updateUserProfile,
  changePassword,
  deleteUserById,
};
