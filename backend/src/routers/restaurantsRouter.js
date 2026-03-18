import { getRestaurantById, registerRestaurant, getMyRestaurant, updateRestaurantStatus } from '../controllers/restaurantsController.js';
import { authenticate } from '../middleware/auth.js';
import express from 'express';
const router = express.Router();

// GET /api/restaurants/me
router.get('/me', authenticate, getMyRestaurant);

// PATCH /api/restaurants/me/status
router.patch('/me/status', authenticate, updateRestaurantStatus);

// GET /api/restaurants/:id
router.get('/:id', getRestaurantById);

// POST /api/restaurants/register
router.post('/register', authenticate, registerRestaurant);

export default router;
