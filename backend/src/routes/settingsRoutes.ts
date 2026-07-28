import { Router } from 'express';
import { getPublicSettings } from '../controllers/settingsController';

const router = Router();

// Public route: GET /api/settings
router.get('/', getPublicSettings);

export default router;
