import { Router, Response } from 'express';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import { requireAdmin } from '../middleware/adminMiddleware';
import { getDashboardStats } from '../controllers/adminController';

const router = Router();

// Protect ALL admin routes with authenticateToken + requireAdmin
router.use(authenticateToken, requireAdmin);

// GET /api/admin/dashboard-stats
router.get('/dashboard-stats', getDashboardStats);

// GET /api/admin/health-check
router.get('/health-check', (_req: AuthenticatedRequest, res: Response) => {
  return res.status(200).json({ status: 'ok' });
});

export default router;
