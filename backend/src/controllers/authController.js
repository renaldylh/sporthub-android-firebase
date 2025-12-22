const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const {
  createUser,
  getUserByEmail,
  getUserById,
} = require('../services/userService');

const JWT_SECRET = process.env.JWT_SECRET || 'development-secret-key';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

const generateToken = (user) =>
  jwt.sign(
    {
      id: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN },
  );

const sanitize = (user) => {
  if (!user) return null;
  const { passwordHash, ...safeData } = user;
  return safeData;
};

const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Name, email, and password are required' });
    }

    const user = await createUser({ name, email, password, role: 'user' });
    const token = generateToken(user);

    return res.status(201).json({ user, token });
  } catch (error) {
    return res.status(400).json({ message: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await getUserByEmail(email);
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isValidPassword = await bcrypt.compare(password, user.passwordHash);
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const safeUser = sanitize(user);
    const token = generateToken(safeUser);

    return res.json({ user: safeUser, token });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

const profile = async (req, res) => {
  try {
    const user = await getUserById(req.user.id);
    return res.json({ user });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

module.exports = {
  register,
  login,
  profile,
};
