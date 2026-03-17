import express from 'express';
import { getRestaurantById, registerRestaurant } from '../controllers/restaurantsController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

// GET /api/restaurants/:id
router.get('/:id', getRestaurantById);

// POST /api/restaurants/register
router.post('/register', authenticate, registerRestaurant);

export default router;
