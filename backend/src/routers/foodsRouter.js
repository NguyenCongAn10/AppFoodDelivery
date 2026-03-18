import express from 'express';
import { getFoods, createFood, updateFood, deleteFood } from '../controllers/foodsController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.get('/', getFoods);
router.post('/', authenticate, authorize(['ADMIN', 'RESTAURANT']), createFood);
router.patch('/:id', authenticate, authorize(['ADMIN', 'RESTAURANT']), updateFood);
router.delete('/:id', authenticate, authorize(['ADMIN', 'RESTAURANT']), deleteFood);

export default router;