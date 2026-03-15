import admin from 'firebase-admin';
import prisma from '../config/prisma.js';

if (!admin.apps.length) {
    admin.initializeApp({
        projectId: 'fooddelivery-f00aa',
    });
}

export const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'No token provided' });
        }

        const idToken = authHeader.split('Bearer ')[1];
        const decoded = await admin.auth().verifyIdToken(idToken);
        const uid = decoded.uid;

        // Lookup user in DB by uid
        const user = await prisma.users.findUnique({ where: { uid } });
        if (!user) {
            return res.status(401).json({ error: 'User not found in database. Please register first.' });
        }

        req.user = { id: user.id, uid: user.uid, role: user.role };
        next();
    } catch (err) {
        console.error('Auth error:', err.message);
        return res.status(401).json({ error: 'Invalid or expired token' });
    }
};

export const authorize = (roles) => (req, res, next) => {
    if (!roles.includes(req.user.role)) {
        return res.status(403).json({ error: 'Forbidden' });
    }
    next();
};