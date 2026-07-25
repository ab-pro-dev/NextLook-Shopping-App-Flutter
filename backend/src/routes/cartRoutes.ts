import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import {
  getCart,
  addItemToCart,
  updateCartItem,
  removeCartItem,
  clearCart,
} from '../controllers/cartController';

const router = Router();

router.use(authenticateToken);

router.get('/', getCart);
router.post('/items', addItemToCart);
router.put('/items/:cartItemId', updateCartItem);
router.delete('/items/:cartItemId', removeCartItem);
router.delete('/', clearCart);

export default router;
