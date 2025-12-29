const express = require('express');
const cors = require('cors');
const path = require('path');
const dotenv = require('dotenv');
const multer = require('multer');

// Load environment variables
dotenv.config();

// Firebase initialization (replaces MySQL)
const { initializeDatabase } = require('./src/config/firebase');
const { uploadImage } = require('./src/config/imageUpload');

// Routes
const authRoutes = require('./src/routes/authRoutes');
const productRoutes = require('./src/routes/productRoutes');
const orderRoutes = require('./src/routes/orderRoutes');
const userRoutes = require('./src/routes/userRoutes');
const dashboardRoutes = require('./src/routes/dashboardRoutes');
const communityRoutes = require('./src/routes/communityRoutes');
const venueRoutes = require('./src/routes/venueRoutes');
const bookingRoutes = require('./src/routes/bookingRoutes');
const eventRoutes = require('./src/routes/eventRoutes');
const eventRegistrationRoutes = require('./src/routes/eventRegistrationRoutes');
const communityMembershipRoutes = require('./src/routes/communityMembershipRoutes');

const app = express();

// Configure multer for memory storage (for ImgBB upload)
const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    // Allow common image MIME types
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/jpg'];
    // Also check by file extension
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    const ext = path.extname(file.originalname).toLowerCase();

    if (allowedMimeTypes.includes(file.mimetype) || allowedExtensions.includes(ext)) {
      cb(null, true);
    } else {
      console.log(`Rejected file: ${file.originalname}, mimetype: ${file.mimetype}`);
      cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed.'));
    }
  },
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Root route - API Welcome
app.get('/', (_req, res) => {
  res.json({
    name: 'Banyumas SportHub API',
    version: '2.0.0',
    status: 'running',
    database: 'Firebase Realtime Database',
    imageStorage: 'ImgBB',
    endpoints: {
      health: 'GET /api/health',
      upload: 'POST /api/upload',
      auth: 'POST /api/auth/login, /api/auth/register',
      products: 'GET/POST/PUT/DELETE /api/products',
      orders: 'GET/POST/PATCH /api/orders',
      users: 'GET/PUT/DELETE /api/users',
      events: 'GET/POST/PUT/DELETE /api/events',
      communities: 'GET/POST/PUT/DELETE /api/communities',
      venues: 'GET/POST/PUT/DELETE /api/venues',
      bookings: 'GET/POST/PATCH /api/bookings',
    },
  });
});

// Health check endpoint
app.get('/api/health', (_req, res) => {
  res.json({
    status: 'ok',
    message: 'Banyumas SportHub API is running with Firebase',
    timestamp: new Date().toISOString(),
  });
});

// Image upload endpoint (now using ImgBB)
app.post('/api/upload', upload.single('image'), async (req, res) => {
  try {
    console.log('[Upload] Request received');
    console.log('[Upload] File:', req.file?.originalname, 'Size:', req.file?.size, 'bytes');

    if (!req.file) {
      console.log('[Upload] No file in request');
      return res.status(400).json({ message: 'No image file provided' });
    }

    // Upload to ImgBB
    const result = await uploadImage(req.file.buffer, req.file.originalname);

    console.log('[Upload] Success, URL:', result.url);

    res.json({
      message: 'Image uploaded successfully',
      imageUrl: result.url,
      displayUrl: result.displayUrl,
      thumbnail: result.thumbnail,
    });
  } catch (error) {
    console.error('[Upload] Error:', error.message);
    console.error('[Upload] Stack:', error.stack);
    res.status(500).json({ message: error.message });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/users', userRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/communities', communityRoutes);
app.use('/api/venues', venueRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/event-registrations', eventRegistrationRoutes);
app.use('/api/community-memberships', communityMembershipRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.originalUrl,
  });
});

// Error handler
app.use((err, _req, res, _next) => {
  console.error('Server Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
  });
});

// Start server
const startServer = async () => {
  try {
    // Initialize Firebase connection
    await initializeDatabase();
    console.log('✅ Firebase Realtime Database connected');

    const port = process.env.PORT || 5000;
    app.listen(port, () => {
      console.log(`🚀 Banyumas SportHub API listening on http://localhost:${port}`);
      console.log(`📋 Health check: http://localhost:${port}/api/health`);
      console.log(`🔥 Using Firebase Realtime Database`);
      console.log(`🖼️  Using ImgBB for image storage`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:');
    console.error('   Error:', error.message);
    console.error('   Stack:', error.stack);
    process.exit(1);
  }
};

startServer();
