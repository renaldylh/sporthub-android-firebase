const mysql = require('mysql2/promise');

/**
 * Database configuration for MySQL via XAMPP
 */
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'sporthub',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

/**
 * Initialize database tables
 */
const initializeDatabase = async () => {
  const connection = await pool.getConnection();

  try {
    // Create users table
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(36) PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        name VARCHAR(255) NOT NULL,
        role ENUM('user', 'admin') DEFAULT 'user',
        passwordHash VARCHAR(255) NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_email (email)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Create products table
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS products (
        id VARCHAR(36) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(12, 2) NOT NULL,
        stock INT NOT NULL DEFAULT 0,
        description TEXT,
        imageUrl VARCHAR(500),
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Create orders table
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS orders (
        id VARCHAR(36) PRIMARY KEY,
        userId VARCHAR(36) NOT NULL,
        totalAmount DECIMAL(12, 2) NOT NULL,
        status ENUM('pending', 'paid', 'delivery', 'completed', 'cancelled', 'expired') DEFAULT 'pending',
        paymentMethod VARCHAR(50),
        shippingAddress TEXT,
        paymentProof VARCHAR(500),
        expiresAt DATETIME,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_userId (userId),
        INDEX idx_status (status),
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    // Create order_items table
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS order_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        orderId VARCHAR(36) NOT NULL,
        productId VARCHAR(36),
        name VARCHAR(255) NOT NULL,
        price DECIMAL(12, 2) NOT NULL,
        quantity INT NOT NULL,
        INDEX idx_orderId (orderId),
        FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);

    console.log('✅ Database tables initialized successfully');
  } finally {
    connection.release();
  }
};

/**
 * Get a connection from the pool
 */
const getConnection = () => pool.getConnection();

/**
 * Execute a query
 */
const query = (sql, params) => pool.execute(sql, params);

module.exports = {
  pool,
  getConnection,
  query,
  initializeDatabase,
};
