/**
 * Product Service - Firebase Realtime Database
 */

const { v4: uuidv4 } = require('uuid');
const { getAll, getById, create, update, remove } = require('../config/firebase');

const PRODUCTS_REF = 'products';

/**
 * Get all products
 */
const getProducts = async () => {
  const products = await getAll(PRODUCTS_REF);
  // Sort by createdAt DESC
  products.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return products;
};

/**
 * Get product by ID
 */
const getProductById = async (productId) => {
  return getById(PRODUCTS_REF, productId);
};

/**
 * Create a new product
 */
const createProduct = async ({ name, price, stock, description, imageUrl }) => {
  const id = uuidv4();
  const now = new Date().toISOString();

  const productData = {
    name,
    price: Number(price),
    stock: Number(stock) || 0,
    description: description || null,
    imageUrl: imageUrl || null,
    createdAt: now,
    updatedAt: now,
  };

  return create(PRODUCTS_REF, id, productData);
};

/**
 * Update a product
 */
const updateProduct = async (productId, updates) => {
  const { name, price, stock, description, imageUrl } = updates;
  const now = new Date().toISOString();

  const updateData = { updatedAt: now };

  if (name !== undefined) updateData.name = name;
  if (price !== undefined) updateData.price = Number(price);
  if (stock !== undefined) updateData.stock = Number(stock);
  if (description !== undefined) updateData.description = description;
  if (imageUrl !== undefined) updateData.imageUrl = imageUrl;

  return update(PRODUCTS_REF, productId, updateData);
};

/**
 * Delete a product
 */
const deleteProduct = async (productId) => {
  return remove(PRODUCTS_REF, productId);
};

module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
