const { v4: uuidv4 } = require('uuid');
const { query, getConnection } = require('../config/database');

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
  const connection = await getConnection();

  try {
    await connection.beginTransaction();

    const orderId = uuidv4();
    const now = new Date();
    // Set expiry to 10 hours from now
    const expiresAt = new Date(now.getTime() + 10 * 60 * 60 * 1000);

    // Insert order
    await connection.execute(
      `INSERT INTO orders (id, userId, totalAmount, status, paymentMethod, shippingAddress, expiresAt, createdAt, updatedAt)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [orderId, userId, totalAmount, status, paymentMethod, shippingAddress || null, expiresAt, now, now]
    );

    // Insert order items
    for (const item of items) {
      await connection.execute(
        `INSERT INTO order_items (orderId, productId, name, price, quantity)
         VALUES (?, ?, ?, ?, ?)`,
        [orderId, item.productId || null, item.name, item.price, item.quantity]
      );
    }

    await connection.commit();

    return {
      id: orderId,
      userId,
      items,
      totalAmount,
      status,
      paymentMethod,
      shippingAddress,
      expiresAt: expiresAt.toISOString(),
      createdAt: now.toISOString(),
      updatedAt: now.toISOString(),
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

/**
 * Get order with its items
 */
const getOrderWithItems = async (orderRow) => {
  if (!orderRow) return null;

  const [items] = await query(
    'SELECT productId, name, price, quantity FROM order_items WHERE orderId = ?',
    [orderRow.id]
  );

  return {
    ...orderRow,
    items,
  };
};

/**
 * Get all orders (admin)
 */
const getOrders = async () => {
  const [rows] = await query(
    'SELECT * FROM orders ORDER BY createdAt DESC'
  );

  const orders = await Promise.all(
    rows.map((row) => getOrderWithItems(row))
  );

  return orders;
};

/**
 * Get orders by user ID
 */
const getOrdersByUser = async (userId) => {
  const [rows] = await query(
    'SELECT * FROM orders WHERE userId = ? ORDER BY createdAt DESC',
    [userId]
  );

  const orders = await Promise.all(
    rows.map((row) => getOrderWithItems(row))
  );

  return orders;
};

/**
 * Get order by ID
 */
const getOrderById = async (orderId) => {
  const [rows] = await query(
    'SELECT * FROM orders WHERE id = ?',
    [orderId]
  );

  if (rows.length === 0) return null;
  return getOrderWithItems(rows[0]);
};

/**
 * Update order status
 */
const updateOrderStatus = async (orderId, status) => {
  const now = new Date().toISOString();

  await query(
    'UPDATE orders SET status = ?, updatedAt = ? WHERE id = ?',
    [status, now, orderId]
  );

  return getOrderById(orderId);
};

/**
 * Upload payment proof
 */
const uploadPaymentProof = async (orderId, paymentProofUrl) => {
  const now = new Date().toISOString();

  await query(
    'UPDATE orders SET paymentProof = ?, status = ?, updatedAt = ? WHERE id = ?',
    [paymentProofUrl, 'paid', now, orderId]
  );

  return getOrderById(orderId);
};

/**
 * Check and expire old pending orders
 */
const expireOldOrders = async () => {
  const now = new Date().toISOString();

  await query(
    `UPDATE orders SET status = 'expired', updatedAt = ? 
     WHERE status = 'pending' AND expiresAt < ?`,
    [now, now]
  );
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
