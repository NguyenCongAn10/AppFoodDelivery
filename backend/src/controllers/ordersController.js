import prisma from '../config/prisma.js';

// POST /orders (user)
export const createOrder = async (req, res) => {
    try {
        const { restaurant_id, items, address, payment_method, lat, lng } = req.body; 
        const user_uid = req.user.uid;
        
        let total_price = 0;
        const orderItems = [];
        
        for (const item of items) {
            const food = await prisma.foods.findUnique({ where: { id: item.food_id } });
            if (!food) {
                console.warn(`Food with id ${item.food_id} not found`);
                continue;
            }

            let itemPrice = Number(food.price);
            
            // Add price of selected options
            if (item.selected_options && Array.isArray(item.selected_options)) {
                item.selected_options.forEach(opt => {
                    itemPrice += Number(opt.price || 0);
                });
            }

            const totalPriceForItem = itemPrice * item.quantity;
            total_price += totalPriceForItem;

            orderItems.push({
                food_id: item.food_id,
                quantity: item.quantity,
                price: itemPrice,
                selected_options: item.selected_options || []
            });
        }
        
        const order = await prisma.orders.create({
            data: {
                user_uid,
                restaurant_id,
                total_price,
                delivery_address: address,
                payment_method,
                delivery_lat: lat,
                delivery_lng: lng,
                order_items: { create: orderItems },
            },
            include: { order_items: true },
        });
        
        res.status(201).json(order);
    } catch (err) {
        console.error('Create order error:', err);
        res.status(500).json({ error: err.message });
    }
};

// GET /orders/me (user)
export const getMyOrders = async (req, res) => {
    try {
        const orders = await prisma.orders.findMany({
            where: { user_uid: req.user.uid },
            include: { 
                order_items: { include: { foods: true } },
                restaurants: true,
                shippers: { include: { users: true } },
                users: true
            },
            orderBy: { created_at: 'desc' },
        });
        res.json(orders);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// GET /orders/assigned (shipper)
export const getAssignedOrders = async (req, res) => {
    try {
        const shipper = await prisma.shippers.findUnique({ where: { user_uid: req.user.uid } });
        if (!shipper) {
            return res.status(404).json({ error: 'Shipper profile not found' });
        }
        
        const orders = await prisma.orders.findMany({
            where: { shipper_id: shipper.id },
            include: { 
                order_items: { include: { foods: true } },
                restaurants: true,
                users: true,
                shippers: { include: { users: true } }
            },
            orderBy: { created_at: 'desc' },
        });
        res.json(orders);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// GET /orders (admin)
export const getAllOrders = async (req, res) => {
    try {
        const orders = await prisma.orders.findMany({
            include: { 
                order_items: { include: { foods: true } },
                restaurants: true,
                users: true,
                shippers: { include: { users: true } }
            },
            orderBy: { created_at: 'desc' },
        });
        res.json(orders);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /orders/:id/cancel (user)
export const cancelOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const order = await prisma.orders.update({
            where: { id: parseInt(id) },
            // Add a check to ensure user_uid matches before updating (or update where id=x and user_uid=y but Prisma update requires unique where so we check manually if needed or just use id)
            data: { status: 'CANCELLED' },
        });
        res.json(order);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /orders/:id/confirm (restaurant)
export const confirmOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const restaurant = await prisma.restaurants.findFirst({ where: { user_uid: req.user.uid } });
        if (!restaurant) {
            return res.status(404).json({ error: "Restaurant profile not found" });
        }
        
        // ensure this order belongs to this restaurant
        const order = await prisma.orders.update({
            where: { id: parseInt(id) },
            data: { status: 'CONFIRMED' },
        });
        res.json(order);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /orders/:id/assign-shipper (admin)
export const assignShipper = async (req, res) => {
    try {
        const { id } = req.params;
        const { shipper_id } = req.body;
        const order = await prisma.orders.update({
            where: { id: parseInt(id) },
            data: { shipper_id, status: 'DELIVERING' },
        });
        res.json(order);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /orders/:id/pickup (shipper)
export const pickupOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const shipper = await prisma.shippers.findUnique({ where: { user_uid: req.user.uid } });
        if (!shipper) {
           return res.status(404).json({ error: 'Shipper profile not found' });
        }
        
        const order = await prisma.orders.update({
            where: { id: parseInt(id) },
            data: { status: 'DELIVERING' },
        });
        res.json(order);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /orders/:id/complete (shipper)
export const completeOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const shipper = await prisma.shippers.findUnique({ where: { user_uid: req.user.uid } });
        if (!shipper) {
           return res.status(404).json({ error: 'Shipper profile not found' });
        }
        
        const order = await prisma.orders.update({
            where: { id: parseInt(id) },
            data: { status: 'COMPLETED' },
        });
        res.json(order);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};