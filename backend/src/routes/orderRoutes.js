const express = require('express');
const {
  createOrderHandler,
  listOrders,
  listMyOrders,
  getOrder,
  updateOrderStatusHandler,
  uploadPaymentProofHandler,
} = require('../controllers/orderController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/', authenticate, createOrderHandler);
router.get('/', authenticate, authorizeRoles('admin'), listOrders);
router.get('/me', authenticate, listMyOrders);
router.get('/:orderId', authenticate, getOrder);
router.patch('/:orderId/status', authenticate, authorizeRoles('admin'), updateOrderStatusHandler);
router.post('/:orderId/payment-proof', authenticate, uploadPaymentProofHandler);

module.exports = router;
