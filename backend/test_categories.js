import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
    const categories = await prisma.categories.findMany();
    console.log(JSON.stringify(categories, null, 2));
}
main().catch(e => console.error(e)).finally(() => prisma.$disconnect());
