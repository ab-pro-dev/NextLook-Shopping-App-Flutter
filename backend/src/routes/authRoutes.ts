import { Router } from 'express';
import { googleAuth, refresh, me, updateProfile, changePassword, adminLogin, adminSetInitialPassword } from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Google Authentication (Mobile app customer sign-in)
router.post('/google', googleAuth);

// Admin Email/Password Authentication & Initial Setup
router.post('/admin-login', adminLogin);
router.post('/admin-set-initial-password', adminSetInitialPassword);

// Token management & session check
router.post('/refresh', refresh);
router.get('/me', authenticateToken, me);
router.put('/me', authenticateToken, updateProfile);
router.put('/me/password', authenticateToken, changePassword);

export default router;
