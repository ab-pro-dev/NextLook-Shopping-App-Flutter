import { Router, Response } from 'express';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import { requireAdmin } from '../middleware/adminMiddleware';
import { getDashboardStats } from '../controllers/adminController';
import {
  getAdminProducts,
  getAdminProductById,
  createAdminProduct,
  updateAdminProduct,
  deleteAdminProduct,
  updateAdminProductStock,
} from '../controllers/adminProductController';
import {
  getAdminOrders,
  getAdminOrderById,
  updateAdminOrderStatus,
} from '../controllers/adminOrderController';
import {
  getAdminCategories,
  createAdminCategory,
  updateAdminCategory,
  deleteAdminCategory,
} from '../controllers/adminCategoryController';
import {
  getAdminCustomers,
  getAdminCustomerById,
} from '../controllers/adminCustomerController';
import {
  getAdminBanners,
  createAdminBanner,
  updateAdminBanner,
  deleteAdminBanner,
} from '../controllers/bannerController';
import { updateAdminSettings } from '../controllers/settingsController';

const router = Router();

// Protect ALL admin routes with authenticateToken + requireAdmin
router.use(authenticateToken, requireAdmin);

// Dashboard stats & health check
router.get('/dashboard-stats', getDashboardStats);
router.get('/health-check', (_req: AuthenticatedRequest, res: Response) => {
  return res.status(200).json({ status: 'ok' });
});

// Admin Product Management
router.get('/products', getAdminProducts);
router.get('/products/:id', getAdminProductById);
router.post('/products', createAdminProduct);
router.put('/products/:id', updateAdminProduct);
router.delete('/products/:id', deleteAdminProduct);
router.put('/products/:id/stock', updateAdminProductStock);

// Admin Order Management
router.get('/orders', getAdminOrders);
router.get('/orders/:id', getAdminOrderById);
router.put('/orders/:id/status', updateAdminOrderStatus);

// Admin Category Management
router.get('/categories', getAdminCategories);
router.post('/categories', createAdminCategory);
router.put('/categories/:id', updateAdminCategory);
router.delete('/categories/:id', deleteAdminCategory);

// Admin Customer Management (Read-Only)
router.get('/customers', getAdminCustomers);
router.get('/customers/:id', getAdminCustomerById);

// Admin Banner Management
router.get('/banners', getAdminBanners);
router.post('/banners', createAdminBanner);
router.put('/banners/:id', updateAdminBanner);
router.delete('/banners/:id', deleteAdminBanner);

// Admin Store Settings
router.put('/settings', updateAdminSettings);

export default router;
