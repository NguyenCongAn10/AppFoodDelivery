import prisma from '../config/prisma.js';

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