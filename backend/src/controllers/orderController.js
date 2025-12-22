const {
  createOrder,
  getOrders,
  getOrdersByUser,
  getOrderById,
  updateOrderStatus,
  uploadPaymentProof,
  expireOldOrders,
} = require('../services/orderService');

const createOrderHandler = async (req, res) => {
  try {
    const { items, totalAmount, shippingAddress, paymentMethod } = req.body;
    const userId = req.user?.id || req.body.userId;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: 'Order must contain at least one item' });
    }

    if (!shippingAddress) {
      return res.status(400).json({ message: 'Shipping address is required' });
    }

    const order = await createOrder({
      userId,
      items,
      totalAmount,
      shippingAddress,
      paymentMethod,
    });

    return res.status(201).json({
      order,
      bankInfo: {
        bankName: 'BCA',
        accountNumber: '1234567890',
        accountHolder: 'Banyumas SportHub',
      },
      message: 'Order created. Please upload payment proof within 10 hours.',
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const listOrders = async (_req, res) => {
  try {
    // Expire old orders first
    await expireOldOrders();
    const orders = await getOrders();
    return res.json({ orders });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const listMyOrders = async (req, res) => {
  try {
    // Expire old orders first
    await expireOldOrders();
    const orders = await getOrdersByUser(req.user.id);
    return res.json({ orders });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getOrder = async (req, res) => {
  try {
    const order = await getOrderById(req.params.orderId);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    if (req.user.role !== 'admin' && order.userId !== req.user.id) {
      return res.status(403).json({ message: 'Not authorized to view this order' });
    }

    return res.json({ order });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const updateOrderStatusHandler = async (req, res) => {
  try {
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ message: 'Status is required' });
    }

    const validStatuses = ['pending', 'paid', 'delivery', 'completed', 'cancelled', 'expired'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }

    const order = await updateOrderStatus(req.params.orderId, status);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    return res.json({ order, message: `Order status updated to ${status}` });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const uploadPaymentProofHandler = async (req, res) => {
  try {
    const { paymentProofUrl } = req.body;
    const orderId = req.params.orderId;

    if (!paymentProofUrl) {
      return res.status(400).json({ message: 'Payment proof URL is required' });
    }

    const existingOrder = await getOrderById(orderId);
    if (!existingOrder) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Check if order belongs to user
    if (existingOrder.userId !== req.user.id) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    // Check if order is expired
    if (existingOrder.status === 'expired') {
      return res.status(400).json({ message: 'Order has expired' });
    }

    const order = await uploadPaymentProof(orderId, paymentProofUrl);
    return res.json({ order, message: 'Payment proof uploaded successfully. Waiting for admin verification.' });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

module.exports = {
  createOrderHandler,
  listOrders,
  listMyOrders,
  getOrder,
  updateOrderStatusHandler,
  uploadPaymentProofHandler,
};
