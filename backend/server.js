const express = require('express');
const cors = require('cors');
const path = require('path');
const dotenv = require('dotenv');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');

// Load environment variables
dotenv.config();

const { initializeDatabase } = require('./src/config/database');
const authRoutes = require('./src/routes/authRoutes');
const productRoutes = require('./src/routes/productRoutes');
const orderRoutes = require('./src/routes/orderRoutes');
const userRoutes = require('./src/routes/userRoutes');
const dashboardRoutes = require('./src/routes/dashboardRoutes');
const communityRoutes = require('./src/routes/communityRoutes');
const venueRoutes = require('./src/routes/venueRoutes');
const bookingRoutes = require('./src/routes/bookingRoutes');
const eventRoutes = require('./src/routes/eventRoutes');

const app = express();

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const filename = `${uuidv4()}${ext}`;
    cb(null, filename);
  },
});

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

// Serve static files (uploaded images)
app.use('/uploads', express.static(uploadsDir));

// Root route - API Welcome
app.get('/', (_req, res) => {
  res.json({
    name: 'Banyumas SportHub API',
    version: '1.0.0',
    status: 'running',
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
    message: 'Banyumas SportHub API is running',
    timestamp: new Date().toISOString(),
  });
});

// Image upload endpoint
app.post('/api/upload', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No image file provided' });
    }
    const imageUrl = `/uploads/${req.file.filename}`;
    res.json({
      message: 'Image uploaded successfully',
      imageUrl,
      fullUrl: `${req.protocol}://${req.get('host')}${imageUrl}`,
    });
  } catch (error) {
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
    // Initialize database tables
    await initializeDatabase();
    console.log('✅ Database connected and initialized');

    const port = process.env.PORT || 5000;
    app.listen(port, () => {
      console.log(`🚀 Banyumas SportHub API listening on http://localhost:${port}`);
      console.log(`📋 Health check: http://localhost:${port}/api/health`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error.message);
    process.exit(1);
  }
};

startServer();
