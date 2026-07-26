import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import {
  createOrder,
  getOrders,
  getOrderById,
} from '../controllers/orderController';

const router = Router();

router.use(authenticateToken);

router.post('/', createOrder);
router.get('/', getOrders);
router.get('/:id', getOrderById);

export default router;
