import express from 'express';
import { registerShipper, getMyShipper, updateMyShipper, getShipperDashboard } from '../controllers/shippersController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.post('/register', authenticate, registerShipper);
router.get('/me', authenticate, authorize(['SHIPPER']), getMyShipper);
router.get('/me/dashboard', authenticate, authorize(['SHIPPER']), getShipperDashboard);
router.patch('/me', authenticate, authorize(['SHIPPER']), updateMyShipper);

export default router;