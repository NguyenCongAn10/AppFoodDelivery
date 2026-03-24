import prisma from '../config/prisma.js';

// GET /foods (public)
export const getFoods = async (req, res) => {
    try {
        const { category_id } = req.query;
        let whereClause = {
            restaurants: { is_open: true }
        };

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
        let { restaurant_id, name, description, price, image_url, category_id, option_groups } = req.body;
        
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
                category_id: category_id ? parseInt(category_id, 10) : null,
                option_groups: option_groups && Array.isArray(option_groups) ? {
                    create: option_groups.map(g => ({
                        name: g.name,
                        is_required: g.is_required || false,
                        selection_type: g.selection_type || 'SINGLE',
                        options: {
                            create: g.options?.map(o => ({
                                name: o.name,
                                price: parseFloat(o.price || 0),
                                description: o.description,
                                image_url: o.image_url
                            })) || []
                        }
                    }))
                } : undefined
            },
            include: {
                option_groups: {
                    include: { options: true }
                }
            }
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

        const option_groups = data.option_groups;
        delete data.option_groups;

        if (data.price !== undefined) data.price = parseFloat(data.price);
        if (data.category_id !== undefined) data.category_id = parseInt(data.category_id, 10) || null;
        if (data.restaurant_id) delete data.restaurant_id;

        if (option_groups && Array.isArray(option_groups)) {
            await prisma.$transaction(async (tx) => {
                await tx.food_option_groups.deleteMany({
                    where: { food_id: foodId }
                });

                await tx.foods.update({
                    where: { id: foodId },
                    data: {
                        ...data,
                        option_groups: {
                            create: option_groups.map(g => ({
                                name: g.name,
                                is_required: g.is_required || false,
                                selection_type: g.selection_type || 'SINGLE',
                                options: {
                                    create: g.options?.map(o => ({
                                        name: o.name,
                                        price: parseFloat(o.price || 0),
                                        description: o.description,
                                        image_url: o.image_url
                                    })) || []
                                }
                            }))
                        }
                    }
                });
            });
        } else {
            if (Object.keys(data).length > 0) {
                await prisma.foods.update({
                    where: { id: foodId },
                    data,
                });
            }
        }

        const updatedFood = await prisma.foods.findUnique({
            where: { id: foodId },
            include: {
                option_groups: {
                    include: { options: true }
                }
            }
        });
        res.json(updatedFood);
    } catch (err) {
        console.error('Update food error:', err);
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