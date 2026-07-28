import { Router } from 'express';
import { googleAuth, refresh, me } from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Google Authentication
router.post('/google', googleAuth);

// Token management & session check
router.post('/refresh', refresh);
router.get('/me', authenticateToken, me);

export default router;
