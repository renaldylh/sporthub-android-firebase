/**
 * User Service - Firebase Realtime Database
 */

const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { db, getAll, getById, create, update, remove, queryByChild } = require('../config/firebase');

const USERS_REF = 'users';

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
  const existing = await queryByChild(USERS_REF, 'email', email);
  if (existing.length > 0) {
    throw new Error('Email already registered');
  }

  const id = uuidv4();
  const passwordHash = await bcrypt.hash(password, 10);
  const createdAt = new Date().toISOString();

  const userData = {
    email,
    name,
    role,
    passwordHash,
    createdAt,
  };

  await create(USERS_REF, id, userData);
  return sanitizeUser({ id, ...userData });
};

/**
 * Get user by email (includes passwordHash for authentication)
 */
const getUserByEmail = async (email) => {
  const users = await queryByChild(USERS_REF, 'email', email);
  if (users.length === 0) return null;
  return users[0];
};

/**
 * Get all users (sanitized)
 */
const getUsers = async () => {
  const users = await getAll(USERS_REF);
  // Sort by createdAt DESC
  users.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return users.map(sanitizeUser);
};

/**
 * Get user by ID (sanitized)
 */
const getUserById = async (userId) => {
  const user = await getById(USERS_REF, userId);
  return sanitizeUser(user);
};

/**
 * Update user role
 */
const updateUserRole = async (userId, role) => {
  await update(USERS_REF, userId, { role });
  return getUserById(userId);
};

/**
 * Update user profile (name only for now)
 */
const updateUserProfile = async (userId, updates) => {
  const { name } = updates;
  if (name) {
    await update(USERS_REF, userId, { name });
  }
  return getUserById(userId);
};

/**
 * Change user password
 */
const changePassword = async (userId, currentPassword, newPassword) => {
  // Get user with password hash
  const user = await getById(USERS_REF, userId);
  if (!user) {
    throw new Error('User not found');
  }

  // Verify current password
  const isValid = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!isValid) {
    throw new Error('Current password is incorrect');
  }

  // Hash new password and update
  const newPasswordHash = await bcrypt.hash(newPassword, 10);
  await update(USERS_REF, userId, { passwordHash: newPasswordHash });

  return true;
};

/**
 * Delete user by ID
 */
const deleteUserById = async (userId) => {
  return remove(USERS_REF, userId);
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
