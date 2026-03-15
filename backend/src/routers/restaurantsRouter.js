import express from 'express';
import { getRestaurantById } from '../controllers/restaurantsController.js';

const router = express.Router();

// GET /api/restaurants/:id
router.get('/:id', getRestaurantById);

export default router;
