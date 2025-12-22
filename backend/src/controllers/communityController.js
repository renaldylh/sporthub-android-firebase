const {
    getCommunities,
    getCommunityById,
    createCommunity,
    updateCommunity,
    deleteCommunity,
} = require('../services/communityService');

const listCommunities = async (_req, res) => {
    try {
        const communities = await getCommunities();
        return res.json({ communities });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const getCommunity = async (req, res) => {
    try {
        const community = await getCommunityById(req.params.id);
        if (!community) {
            return res.status(404).json({ message: 'Community not found' });
        }
        return res.json({ community });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const createCommunityHandler = async (req, res) => {
    try {
        const { name, description, category, imageUrl } = req.body;

        if (!name) {
            return res.status(400).json({ message: 'Name is required' });
        }

        const community = await createCommunity({ name, description, category, imageUrl });
        return res.status(201).json({ community });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const updateCommunityHandler = async (req, res) => {
    try {
        const community = await updateCommunity(req.params.id, req.body);
        if (!community) {
            return res.status(404).json({ message: 'Community not found' });
        }
        return res.json({ community });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const removeCommunity = async (req, res) => {
    try {
        await deleteCommunity(req.params.id);
        return res.json({ success: true });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

module.exports = {
    listCommunities,
    getCommunity,
    createCommunityHandler,
    updateCommunityHandler,
    removeCommunity,
};
