import express from 'express';
import { login, getMe, sendOtp, verifyOtp } from '../controllers/authController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.post('/login', login);
router.get('/me', authenticate, getMe);
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);

export default router;