const {
    getVenues,
    getVenueById,
    createVenue,
    updateVenue,
    deleteVenue,
} = require('../services/venueService');

const listVenues = async (_req, res) => {
    try {
        const venues = await getVenues();
        return res.json({ venues });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const getVenueHandler = async (req, res) => {
    try {
        const venue = await getVenueById(req.params.id);
        if (!venue) {
            return res.status(404).json({ message: 'Venue not found' });
        }
        return res.json({ venue });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const createVenueHandler = async (req, res) => {
    try {
        const { name, type, pricePerHour, address, description, imageUrl } = req.body;

        if (!name || !type || pricePerHour == null) {
            return res.status(400).json({ message: 'Name, type, and pricePerHour are required' });
        }

        const venue = await createVenue({ name, type, pricePerHour, address, description, imageUrl });
        return res.status(201).json({ venue });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const updateVenueHandler = async (req, res) => {
    try {
        const venue = await updateVenue(req.params.id, req.body);
        if (!venue) {
            return res.status(404).json({ message: 'Venue not found' });
        }
        return res.json({ venue });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

const removeVenue = async (req, res) => {
    try {
        await deleteVenue(req.params.id);
        return res.json({ success: true });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

module.exports = {
    listVenues,
    getVenueHandler,
    createVenueHandler,
    updateVenueHandler,
    removeVenue,
};
