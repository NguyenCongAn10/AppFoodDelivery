import prisma from '../config/prisma.js';

// POST /shippers/register
export const registerShipper = async (req, res) => {
    try {
        const { phone, vehicle_name, license_plate } = req.body;
        const user_uid = req.user.uid;
        
        const shipper = await prisma.shippers.create({
            data: { 
                user_uid, 
                phone, 
                vehicle_name, 
                license_plate 
            },
        });
        res.status(201).json(shipper);
    } catch (err) {
        if (err.code === 'P2002') {
            res.status(400).json({ error: 'License plate or user already registered as shipper' });
        } else {
            res.status(500).json({ error: err.message });
        }
    }
};

// GET /shippers/me
export const getMyShipper = async (req, res) => {
    try {
        const shipper = await prisma.shippers.findUnique({
            where: { user_uid: req.user.uid },
        });
        res.json(shipper);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /shippers/me
export const updateMyShipper = async (req, res) => {
    try {
        const data = req.body;
        const shipper = await prisma.shippers.update({
            where: { user_uid: req.user.uid },
            data,
        });
        res.json(shipper);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};