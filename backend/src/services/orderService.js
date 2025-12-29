/**
 * Order Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { db, getAll, getById, create, update, queryByChild } = require('../config/firebase');

const ORDERS_REF = 'orders';

/**
 * Create a new order with items (10 hour expiry for payment)
 */
const createOrder = async ({
  userId,
  items,
  totalAmount,
  shippingAddress,
  status = 'pending',
  paymentMethod = 'manual-transfer',
}) => {
  const orderId = uuidv4();
  const now = new Date();
  // Set expiry to 10 hours from now
  const expiresAt = new Date(now.getTime() + 10 * 60 * 60 * 1000);

  const orderData = {
    userId,
    items, // Items stored as nested array
    totalAmount: Number(totalAmount),
    status,
    paymentMethod,
    shippingAddress: shippingAddress || null,
    paymentProof: null,
    expiresAt: expiresAt.toISOString(),
    createdAt: now.toISOString(),
    updatedAt: now.toISOString(),
  };

  return create(ORDERS_REF, orderId, orderData);
};

/**
 * Get all orders (admin)
 */
const getOrders = async () => {
  const orders = await getAll(ORDERS_REF);
  // Sort by createdAt DESC
  orders.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return orders;
};

/**
 * Get orders by user ID
 */
const getOrdersByUser = async (userId) => {
  const orders = await queryByChild(ORDERS_REF, 'userId', userId);
  // Sort by createdAt DESC
  orders.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return orders;
};

/**
 * Get order by ID
 */
const getOrderById = async (orderId) => {
  return getById(ORDERS_REF, orderId);
};

/**
 * Update order status
 */
const updateOrderStatus = async (orderId, status) => {
  const now = new Date().toISOString();
  return update(ORDERS_REF, orderId, { status, updatedAt: now });
};

/**
 * Upload payment proof
 */
const uploadPaymentProof = async (orderId, paymentProofUrl) => {
  const now = new Date().toISOString();
  return update(ORDERS_REF, orderId, {
    paymentProof: paymentProofUrl,
    status: 'paid',
    updatedAt: now,
  });
};

/**
 * Check and expire old pending orders
 */
const expireOldOrders = async () => {
  const now = new Date().toISOString();
  const orders = await getAll(ORDERS_REF);

  const expiredOrders = orders.filter(
    (order) => order.status === 'pending' && order.expiresAt < now
  );

  for (const order of expiredOrders) {
    await update(ORDERS_REF, order.id, { status: 'expired', updatedAt: now });
  }

  return expiredOrders.length;
};

module.exports = {
  createOrder,
  getOrders,
  getOrdersByUser,
  getOrderById,
  updateOrderStatus,
  uploadPaymentProof,
  expireOldOrders,
};
