import express from 'express';
import {
    createOrder, getMyOrders, getAssignedOrders, getAllOrders, getRestaurantOrders,
    cancelOrder, confirmOrder, assignShipper, pickupOrder, completeOrder
} from '../controllers/ordersController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.post('/', authenticate, authorize(['USER']), createOrder);
router.get('/me', authenticate, authorize(['USER']), getMyOrders);
router.get('/assigned', authenticate, authorize(['SHIPPER']), getAssignedOrders);
router.get('/restaurant', authenticate, authorize(['RESTAURANT']), getRestaurantOrders);
router.get('/', authenticate, authorize(['ADMIN']), getAllOrders);
router.patch('/:id/cancel', authenticate, authorize(['USER', 'RESTAURANT']), cancelOrder);
router.patch('/:id/confirm', authenticate, authorize(['RESTAURANT']), confirmOrder);
router.patch('/:id/assign-shipper', authenticate, authorize(['ADMIN']), assignShipper);
router.patch('/:id/pickup', authenticate, authorize(['SHIPPER']), pickupOrder);
router.patch('/:id/complete', authenticate, authorize(['SHIPPER']), completeOrder);

export default router;