const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/database');

/**
 * Get all products
 */
const getProducts = async () => {
  const [rows] = await query(
    'SELECT * FROM products ORDER BY createdAt DESC'
  );
  return rows;
};

/**
 * Get product by ID
 */
const getProductById = async (productId) => {
  const [rows] = await query(
    'SELECT * FROM products WHERE id = ?',
    [productId]
  );

  if (rows.length === 0) return null;
  return rows[0];
};

/**
 * Create a new product
 */
const createProduct = async ({ name, price, stock, description, imageUrl }) => {
  const id = uuidv4();
  const now = new Date().toISOString();

  await query(
    `INSERT INTO products (id, name, price, stock, description, imageUrl, createdAt, updatedAt)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [id, name, price, stock, description || null, imageUrl || null, now, now]
  );

  return { id, name, price, stock, description, imageUrl, createdAt: now, updatedAt: now };
};

/**
 * Update a product
 */
const updateProduct = async (productId, updates) => {
  const { name, price, stock, description, imageUrl } = updates;
  const now = new Date().toISOString();

  // Build dynamic update query
  const fields = [];
  const values = [];

  if (name !== undefined) {
    fields.push('name = ?');
    values.push(name);
  }
  if (price !== undefined) {
    fields.push('price = ?');
    values.push(price);
  }
  if (stock !== undefined) {
    fields.push('stock = ?');
    values.push(stock);
  }
  if (description !== undefined) {
    fields.push('description = ?');
    values.push(description);
  }
  if (imageUrl !== undefined) {
    fields.push('imageUrl = ?');
    values.push(imageUrl);
  }

  fields.push('updatedAt = ?');
  values.push(now);
  values.push(productId);

  await query(
    `UPDATE products SET ${fields.join(', ')} WHERE id = ?`,
    values
  );

  return getProductById(productId);
};

/**
 * Delete a product
 */
const deleteProduct = async (productId) => {
  await query('DELETE FROM products WHERE id = ?', [productId]);
  return { success: true };
};

module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
