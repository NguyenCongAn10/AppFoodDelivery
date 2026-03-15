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

// POST /foods (admin)
export const createFood = async (req, res) => {
    try {
        const { restaurant_id, name, description, price, image_url } = req.body;
        const food = await prisma.foods.create({
            data: { restaurant_id, name, description, price, image_url },
        });
        res.status(201).json(food);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// PATCH /foods/:id (admin)
export const updateFood = async (req, res) => {
    try {
        const { id } = req.params;
        const data = req.body;
        const food = await prisma.foods.update({
            where: { id },
            data,
        });
        res.json(food);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// DELETE /foods/:id (admin)
export const deleteFood = async (req, res) => {
    try {
        const { id } = req.params;
        await prisma.foods.delete({ where: { id } });
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};