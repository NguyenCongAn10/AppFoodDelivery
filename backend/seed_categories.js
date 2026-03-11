import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const categories = [
    { name: 'Burger', icon_url: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png' },
    { name: 'Pizza', icon_url: 'https://cdn-icons-png.flaticon.com/512/3132/3132693.png' },
    { name: 'Salad', icon_url: 'https://cdn-icons-png.flaticon.com/512/3766/3766099.png' },
    { name: 'Sushi', icon_url: 'https://cdn-icons-png.flaticon.com/512/2254/2254504.png' },
    { name: 'Coffee', icon_url: 'https://cdn-icons-png.flaticon.com/512/2935/2935327.png' },
  ];

  for (const cat of categories) {
    await prisma.categories.upsert({
      where: { name: cat.name },
      update: {},
      create: cat,
    });
  }
  console.log('Categories seeded!');
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
