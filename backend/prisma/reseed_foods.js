import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function fetchMeals(category) {
  const res = await fetch(`https://www.themealdb.com/api/json/v1/1/filter.php?c=${category}`);
  const data = await res.json();
  return data.meals || [];
}

async function main() {
  console.log('--- Starting Food Reseed Process ---');

  // 1. Delete dependent data first to avoid foreign key errors
  console.log('Deleting cart_items...');
  await prisma.cart_items.deleteMany();
  console.log('Deleting favorites...');
  await prisma.favorites.deleteMany();
  console.log('Deleting order_items...');
  await prisma.order_items.deleteMany();
  console.log('Deleting food_options & groups...');
  await prisma.food_options.deleteMany();
  await prisma.food_option_groups.deleteMany();
  console.log('Deleting foods...');
  await prisma.foods.deleteMany();

  // 2. Fetch existing restaurants and categories
  const restaurants = await prisma.restaurants.findMany();
  const categories = await prisma.categories.findMany();

  if (restaurants.length === 0) {
    console.error('No restaurants found. Please run seed.js first.');
    return;
  }

  // Create a map to try to map TheMealDB categories to our DB categories
  const categoryMap = {};
  for (const c of categories) {
    categoryMap[c.name.toLowerCase()] = c.id;
  }
  
  // A mapping of our db categories to TheMealDB category names
  const apiCategories = ['Chicken', 'Dessert', 'Beef', 'Seafood', 'Pasta'];
  
  const foodsToInsert = [];

  for (const apiCat of apiCategories) {
    console.log(`Fetching meals for ${apiCat}...`);
    const meals = await fetchMeals(apiCat);
    
    // Only take top 5 meals from each category
    const topMeals = meals.slice(0, 5);

    for (const meal of topMeals) {
      // Find a random restaurant
      const randomRestaurant = restaurants[Math.floor(Math.random() * restaurants.length)];
      
      // Try to find matching category, otherwise just use a random one or the first one
      let categoryId = categoryMap[apiCat.toLowerCase()];
      if (!categoryId) {
        categoryId = categories[Math.floor(Math.random() * categories.length)].id;
      }

      // Random price between 5 and 25
      const price = parseFloat((Math.random() * 20 + 5).toFixed(2));

      foodsToInsert.push({
        restaurant_id: randomRestaurant.id,
        category_id: categoryId,
        name: meal.strMeal,
        description: `Delicious ${meal.strMeal} prepared fresh!`,
        price: price,
        image_url: meal.strMealThumb, // Reliable image from TheMealDB
        is_available: true,
      });
    }
  }

  console.log(`Creating ${foodsToInsert.length} new foods...`);
  
  for (const food of foodsToInsert) {
    await prisma.foods.create({
      data: food,
    });
  }

  console.log('✅ Foods successfully reseeded with reliable images!');
  console.log('--- Reseed Process Completed ---');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
