const { query } = require('../config/database');

/**
 * Get dashboard statistics
 */
const getStats = async () => {
    // Total users
    const [usersResult] = await query('SELECT COUNT(*) as count FROM users');
    const totalUsers = usersResult[0].count;

    // Total products
    const [productsResult] = await query('SELECT COUNT(*) as count FROM products');
    const totalProducts = productsResult[0].count;

    // Total orders
    const [ordersResult] = await query('SELECT COUNT(*) as count FROM orders');
    const totalOrders = ordersResult[0].count;

    // Total revenue
    const [revenueResult] = await query(
        "SELECT COALESCE(SUM(totalAmount), 0) as total FROM orders WHERE status != 'cancelled'"
    );
    const totalRevenue = revenueResult[0].total;

    // Recent orders (last 5)
    const [recentOrders] = await query(`
    SELECT o.*, u.name as userName, u.email as userEmail
    FROM orders o
    LEFT JOIN users u ON o.userId = u.id
    ORDER BY o.createdAt DESC
    LIMIT 5
  `);

    // Low stock products (stock < 10)
    const [lowStockProducts] = await query(
        'SELECT * FROM products WHERE stock < 10 ORDER BY stock ASC LIMIT 5'
    );

    // Orders by status
    const [ordersByStatus] = await query(`
    SELECT status, COUNT(*) as count
    FROM orders
    GROUP BY status
  `);

    // Monthly revenue (last 6 months)
    const [monthlyRevenue] = await query(`
    SELECT 
      DATE_FORMAT(createdAt, '%Y-%m') as month,
      SUM(totalAmount) as revenue,
      COUNT(*) as orderCount
    FROM orders
    WHERE status != 'cancelled'
      AND createdAt >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
    GROUP BY DATE_FORMAT(createdAt, '%Y-%m')
    ORDER BY month DESC
  `);

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
