import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import {
  createTelebirrCheckout,
  handleTelebirrNotify,
  handleTelebirrRedirect,
  testTelebirrConnection,
} from '../controllers/telebirrController';

const router = Router();

// GET /api/payments/telebirr/test-connection (Protected diagnostic endpoint)
router.get('/test-connection', authenticateToken, testTelebirrConnection);

// POST /api/payments/telebirr/create-checkout (Authenticated)
router.post('/create-checkout', authenticateToken, createTelebirrCheckout);

// POST /api/payments/telebirr/notify (Webhook from Telebirr)
router.post('/notify', handleTelebirrNotify);

// GET /api/payments/telebirr/redirect (Browser landing page)
router.get('/redirect', handleTelebirrRedirect);

export default router;
