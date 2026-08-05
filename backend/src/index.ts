import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes';
import categoryRoutes from './routes/categoryRoutes';
import productRoutes from './routes/productRoutes';
import wishlistRoutes from './routes/wishlistRoutes';
import addressRoutes from './routes/addressRoutes';
import cartRoutes from './routes/cartRoutes';
import orderRoutes from './routes/orderRoutes';
import notificationRoutes from './routes/notificationRoutes';
import adminRoutes from './routes/adminRoutes';
import settingsRoutes from './routes/settingsRoutes';

import uploadRoutes from './routes/uploadRoutes';
import bannerRoutes from './routes/bannerRoutes';

import rateLimit from 'express-rate-limit';

const systemPort = process.env.PORT;
dotenv.config();

const app = express();
const port = systemPort ? parseInt(systemPort, 10) : (process.env.PORT ? parseInt(process.env.PORT, 10) : 3000);

// Explicit CORS allowlist
const allowedOrigins = [
  'https://nextlook-admin-dashboard.onrender.com',
  'http://localhost:5173',
  'http://localhost:5174',
  'http://localhost:3000',
  ...(process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',').map((s) => s.trim()) : []),
];

// Custom CORS middleware for explicit allowlist and clean origin rejection
app.use((req, res, next) => {
  const origin = req.headers.origin;

  // Check if request origin matches allowed origins
  if (!origin || allowedOrigins.includes(origin)) {
    if (origin) {
      res.setHeader('Access-Control-Allow-Origin', origin);
      res.setHeader('Access-Control-Allow-Credentials', 'true');
      res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    }

    if (req.method === 'OPTIONS') {
      return res.sendStatus(204);
    }
    return next();
  }

  // Disallowed origin: return 204 for OPTIONS preflight without CORS headers
  if (req.method === 'OPTIONS') {
    return res.sendStatus(204);
  }

  return next();
});

// Rate limiters to prevent brute force and API abuse
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 15, // limit each IP to 15 auth requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many login/auth requests from this IP. Please try again after 15 minutes.' },
});

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // limit each IP to 200 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: 'Too many requests from this IP. Please try again later.' },
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (_req, res) => {
  res.json({ status: 'ok', service: 'NextLook Backend' });
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// Apply rate limiters & mount auth routes
app.use('/api/auth', authLimiter, authRoutes);
app.use('/auth', authLimiter, authRoutes);
app.use('/api', apiLimiter);

app.use('/api/banners', bannerRoutes);
app.use('/banners', bannerRoutes);

app.use('/api/categories', categoryRoutes);
app.use('/categories', categoryRoutes);

app.use('/api/products', productRoutes);
app.use('/products', productRoutes);

app.use('/api/wishlist', wishlistRoutes);
app.use('/wishlist', wishlistRoutes);

app.use('/api/addresses', addressRoutes);
app.use('/addresses', addressRoutes);

app.use('/api/cart', cartRoutes);
app.use('/cart', cartRoutes);

app.use('/api/orders', orderRoutes);
app.use('/orders', orderRoutes);

app.use('/api/notifications', notificationRoutes);
app.use('/notifications', notificationRoutes);

app.use('/api/settings', settingsRoutes);
app.use('/settings', settingsRoutes);

app.use('/api/admin/upload', uploadRoutes);
app.use('/admin/upload', uploadRoutes);

app.use('/api/admin', adminRoutes);
app.use('/admin', adminRoutes);

app.listen(port, '0.0.0.0', () => {
  console.log(`NextLook backend running on port ${port}`);
});

export default app;
