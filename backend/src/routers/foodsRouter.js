import express from 'express';
import { getFoods, createFood, updateFood, deleteFood } from '../controllers/foodsController.js';
import { authenticate, authorize } from '../middleware/auth.js';

const router = express.Router();

router.get('/', getFoods);
router.post('/', authenticate, authorize(['ADMIN']), createFood);
router.patch('/:id', authenticate, authorize(['ADMIN']), updateFood);
router.delete('/:id', authenticate, authorize(['ADMIN']), deleteFood);

export default router;