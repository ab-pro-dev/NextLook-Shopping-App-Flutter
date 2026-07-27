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
import telebirrRoutes from './routes/telebirrRoutes';

const systemPort = process.env.PORT;
dotenv.config();

const app = express();
const port = systemPort ? parseInt(systemPort, 10) : (process.env.PORT ? parseInt(process.env.PORT, 10) : 3000);

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (_req, res) => {
  res.json({ status: 'ok', service: 'NextLook Backend' });
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRoutes);
app.use('/auth', authRoutes);

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

app.use('/api/payments/telebirr', telebirrRoutes);
app.use('/payments/telebirr', telebirrRoutes);

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`NextLook backend running on port ${port}`);
});

export default app;
