import { Router } from 'express';
import { getProducts, getHomeSections, getProductById } from '../controllers/productController';

const router = Router();

router.get('/', getProducts);
router.get('/home-sections', getHomeSections);
router.get('/:id', getProductById);

export default router;
