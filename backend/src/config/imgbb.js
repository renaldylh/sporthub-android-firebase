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
        console.log('[ImgBB] Starting upload for:', filename);
        console.log('[ImgBB] Buffer size:', imageBuffer?.length || 0, 'bytes');

        if (!imageBuffer || imageBuffer.length === 0) {
            throw new Error('Image buffer is empty');
        }

        // Convert buffer to base64
        const base64Image = imageBuffer.toString('base64');
        console.log('[ImgBB] Base64 length:', base64Image.length);

        // Create form data
        const formData = new FormData();
        formData.append('key', IMGBB_API_KEY);
        formData.append('image', base64Image);
        formData.append('name', filename.replace(/\.[^/.]+$/, '')); // Remove extension

        console.log('[ImgBB] Sending request to ImgBB...');

        // Upload to ImgBB
        const response = await axios.post(IMGBB_API_URL, formData, {
            headers: {
                ...formData.getHeaders(),
            },
            maxContentLength: Infinity,
            maxBodyLength: Infinity,
        });

        console.log('[ImgBB] Response success:', response.data.success);

        if (response.data.success) {
            const result = {
                url: response.data.data.url,
                displayUrl: response.data.data.display_url,
                deleteUrl: response.data.data.delete_url,
                thumbnail: response.data.data.thumb?.url || response.data.data.url,
            };
            console.log('[ImgBB] Upload successful:', result.url);
            return result;
        }

        console.error('[ImgBB] Upload failed:', response.data);
        throw new Error('ImgBB upload failed: ' + JSON.stringify(response.data));
    } catch (error) {
        console.error('[ImgBB] Upload error:', error.message);
        if (error.response?.data) {
            console.error('[ImgBB] Response data:', error.response.data);
        }
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
