const { getStats } = require('../services/dashboardService');

const getDashboardStats = async (_req, res) => {
    try {
        const stats = await getStats();
        return res.json(stats);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getDashboardStats,
};
