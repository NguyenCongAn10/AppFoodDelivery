import express from 'express';
import {
    createOrder, getMyOrders, getAssignedOrders, getAllOrders, getRestaurantOrders,
    cancelOrder, confirmOrder, assignShipper, pickupOrder, completeOrder,
    getAvailableOrders, acceptOrder, updateShipperLocation, readyOrder
} from '../controllers/ordersController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.post('/', authenticate, authorize(['USER']), createOrder);
router.get('/me', authenticate, authorize(['USER']), getMyOrders);
router.get('/available', authenticate, authorize(['SHIPPER']), getAvailableOrders);
router.get('/assigned', authenticate, authorize(['SHIPPER']), getAssignedOrders);
router.get('/restaurant', authenticate, authorize(['RESTAURANT']), getRestaurantOrders);
router.get('/', authenticate, authorize(['ADMIN']), getAllOrders);
router.patch('/:id/cancel', authenticate, authorize(['USER', 'RESTAURANT']), cancelOrder);
router.patch('/:id/confirm', authenticate, authorize(['RESTAURANT']), confirmOrder);
router.patch('/:id/ready', authenticate, authorize(['RESTAURANT']), readyOrder);
router.patch('/:id/assign-shipper', authenticate, authorize(['ADMIN']), assignShipper);
router.patch('/:id/accept', authenticate, authorize(['SHIPPER']), acceptOrder);
router.patch('/:id/pickup', authenticate, authorize(['SHIPPER']), pickupOrder);
router.patch('/:id/complete', authenticate, authorize(['SHIPPER']), completeOrder);
router.patch('/:id/location', authenticate, authorize(['SHIPPER']), updateShipperLocation);

export default router;