/**
 * Dashboard Service - Firebase Realtime Database
 */

const { getAll, getById } = require('../config/firebase');

const USERS_REF = 'users';
const PRODUCTS_REF = 'products';
const ORDERS_REF = 'orders';

/**
 * Get dashboard statistics
 */
const getStats = async () => {
  // Fetch all data
  const [users, products, orders] = await Promise.all([
    getAll(USERS_REF),
    getAll(PRODUCTS_REF),
    getAll(ORDERS_REF),
  ]);

  // Total counts
  const totalUsers = users.length;
  const totalProducts = products.length;
  const totalOrders = orders.length;

  // Total revenue (excluding cancelled orders)
  const validOrders = orders.filter((order) => order.status !== 'cancelled');
  const totalRevenue = validOrders.reduce((sum, order) => sum + Number(order.totalAmount || 0), 0);

  // Recent orders (last 5)
  const sortedOrders = [...orders].sort(
    (a, b) => new Date(b.createdAt) - new Date(a.createdAt)
  );

  // Enrich recent orders with user data
  const recentOrders = await Promise.all(
    sortedOrders.slice(0, 5).map(async (order) => {
      const user = await getById(USERS_REF, order.userId);
      return {
        ...order,
        userName: user?.name || null,
        userEmail: user?.email || null,
      };
    })
  );

  // Low stock products (stock < 10)
  const lowStockProducts = products
    .filter((product) => Number(product.stock) < 10)
    .sort((a, b) => Number(a.stock) - Number(b.stock))
    .slice(0, 5);

  // Orders by status
  const statusCounts = {};
  orders.forEach((order) => {
    statusCounts[order.status] = (statusCounts[order.status] || 0) + 1;
  });
  const ordersByStatus = Object.entries(statusCounts).map(([status, count]) => ({
    status,
    count,
  }));

  // Monthly revenue (last 6 months)
  const sixMonthsAgo = new Date();
  sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

  const monthlyData = {};
  validOrders
    .filter((order) => new Date(order.createdAt) >= sixMonthsAgo)
    .forEach((order) => {
      const month = order.createdAt.substring(0, 7); // YYYY-MM
      if (!monthlyData[month]) {
        monthlyData[month] = { revenue: 0, orderCount: 0 };
      }
      monthlyData[month].revenue += Number(order.totalAmount || 0);
      monthlyData[month].orderCount += 1;
    });

  const monthlyRevenue = Object.entries(monthlyData)
    .map(([month, data]) => ({
      month,
      revenue: data.revenue,
      orderCount: data.orderCount,
    }))
    .sort((a, b) => b.month.localeCompare(a.month));

  return {
    totalUsers,
    totalProducts,
    totalOrders,
    totalRevenue,
    recentOrders,
    lowStockProducts,
    ordersByStatus,
    monthlyRevenue,
  };
};

module.exports = {
  getStats,
};
