import prisma from '../config/prisma.js';

// GET /api/restaurants/:id
export const getRestaurantById = async (req, res) => {
    try {
        const restaurantId = parseInt(req.params.id);

        if (isNaN(restaurantId)) {
            return res.status(400).json({ error: 'Invalid restaurant ID' });
        }

        // Fetch restaurant with its foods and their categories
        const restaurant = await prisma.restaurants.findUnique({
            where: { id: restaurantId },
            include: {
                foods: {
                    where: { is_available: true },
                    include: {
                        categories: true,
                        option_groups: {
                            include: { options: true }
                        }
                    },
                },
            },
        });

        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        // Group foods by category
        const groupedFoods = {};
        const othersCategory = "Others";

        restaurant.foods.forEach((food) => {
            const categoryName = food.categories?.name || othersCategory;
            if (!groupedFoods[categoryName]) {
                groupedFoods[categoryName] = [];
            }
            groupedFoods[categoryName].push({
                id: food.id,
                restaurant_id: food.restaurant_id,
                name: food.name,
                description: food.description,
                price: parseFloat(food.price),
                image_url: food.image_url,
                is_available: food.is_available,
                category_id: food.category_id,
                category_name: food.categories?.name,
                option_groups: food.option_groups,
            });
        });

        // Convert grouped object to array format for easier consumption in frontend
        const menuCategories = Object.keys(groupedFoods).map(categoryName => {
            return {
                category_name: categoryName,
                foods: groupedFoods[categoryName]
            };
        });

        // Construct final response object
        const responseData = {
            id: restaurant.id,
            name: restaurant.restaurant_name,
            address: restaurant.address,
            rating: restaurant.rating ? parseFloat(restaurant.rating) : 0,
            image_url: restaurant.image_url,
            latitude: restaurant.latitude,
            longitude: restaurant.longitude,
            menu: menuCategories
        };

        res.json(responseData);
    } catch (error) {
        console.error('Error fetching restaurant detail:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// POST /shippers/register
export const registerRestaurant = async (req, res) => {
    try {
        const { restaurant_name, address, latitude, longitude, phone } = req.body;
        const user_uid = req.user.uid;

        const result = await prisma.$transaction(async (tx) => {
            // 1. Create restaurant record
            const restaurant = await tx.restaurants.create({
                data: {
                    user_uid,
                    restaurant_name,
                    address,
                    latitude: latitude || 0,
                    longitude: longitude || 0,
                    phone,
                    image_url: "https://via.placeholder.com/150", // Default image
                },
            });

            // 2. Update user role
            await tx.users.update({
                where: { uid: user_uid },
                data: { role: 'RESTAURANT' },
            });

            return restaurant;
        });

        res.status(201).json(result);
    } catch (err) {
        console.error('Register restaurant error:', err);
        res.status(500).json({ error: err.message });
    }
};

// GET /api/restaurants/me
export const getMyRestaurant = async (req, res) => {
    try {
        const user_uid = req.user.uid;
        const restaurant = await prisma.restaurants.findFirst({
            where: { user_uid },
            include: {
                foods: {
                    include: {
                        categories: true,
                        option_groups: {
                            include: { options: true }
                        }
                    },
                },
            },
        });

        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        res.json(restaurant);
    } catch (error) {
        console.error('Error fetching my restaurant:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// PATCH /api/restaurants/me/status
export const updateRestaurantStatus = async (req, res) => {
    try {
        const { is_open } = req.body;
        const user_uid = req.user.uid;

        const restaurant = await prisma.restaurants.findFirst({ where: { user_uid } });
        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        const updated = await prisma.restaurants.update({
            where: { id: restaurant.id },
            data: { is_open },
        });

        res.json(updated);
    } catch (err) {
        console.error('Update restaurant status error:', err);
        res.status(500).json({ error: err.message });
    }
};

// PATCH /api/restaurants/me
export const updateMyRestaurant = async (req, res) => {
    try {
        const { restaurant_name, address, phone, latitude, longitude } = req.body;
        const user_uid = req.user.uid;

        const restaurant = await prisma.restaurants.findFirst({ where: { user_uid } });
        if (!restaurant) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        const updated = await prisma.restaurants.update({
            where: { id: restaurant.id },
            data: {
                restaurant_name: restaurant_name !== undefined ? restaurant_name : restaurant.restaurant_name,
                address: address !== undefined ? address : restaurant.address,
                phone: phone !== undefined ? phone : restaurant.phone,
                latitude: latitude !== undefined ? latitude : restaurant.latitude,
                longitude: longitude !== undefined ? longitude : restaurant.longitude,
            },
        });

        res.json(updated);
    } catch (err) {
        console.error('Update restaurant profile error:', err);
        res.status(500).json({ error: err.message });
    }
};
