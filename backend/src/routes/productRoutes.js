const express = require('express');
const path = require('path');
const {
  listProducts,
  getProduct,
  createProductHandler,
  updateProductHandler,
  removeProduct,
  uploadProductImage,
} = require('../controllers/productController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');
const upload = require('../middleware/upload');

const router = express.Router();

// Public routes
router.get('/', listProducts);
router.get('/:productId', getProduct);

// Admin only routes
router.post('/', authenticate, authorizeRoles('admin'), createProductHandler);
router.put('/:productId', authenticate, authorizeRoles('admin'), updateProductHandler);
router.delete('/:productId', authenticate, authorizeRoles('admin'), removeProduct);

// Image upload route
router.post(
  '/:productId/image',
  authenticate,
  authorizeRoles('admin'),
  upload.single('image'),
  uploadProductImage
);

module.exports = router;
