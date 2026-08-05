import { Router } from 'express';
import { googleAuth, refresh, me, updateProfile, changePassword, adminLogin } from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Google Authentication (Mobile app customer sign-in)
router.post('/google', googleAuth);

// Admin Email/Password Authentication
router.post('/admin-login', adminLogin);

// Token management & session check
router.post('/refresh', refresh);
router.get('/me', authenticateToken, me);
router.put('/me', authenticateToken, updateProfile);
router.put('/me/password', authenticateToken, changePassword);

export default router;
