import express from 'express';
import { registerShipper, getMyShipper, updateMyShipper } from '../controllers/shippersController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.post('/register', authenticate, authorize(['SHIPPER']), registerShipper);
router.get('/me', authenticate, authorize(['SHIPPER']), getMyShipper);
router.patch('/me', authenticate, authorize(['SHIPPER']), updateMyShipper);

export default router;