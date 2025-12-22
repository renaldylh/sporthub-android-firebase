const {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
} = require('../services/productService');

const listProducts = async (_req, res) => {
  try {
    const products = await getProducts();
    return res.json({ products });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const getProduct = async (req, res) => {
  try {
    const product = await getProductById(req.params.productId);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    return res.json({ product });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const createProductHandler = async (req, res) => {
  try {
    const { name, price, stock, description, imageUrl } = req.body;

    if (!name || price == null || stock == null) {
      return res.status(400).json({ message: 'Name, price, and stock are required' });
    }

    const product = await createProduct({ name, price, stock, description, imageUrl });
    return res.status(201).json({ product });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const updateProductHandler = async (req, res) => {
  try {
    const product = await updateProduct(req.params.productId, req.body);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    return res.json({ product });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const removeProduct = async (req, res) => {
  try {
    await deleteProduct(req.params.productId);
    return res.json({ success: true });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// Upload product image
const uploadProductImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No image file uploaded' });
    }

    const productId = req.params.productId;
    const imageUrl = `/uploads/products/${req.file.filename}`;

    // Update product with new image URL
    const product = await updateProduct(productId, { imageUrl });

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    return res.json({
      message: 'Image uploaded successfully',
      imageUrl,
      product
    });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

module.exports = {
  listProducts,
  getProduct,
  createProductHandler,
  updateProductHandler,
  removeProduct,
  uploadProductImage,
};
