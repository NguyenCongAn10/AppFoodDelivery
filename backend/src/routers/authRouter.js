import express from 'express';
import { login, getMe, sendOtp, verifyOtp, sendPreRegisterOtp, verifyPreRegisterOtp } from '../controllers/authController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.post('/login', login);
router.get('/me', authenticate, getMe);
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtp);
router.post('/send-pre-register-otp', sendPreRegisterOtp);
router.post('/verify-pre-register-otp', verifyPreRegisterOtp);

export default router;