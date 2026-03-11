import express from 'express';
import { getAllCategories, createCategory } from '../controllers/categoryController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// Public route to get categories
router.get('/', getAllCategories);

// Protected route to create category
router.post('/', authenticate, createCategory);

export default router;
