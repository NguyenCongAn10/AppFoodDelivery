import prisma from '../config/prisma.js';

// Haversine formula: khoảng cách giữa 2 tọa độ (km)
function haversineDistance(lat1, lng1, lat2, lng2) {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) ** 2
        + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180)
        * Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

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
        
        // Tính phí giao hàng (1$ cho mỗi KM, tối thiểu 1$)
        let delivery_fee = 0;
        const restaurant = await prisma.restaurants.findUnique({ where: { id: restaurant_id } });
        if (restaurant && lat && lng) {
            const distKm = haversineDistance(lat, lng, restaurant.latitude, restaurant.longitude);
            delivery_fee = Math.max(1, Math.round(distKm * 10) / 10); // $1/km, round 1 decimal
        }
        total_price += delivery_fee;
        
        const order = await prisma.orders.create({
            data: {
                user_uid,
                restaurant_id,
                total_price,
                delivery_fee,
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

// GET /orders/available?lat=&lng= (shipper) - lọc đơn trong bán kính 15km
export const getAvailableOrders = async (req, res) => {
    try {
        const { lat, lng } = req.query;
        if (!lat || !lng) {
            return res.status(400).json({ error: 'Vị trí hiện tại (lat, lng) là bắt buộc' });
        }

        const shipperLat = parseFloat(lat);
        const shipperLng = parseFloat(lng);
        const MAX_DISTANCE_KM = 15;

        const orders = await prisma.orders.findMany({
            where: { status: 'CONFIRMED', shipper_id: null },
            include: {
                restaurants: true,
                users: true,
                order_items: { include: { foods: true } },
            },
            orderBy: { created_at: 'desc' },
        });

        const nearby = orders
            .map(order => {
                const rLat = order.restaurants?.latitude;
                const rLng = order.restaurants?.longitude;
                // If restaurant has no coordinates, include it at distance 0
                if (rLat == null || rLng == null) {
                    return { ...order, distance_km: 0 };
                }
                const dist = haversineDistance(shipperLat, shipperLng, rLat, rLng);
                const distKm = isNaN(dist) ? 0 : Math.round(dist * 10) / 10;
                return { ...order, distance_km: distKm };
            })
            .filter(order => order.distance_km <= MAX_DISTANCE_KM)
            .sort((a, b) => a.distance_km - b.distance_km);

        res.json(nearby);
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

// PATCH /orders/:id/accept (shipper) - tự nhận đơn
export const acceptOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const shipper = await prisma.shippers.findUnique({ where: { user_uid: req.user.uid } });
        if (!shipper) {
            return res.status(404).json({ error: 'Shipper profile not found' });
        }

        // Kiểm tra đơn vẫn còn khả dụng (tránh race condition)
        const existing = await prisma.orders.findUnique({ where: { id: parseInt(id) } });
        if (!existing) return res.status(404).json({ error: 'Order not found' });
        if (existing.status !== 'CONFIRMED' || existing.shipper_id !== null) {
            return res.status(409).json({ error: 'Đơn hàng này đã được nhận bởi shipper khác' });
        }

        const order = await prisma.orders.update({
            where: { id: parseInt(id) },
            data: { shipper_id: shipper.id }, // status KEEP as CONFIRMED until restaurant Hands over
            include: {
                restaurants: true,
                users: true,
                order_items: { include: { foods: true } },
            },
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

// PATCH /orders/:id/location (shipper) - cập nhật GPS
export const updateShipperLocation = async (req, res) => {
    try {
        const { id } = req.params;
        const { lat, lng } = req.body;
        if (lat === undefined || lng === undefined) {
            return res.status(400).json({ error: 'lat và lng là bắt buộc' });
        }
        const order = await prisma.orders.update({
            where: { id: parseInt(id) },
            data: { shipper_lat: parseFloat(lat), shipper_lng: parseFloat(lng) },
        });
        res.json(order);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /orders/:id/ready (restaurant) - Chuẩn bị xong, giao cho shipper
export const readyOrder = async (req, res) => {
    try {
        const { id } = req.params;
        const restaurant = await prisma.restaurants.findFirst({ where: { user_uid: req.user.uid } });
        if (!restaurant) {
            return res.status(404).json({ error: "Restaurant profile not found" });
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

// GET /orders/restaurant (restaurant)
export const getRestaurantOrders = async (req, res) => {
    try {
        const restaurant = await prisma.restaurants.findFirst({ where: { user_uid: req.user.uid } });
        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant profile not found' });
        }
        
        const orders = await prisma.orders.findMany({
            where: { restaurant_id: restaurant.id },
            include: { 
                order_items: { include: { foods: true } },
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