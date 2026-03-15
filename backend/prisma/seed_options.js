import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding food options...');

  // Get all foods
  const foods = await prisma.foods.findMany();

  for (const food of foods) {
    // 1. Add "Choose Size" (SINGLE selection)
    const sizeGroup = await prisma.food_option_groups.create({
      data: {
        food_id: food.id,
        name: 'Choose Size',
        is_required: true,
        selection_type: 'SINGLE',
        options: {
          create: [
            { name: 'Small', price: 0, description: '10"' },
            { name: 'Medium', price: 2, description: '12"' },
            { name: 'Large', price: 4, description: '14"' },
          ],
        },
      },
    });

    // 2. Add "Extra Toppings" (MULTIPLE selection)
    const toppingGroup = await prisma.food_option_groups.create({
      data: {
        food_id: food.id,
        name: 'Extra Toppings',
        is_required: false,
        selection_type: 'MULTIPLE',
        options: {
          create: [
            { name: 'Extra Cheese', price: 1.5, image_url: 'https://cdn-icons-png.flaticon.com/512/2153/2153702.png' },
            { name: 'Black Olives', price: 0.75, image_url: 'https://cdn-icons-png.flaticon.com/512/8201/8201413.png' },
            { name: 'Red Onions', price: 0.5, image_url: 'https://cdn-icons-png.flaticon.com/512/727/727393.png' },
            { name: 'Bacon', price: 2.0, image_url: 'https://cdn-icons-png.flaticon.com/512/1582/1582144.png' },
            { name: 'Mushrooms', price: 1.0, image_url: 'https://cdn-icons-png.flaticon.com/512/1790/1790387.png' },
          ],
        },
      },
    });
  }

  console.log('Seeding completed!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
