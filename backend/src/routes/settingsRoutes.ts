import { Router } from 'express';
import { getPublicSettings, getDbSchemaCheck } from '../controllers/settingsController';

const router = Router();

// Public route: GET /api/settings
router.get('/', getPublicSettings);

// Temporary diagnostic route: GET /api/settings/db-schema-check
router.get('/db-schema-check', getDbSchemaCheck);

export default router;
