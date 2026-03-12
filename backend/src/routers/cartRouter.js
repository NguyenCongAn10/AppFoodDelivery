import express from 'express';
const router = express.Router();
import * as cartController from '../controllers/cartController.js';
import { authenticate } from '../middleware/auth.js';

router.use(authenticate);

router.get('/', cartController.getCart);
router.post('/', cartController.addToCart);
router.patch('/:id/quantity', cartController.updateCartItem);
router.delete('/:id', cartController.removeFromCart);
router.delete('/', cartController.clearCart);

export default router;
