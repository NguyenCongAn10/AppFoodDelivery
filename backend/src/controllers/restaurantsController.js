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
