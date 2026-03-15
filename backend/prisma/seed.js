import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('--- Starting Seeding Process ---');

  // 1. Create Categories
  const categoriesData = [
    { name: 'Burger', icon_url: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png' },
    { name: 'Pizza', icon_url: 'https://cdn-icons-png.flaticon.com/512/3132/3132693.png' },
    { name: 'Salad', icon_url: 'https://cdn-icons-png.flaticon.com/512/3766/3766099.png' },
    { name: 'Sushi', icon_url: 'https://cdn-icons-png.flaticon.com/512/2254/2254504.png' },
    { name: 'Coffee', icon_url: 'https://cdn-icons-png.flaticon.com/512/2935/2935327.png' },
    { name: 'Dessert', icon_url: 'https://cdn-icons-png.flaticon.com/512/2515/2515231.png' },
    { name: 'Chicken', icon_url: 'https://cdn-icons-png.flaticon.com/512/3144/3144467.png' },
  ];

  const categories = {};
  for (const cat of categoriesData) {
    const created = await prisma.categories.upsert({
      where: { name: cat.name },
      update: cat,
      create: cat,
    });
    categories[cat.name] = created;
  }
  console.log('✅ Categories seeded');

  // 2. Create Restaurant Owners (Users)
  const ownersData = [
    { uid: 'owner_1_uid', name: 'Nguyen Van A', email: 'owner1@example.com', role: 'RESTAURANT', phone: '0901234561' },
    { uid: 'owner_2_uid', name: 'Tran Thi B', email: 'owner2@example.com', role: 'RESTAURANT', phone: '0901234562' },
  ];

  for (const owner of ownersData) {
    await prisma.users.upsert({
      where: { email: owner.email },
      update: owner,
      create: owner,
    });
  }
  console.log('✅ Restaurant owners seeded');

  // 3. Create Restaurants
  const restaurantsData = [
    {
      user_uid: 'owner_1_uid',
      restaurant_name: 'Burger King Hanoi',
      address: '123 Kim Ma, Ba Dinh, Hanoi',
      latitude: 21.0307,
      longitude: 105.8194,
      phone: '0241234567',
      is_open: true,
      rating: 4.5,
      rating_count: 120,
    },
    {
      user_uid: 'owner_1_uid',
      restaurant_name: 'Pizza Hut Cầu Giấy',
      address: '45 Xuan Thuy, Cau Giay, Hanoi',
      latitude: 21.0362,
      longitude: 105.7828,
      phone: '0247654321',
      is_open: true,
      rating: 4.2,
      rating_count: 85,
    },
    {
      user_uid: 'owner_2_uid',
      restaurant_name: 'Sushi Bar Da Nang',
      address: '99 Vo Nguyen Giap, Da Nang',
      latitude: 16.0544,
      longitude: 108.2022,
      phone: '0236123456',
      is_open: true,
      rating: 4.8,
      rating_count: 200,
    },
  ];

  const restaurants = [];
  for (const res of restaurantsData) {
    const created = await prisma.restaurants.create({
      data: res,
    });
    restaurants.push(created);
  }
  console.log('✅ Restaurants seeded');

  // 4. Create Foods
  const foodsData = [
    // Burger King Foods
    {
      restaurant_id: restaurants[0].id,
      category_id: categories['Burger'].id,
      name: 'Whopper Jr.',
      description: 'The iconic Whopper in a smaller size.',
      price: 5.99,
      image_url: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800',
    },
    {
      restaurant_id: restaurants[0].id,
      category_id: categories['Burger'].id,
      name: 'Bacon King',
      description: 'Two flame-grilled beef patties with crispy bacon.',
      price: 8.99,
      image_url: 'https://images.unsplash.com/photo-1553979459-d2229ba7443b?auto=format&fit=crop&q=80&w=800',
    },
    {
      restaurant_id: restaurants[0].id,
      category_id: categories['Chicken'].id,
      name: 'Crispy Chicken Sandwich',
      description: 'Seasoned white meat chicken filleted and breaded.',
      price: 6.49,
      image_url: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&q=80&w=800',
    },
    // Pizza Hut Foods
    {
      restaurant_id: restaurants[1].id,
      category_id: categories['Pizza'].id,
      name: 'Pepperoni Lovers',
      description: 'Pepperoni, tomato sauce, and mozzarella cheese.',
      price: 12.99,
      image_url: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=800',
    },
    {
      restaurant_id: restaurants[1].id,
      category_id: categories['Pizza'].id,
      name: 'Veggie Supreme',
      description: 'Mushrooms, green peppers, onions, tomatoes, and olives.',
      price: 11.99,
      image_url: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?auto=format&fit=crop&q=80&w=800',
    },
    // Sushi Bar Foods
    {
      restaurant_id: restaurants[2].id,
      category_id: categories['Sushi'].id,
      name: 'Salmon Nigiri',
      description: 'Fresh salmon slices on top of vinegared rice.',
      price: 14.50,
      image_url: 'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?auto=format&fit=crop&q=80&w=800',
    },
    {
      restaurant_id: restaurants[2].id,
      category_id: categories['Sushi'].id,
      name: 'California Roll',
      description: 'Crab, avocado, and cucumber wrapped in seaweed and rice.',
      price: 10.99,
      image_url: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?auto=format&fit=crop&q=80&w=800',
    },
  ];

  for (const food of foodsData) {
    await prisma.foods.create({
      data: food,
    });
  }
  console.log('✅ Foods seeded');

  console.log('--- Seeding Completed Successfully ---');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
