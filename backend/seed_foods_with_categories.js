import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    // get first restaurant to link foods to
    let restaurant = await prisma.restaurants.findFirst();
    if (!restaurant) {
        console.log("No restaurant found. Creating a dummy restaurant...");
        
        let dummyUser = await prisma.users.findFirst({ where: { email: "dummy@restaurant.com" } });
        if (!dummyUser) {
            dummyUser = await prisma.users.create({
                data: {
                    uid: "dummy_uid_123",
                    name: "Dummy Owner",
                    email: "dummy@restaurant.com",
                    role: "RESTAURANT",
                }
            });
        }

        restaurant = await prisma.restaurants.create({
            data: {
                user_uid: dummyUser.uid,
                restaurant_name: "The Dummy Kitchen",
                address: "123 Seed Street",
                latitude: 21.028511,
                longitude: 105.804817,
                phone: "0123456789",
            }
        });
        console.log("Created dummy restaurant:", restaurant.name);
    }

    const categories = await prisma.categories.findMany();
    if (categories.length === 0) {
        console.error("No categories found. Cannot link foods properly.");
        return;
    }

    // Helper map
    const catMap = {};
    categories.forEach(c => catMap[c.name.toLowerCase()] = c.id);

    console.log("Categories Map:", catMap);

    const foodsToCreate = [
        {
            name: "Classic Cheeseburger",
            description: "A delicious cheeseburger with cheddar.",
            price: 10.99,
            image_url: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
            category_id: catMap['burger'] || null,
            restaurant_id: restaurant.id,
        },
        {
            name: "Double Bacon Burger",
            description: "Two patties, crispy bacon, and special sauce.",
            price: 14.99,
            image_url: "https://images.unsplash.com/photo-1594212202875-c0528fb4ee8d",
            category_id: catMap['burger'] || null,
            restaurant_id: restaurant.id,
        },
        {
            name: "Margherita Pizza",
            description: "Fresh tomato, mozzarella, and basil.",
            price: 12.99,
            image_url: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002",
            category_id: catMap['pizza'] || null,
            restaurant_id: restaurant.id,
        },
        {
            name: "Pepperoni Passion",
            description: "Loaded with double pepperoni.",
            price: 15.99,
            image_url: "https://images.unsplash.com/photo-1628840042765-356cda07504e",
            category_id: catMap['pizza'] || null,
            restaurant_id: restaurant.id,
        },
        {
            name: "Caesar Salad",
            description: "Crispy romaine, croutons, and Caesar dressing.",
            price: 8.99,
            image_url: "https://images.unsplash.com/photo-1550304943-4f24f54ddde9",
            category_id: catMap['salad'] || null,
            restaurant_id: restaurant.id,
        },
        {
            name: "Spicy Tuna Roll",
            description: "Fresh tuna with spicy mayo.",
            price: 11.99,
            image_url: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c",
            category_id: catMap['sushi'] || null,
            restaurant_id: restaurant.id,
        },
        {
            name: "Iced Caramel Macchiato",
            description: "Espresso, milk, vanilla syrup, and caramel drizzle.",
            price: 5.99,
            image_url: "https://images.unsplash.com/photo-1497935586351-b67a49e012bf",
            category_id: catMap['coffee'] || null,
            restaurant_id: restaurant.id,
        }
    ];

    console.log("Starting to seed foods...");
    let createdCount = 0;
    for (const food of foodsToCreate) {
        // Prevent exact duplicates
        const exists = await prisma.foods.findFirst({ where: { name: food.name } });
        if (!exists) {
            await prisma.foods.create({ data: food });
            createdCount++;
        }
    }

    console.log(`Seeded ${createdCount} new foods!`);
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
