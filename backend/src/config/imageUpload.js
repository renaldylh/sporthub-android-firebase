/**
 * Image Upload Service using Freeimage.host
 * Backend proxy to avoid CORS issues from Flutter Web
 */

const axios = require('axios');
const FormData = require('form-data');

// Freeimage.host API - free, no registration
const API_KEY = '6d207e02198a847aa98d0a2a901485a5';
const UPLOAD_URL = 'https://freeimage.host/api/1/upload';

/**
 * Upload image to Freeimage.host
 * @param {Buffer} imageBuffer - Image file buffer
 * @param {string} filename - Original filename
 * @returns {Promise<{url: string}>}
 */
const uploadImage = async (imageBuffer, filename = 'image') => {
    try {
        console.log('[ImageUpload] Starting upload for:', filename);
        console.log('[ImageUpload] Buffer size:', imageBuffer?.length || 0, 'bytes');

        if (!imageBuffer || imageBuffer.length === 0) {
            throw new Error('Image buffer is empty');
        }

        // Convert to base64
        const base64Image = imageBuffer.toString('base64');
        console.log('[ImageUpload] Base64 length:', base64Image.length);

        // Create form data
        const formData = new FormData();
        formData.append('key', API_KEY);
        formData.append('action', 'upload');
        formData.append('source', base64Image);
        formData.append('format', 'json');

        console.log('[ImageUpload] Sending to Freeimage.host...');

        const response = await axios.post(UPLOAD_URL, formData, {
            headers: formData.getHeaders(),
            maxContentLength: Infinity,
            maxBodyLength: Infinity,
            timeout: 60000,
        });

        console.log('[ImageUpload] Response status:', response.status);
        console.log('[ImageUpload] Response data:', JSON.stringify(response.data));

        if (response.data && response.data.status_code === 200 && response.data.image) {
            const result = {
                url: response.data.image.url,
                displayUrl: response.data.image.display_url,
                thumb: response.data.image.thumb?.url,
            };
            console.log('[ImageUpload] SUCCESS! URL:', result.url);
            return result;
        }

        throw new Error('Upload failed: ' + (response.data?.error?.message || response.data?.status_txt || 'Unknown error'));
    } catch (error) {
        console.error('[ImageUpload] ERROR:', error.message);
        if (error.response?.data) {
            console.error('[ImageUpload] Response:', JSON.stringify(error.response.data));
        }
        throw new Error('Failed to upload: ' + error.message);
    }
};

module.exports = {
    uploadImage,
};
