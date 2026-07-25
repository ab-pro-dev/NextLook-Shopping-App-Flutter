import { Router } from 'express';
import { authenticateToken } from '../middleware/auth';
import {
  getWishlist,
  addToWishlist,
  removeFromWishlist,
} from '../controllers/wishlistController';

const router = Router();

router.use(authenticateToken);

router.get('/', getWishlist);
router.post('/:productId', addToWishlist);
router.delete('/:productId', removeFromWishlist);

export default router;
