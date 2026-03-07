import prisma from '../config/prisma.js';

export const createUser = async (req, res) => {
    try {
        const { uid, name, email, role, phone } = req.body;

        if (!uid) {
            return res.status(400).json({ error: 'uid is required' });
        }

        const newUser = await prisma.users.create({
            data: {
                uid,
                name,
                email,
                role: role || 'USER',
                phone,
            },
        });

        res.status(201).json(newUser);
    } catch (err) {
        console.error("Create user error:", err);
        if (err.code === 'P2002') {
            res.status(400).json({
                error: "Email or uid already exists",
            });
        } else {
            res.status(500).json({
                error: err.message || "Unknown error",
            });
        }
    }
};

export const updateUser = async (req, res) => {
    const { id } = req.params;
    const { name, email, role, phone } = req.body;

    try {
        const updatedUser = await prisma.users.update({
            where: { uid: id }, 
            data: { name, email, role, phone },
        });

        res.status(200).json(updatedUser);
    } catch (err) {
        console.error("Update user error:", err);
        res.status(500).json({ error: err.message || "Unknown error" });
    }
}; 

export const getUser = async (req, res) => {
    const { id } = req.params;
    
    try {
        const user = await prisma.users.findUnique({
            where: { uid: id }, 
        });

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        res.status(200).json(user);
    } catch (err) {
        console.error("Get user error:", err);
        res.status(500).json({ error: err.message || "Unknown error" });
    }
};
