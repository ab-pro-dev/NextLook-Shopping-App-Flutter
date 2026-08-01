import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import { requireAdmin } from '../middleware/adminMiddleware';
import { uploadMiddleware, uploadImage, deleteImage } from '../controllers/uploadController';

const router = Router();

// All upload routes require authentication & admin privileges
router.use(authenticateToken, requireAdmin);

router.post('/image', uploadMiddleware, uploadImage);
router.delete('/image', deleteImage);

export default router;
