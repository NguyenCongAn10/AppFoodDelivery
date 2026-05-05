import prisma from '../config/prisma.js';
import { sendOtpEmail } from '../config/mailer.js';

// ── In-memory store cho pre-registration OTP ─────────────────────────────────
// Map<email, { otp: string, expiry: Date }>
const preRegisterOtpStore = new Map();

// POST /auth/send-pre-register-otp  (không cần user tồn tại trước)
export const sendPreRegisterOtp = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ error: 'Email is required' });

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const expiry = new Date(Date.now() + 5 * 60 * 1000); // 5 phút

        preRegisterOtpStore.set(email, { otp, expiry });

        // Tự dọn sau 5 phút
        setTimeout(() => preRegisterOtpStore.delete(email), 5 * 60 * 1000);

        await sendOtpEmail(email, otp);
        res.json({ message: 'OTP sent successfully' });
    } catch (err) {
        console.error('sendPreRegisterOtp error:', err);
        res.status(500).json({ error: err.message });
    }
};

// POST /auth/verify-pre-register-otp
export const verifyPreRegisterOtp = async (req, res) => {
    try {
        const { email, otp } = req.body;
        if (!email || !otp) return res.status(400).json({ error: 'Email and OTP are required' });

        const record = preRegisterOtpStore.get(email);
        if (!record) return res.status(400).json({ error: 'OTP not found or expired' });

        if (record.otp !== otp) return res.status(400).json({ error: 'Invalid OTP' });
        if (new Date() > record.expiry) {
            preRegisterOtpStore.delete(email);
            return res.status(400).json({ error: 'OTP expired' });
        }

        preRegisterOtpStore.delete(email); // Xóa sau khi verify thành công
        res.json({ message: 'OTP verified successfully' });
    } catch (err) {
        console.error('verifyPreRegisterOtp error:', err);
        res.status(500).json({ error: err.message });
    }
};


// POST /auth/login
export const login = async (req, res) => {
    try {
        const { email, password } = req.body; 
        const user = await prisma.users.findUnique({ where: { email } });
        if (!user) return res.status(401).json({ error: 'Invalid credentials' });
        // TODO: Generate JWT token
        res.json({ token: 'fake-token', user });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// GET /me
export const getMe = async (req, res) => {
    try {
        const user = await prisma.users.findUnique({ where: { uid: req.user.uid } });
        res.json(user);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// POST /auth/send-otp
export const sendOtp = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) return res.status(400).json({ error: 'Email is required' });

        const user = await prisma.users.findUnique({ where: { email } });
        if (!user) return res.status(404).json({ error: 'User not found' });

        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const expiry = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

        await prisma.users.update({
            where: { email },
            data: {
                otp_code: otp,
                otp_expiry: expiry
            }
        });

        await sendOtpEmail(email, otp);

        res.json({ message: 'OTP sent successfully' });
    } catch (err) {
        console.error("Send OTP error:", err);
        res.status(500).json({ error: err.message });
    }
};

// POST /auth/verify-otp
export const verifyOtp = async (req, res) => {
    try {
        const { email, otp } = req.body;
        if (!email || !otp) return res.status(400).json({ error: 'Email and OTP are required' });

        const user = await prisma.users.findUnique({ where: { email } });
        if (!user) return res.status(404).json({ error: 'User not found' });

        if (user.otp_code !== otp) {
            return res.status(400).json({ error: 'Invalid OTP' });
        }

        if (new Date() > user.otp_expiry) {
            return res.status(400).json({ error: 'OTP expired' });
        }

        // Clear OTP after success
        await prisma.users.update({
            where: { email },
            data: {
                otp_code: null,
                otp_expiry: null
            }
        });

        res.json({ message: 'OTP verified successfully' });
    } catch (err) {
        console.error("Verify OTP error:", err);
        res.status(500).json({ error: err.message });
    }
};