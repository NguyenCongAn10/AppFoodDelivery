import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Get all categories
export const getAllCategories = async (req, res) => {
  try {
    const categories = await prisma.categories.findMany({
      orderBy: { created_at: 'desc' },
    });
    res.json(categories);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
};

// Create a new category (admin/internal use typically)
export const createCategory = async (req, res) => {
  try {
    const { name, icon_url } = req.body;
    
    if (!name) {
      return res.status(400).json({ error: 'Category name is required' });
    }

    const newCategory = await prisma.categories.create({
      data: {
        name,
        icon_url,
      },
    });

    res.status(201).json(newCategory);
  } catch (error) {
    console.error('Error creating category:', error);
    if (error.code === 'P2002') {
       return res.status(409).json({ error: 'Category name already exists' });
    }
    res.status(500).json({ error: 'Failed to create category' });
  }
};
