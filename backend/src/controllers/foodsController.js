import prisma from '../config/prisma.js';

// GET /foods (public)
export const getFoods = async (req, res) => {
    try {
        const { category_id } = req.query;
        let whereClause = {};

        if (category_id) {
            whereClause.category_id = parseInt(category_id, 10);
        }

        const foods = await prisma.foods.findMany({
            where: whereClause,
            include: {
                restaurants: true,
                categories: true,
                option_groups: {
                    include: {
                        options: true
                    }
                }
            },
        });
        res.json(foods);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// POST /foods (admin or restaurant)
export const createFood = async (req, res) => {
    try {
        let { restaurant_id, name, description, price, image_url, category_id } = req.body;
        
        if (req.user.role === 'RESTAURANT') {
            const restaurant = await prisma.restaurants.findFirst({
                where: { user_uid: req.user.uid }
            });
            if (!restaurant) {
                return res.status(403).json({ error: 'Restaurant profile not found' });
            }
            restaurant_id = restaurant.id;
        }

        const food = await prisma.foods.create({
            data: { 
                restaurant_id: parseInt(restaurant_id, 10), 
                name, 
                description, 
                price: parseFloat(price), 
                image_url,
                category_id: category_id ? parseInt(category_id, 10) : null
            },
        });
        res.status(201).json(food);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /foods/:id (admin or restaurant)
export const updateFood = async (req, res) => {
    try {
        const { id } = req.params;
        const data = req.body;
        const foodId = parseInt(id, 10);

        if (req.user.role === 'RESTAURANT') {
            const restaurant = await prisma.restaurants.findFirst({
                where: { user_uid: req.user.uid }
            });
            const food = await prisma.foods.findUnique({
                where: { id: foodId }
            });

            if (!food || food.restaurant_id !== restaurant.id) {
                return res.status(403).json({ error: 'Forbidden: You do not own this food item' });
            }
        }

        if (data.price) data.price = parseFloat(data.price);
        if (data.category_id) data.category_id = parseInt(data.category_id, 10);
        if (data.restaurant_id) delete data.restaurant_id;

        const updatedFood = await prisma.foods.update({
            where: { id: foodId },
            data,
        });
        res.json(updatedFood);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// DELETE /foods/:id (admin or restaurant)
export const deleteFood = async (req, res) => {
    try {
        const { id } = req.params;
        const foodId = parseInt(id, 10);

        if (req.user.role === 'RESTAURANT') {
            const restaurant = await prisma.restaurants.findFirst({
                where: { user_uid: req.user.uid }
            });
            const food = await prisma.foods.findUnique({
                where: { id: foodId }
            });

            if (!food || food.restaurant_id !== restaurant.id) {
                return res.status(403).json({ error: 'Forbidden: You do not own this food item' });
            }
        }

        await prisma.foods.delete({ where: { id: foodId } });
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};