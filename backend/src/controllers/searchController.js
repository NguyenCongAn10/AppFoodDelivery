import prisma from '../config/prisma.js';

const toRadians = (deg) => (deg * Math.PI) / 180;

const calculateDistanceKm = (lat1, lon1, lat2, lon2) => {
    if (
        lat1 == null ||
        lon1 == null ||
        lat2 == null ||
        lon2 == null
    ) {
        return null;
    }

    const R = 6371; // Earth radius in km
    const dLat = toRadians(lat2 - lat1);
    const dLon = toRadians(lon2 - lon1);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRadians(lat1)) *
            Math.cos(toRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
};

export const searchRestaurantsByFood = async (req, res) => {
    try {
        const { q, query, lat, lng } = req.query;
        const searchTerm = (q || query || '').trim();

        if (!searchTerm) {
            return res
                .status(400)
                .json({ error: 'Query parameter "q" hoặc "query" là bắt buộc' });
        }

        const userLat = lat ? parseFloat(lat) : null;
        const userLng = lng ? parseFloat(lng) : null;

        const foods = await prisma.foods.findMany({
            where: {
                is_available: true,
                OR: [
                    {
                        name: {
                            contains: searchTerm,
                            mode: 'insensitive',
                        },
                    },
                    {
                        categories: {
                            name: {
                                contains: searchTerm,
                                mode: 'insensitive',
                            },
                        },
                    },
                    {
                        restaurants: {
                            restaurant_name: {
                                contains: searchTerm,
                                mode: 'insensitive',
                            },
                        },
                    },
                ],
            },
            include: {
                restaurants: true,
            },
        });

        const restaurantMap = new Map();

        for (const food of foods) {
            const restaurant = food.restaurants;
            if (!restaurant) continue;

            const restaurantId = restaurant.id;

            if (!restaurantMap.has(restaurantId)) {
                const distanceKm =
                    userLat != null && userLng != null
                        ? calculateDistanceKm(
                              userLat,
                              userLng,
                              restaurant.latitude,
                              restaurant.longitude
                          )
                        : null;

                restaurantMap.set(restaurantId, {
                    id: restaurant.id,
                    name: restaurant.restaurant_name,
                    rating: restaurant.rating
                        ? Number(restaurant.rating)
                        : 0,
                    rating_count: restaurant.rating_count ?? 0,
                    distance_km: distanceKm,
                    address: restaurant.address,
                    latitude: restaurant.latitude,
                    longitude: restaurant.longitude,
                    image_url: restaurant.image_url || null,
                    matched_foods: [],
                });
            }

            const entry = restaurantMap.get(restaurantId);
            entry.matched_foods.push({
                id: food.id,
                name: food.name,
                price: food.price,
                image_url: food.image_url,
            });
        }

        let results = Array.from(restaurantMap.values());

        results.sort((a, b) => {
            if (a.distance_km != null && b.distance_km != null) {
                return a.distance_km - b.distance_km;
            }
            if (a.distance_km != null) return -1;
            if (b.distance_km != null) return 1;
            return (b.rating || 0) - (a.rating || 0);
        });

        return res.json(results);
    } catch (err) {
        console.error('Error in searchRestaurantsByFood:', err);
        return res.status(500).json({ error: err.message || 'Internal server error' });
    }
};

export const getSearchSuggestions = async (req, res) => {
    try {
        const foods = await prisma.foods.findMany({
            where: {
                is_available: true,
            },
            include: {
                restaurants: true,
            },
            take: 20,
            orderBy: {
                created_at: 'desc',
            },
        });

        return res.json(foods);
    } catch (err) {
        console.error('Error in getSearchSuggestions:', err);
        return res.status(500).json({ error: err.message || 'Internal server error' });
    }
};

