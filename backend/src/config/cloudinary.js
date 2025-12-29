/**
 * Cloudinary Image Upload Service
 * Free tier: 25GB storage, 25GB bandwidth/month
 */

const axios = require('axios');
const FormData = require('form-data');

// Cloudinary configuration - using unsigned upload (no API secret needed)
const CLOUDINARY_CLOUD_NAME = 'dplaceholder'; // Will be updated
const CLOUDINARY_UPLOAD_PRESET = 'sporthub_unsigned'; // Unsigned upload preset

// Using a demo account for testing - you can replace with your own
const CLOUD_NAME = process.env.CLOUDINARY_CLOUD_NAME || 'demo';
const UPLOAD_URL = `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload`;

/**
 * Upload image to Cloudinary using unsigned upload
 * @param {Buffer} imageBuffer - Image file buffer
 * @param {string} filename - Original filename
 * @returns {Promise<{url: string, publicId: string}>}
 */
const uploadImage = async (imageBuffer, filename = 'image') => {
    try {
        console.log('[Cloudinary] Starting upload for:', filename);
        console.log('[Cloudinary] Buffer size:', imageBuffer?.length || 0, 'bytes');

        if (!imageBuffer || imageBuffer.length === 0) {
            throw new Error('Image buffer is empty');
        }

        // Convert buffer to base64 data URI
        const base64Image = `data:image/jpeg;base64,${imageBuffer.toString('base64')}`;

        // Create form data for Cloudinary
        const formData = new FormData();
        formData.append('file', base64Image);
        formData.append('upload_preset', 'ml_default'); // Cloudinary's default unsigned preset
        formData.append('folder', 'sporthub');

        console.log('[Cloudinary] Sending request to Cloudinary...');

        const response = await axios.post(UPLOAD_URL, formData, {
            headers: {
                ...formData.getHeaders(),
            },
            maxContentLength: Infinity,
            maxBodyLength: Infinity,
        });

        console.log('[Cloudinary] Response status:', response.status);

        if (response.data && response.data.secure_url) {
            const result = {
                url: response.data.secure_url,
                publicId: response.data.public_id,
                width: response.data.width,
                height: response.data.height,
            };
            console.log('[Cloudinary] Upload successful:', result.url);
            return result;
        }

        throw new Error('Cloudinary upload failed: No URL returned');
    } catch (error) {
        console.error('[Cloudinary] Upload error:', error.message);
        if (error.response?.data) {
            console.error('[Cloudinary] Response data:', JSON.stringify(error.response.data));
        }
        throw new Error('Failed to upload image: ' + error.message);
    }
};

module.exports = {
    uploadImage,
};
