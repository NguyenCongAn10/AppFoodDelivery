import prisma from '../config/prisma.js';

// POST /shippers/register
export const registerShipper = async (req, res) => {
    try {
        const { phone, vehicle_name, license_plate } = req.body;
        const user_uid = req.user.uid;
        
        const result = await prisma.$transaction(async (tx) => {
            // 1. Create shipper record
            const shipper = await tx.shippers.create({
                data: { 
                    user_uid, 
                    phone, 
                    vehicle_name, 
                    license_plate 
                },
            });

            // 2. Update user role
            await tx.users.update({
                where: { uid: user_uid },
                data: { role: 'SHIPPER' },
            });

            return shipper;
        });

        res.status(201).json(result);
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

// GET /shippers/me/dashboard
export const getShipperDashboard = async (req, res) => {
    try {
        const shipper = await prisma.shippers.findUnique({
            where: { user_uid: req.user.uid },
        });

        if (!shipper) {
            return res.status(404).json({ error: 'Shipper not found' });
        }

        const completedOrders = await prisma.orders.findMany({
            where: { shipper_id: shipper.id, status: 'COMPLETED' },
            orderBy: { created_at: 'desc' },
            include: { restaurants: true, users: true }
        });

        // Sum delivery_fee
        const totalEarnings = completedOrders.reduce((sum, order) => sum + Number(order.delivery_fee || 0), 0);
        const totalDeliveries = completedOrders.length;
        
        // Lấy top 20 đơn giao gần nhất
        const recentDeliveries = completedOrders.slice(0, 20);

        res.json({
            total_earnings: totalEarnings,
            total_deliveries: totalDeliveries,
            recent_deliveries: recentDeliveries
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};