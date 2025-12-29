/**
 * ImgBB Image Upload Service
 * Pengganti local file storage
 */

const axios = require('axios');
const FormData = require('form-data');

const IMGBB_API_KEY = process.env.IMGBB_API_KEY || '7c39eba7c90b99b20651dded97f0ba4c';
const IMGBB_API_URL = 'https://api.imgbb.com/1/upload';

/**
 * Upload image to ImgBB
 * @param {Buffer} imageBuffer - Image file buffer
 * @param {string} filename - Original filename (optional, for logging)
 * @returns {Promise<{url: string, deleteUrl: string}>} - Image URLs
 */
const uploadImage = async (imageBuffer, filename = 'image') => {
    try {
        // Convert buffer to base64
        const base64Image = imageBuffer.toString('base64');

        // Create form data
        const formData = new FormData();
        formData.append('key', IMGBB_API_KEY);
        formData.append('image', base64Image);
        formData.append('name', filename.replace(/\.[^/.]+$/, '')); // Remove extension

        // Upload to ImgBB
        const response = await axios.post(IMGBB_API_URL, formData, {
            headers: {
                ...formData.getHeaders(),
            },
            maxContentLength: Infinity,
            maxBodyLength: Infinity,
        });

        if (response.data.success) {
            return {
                url: response.data.data.url,
                displayUrl: response.data.data.display_url,
                deleteUrl: response.data.data.delete_url,
                thumbnail: response.data.data.thumb?.url || response.data.data.url,
            };
        }

        throw new Error('ImgBB upload failed: ' + JSON.stringify(response.data));
    } catch (error) {
        console.error('ImgBB upload error:', error.message);
        throw new Error('Failed to upload image: ' + error.message);
    }
};

/**
 * Upload image from file path (for migration purposes)
 * @param {string} filePath - Path to image file
 * @returns {Promise<{url: string}>}
 */
const uploadImageFromPath = async (filePath) => {
    const fs = require('fs');
    const path = require('path');

    const buffer = fs.readFileSync(filePath);
    const filename = path.basename(filePath);

    return uploadImage(buffer, filename);
};

module.exports = {
    uploadImage,
    uploadImageFromPath,
};
