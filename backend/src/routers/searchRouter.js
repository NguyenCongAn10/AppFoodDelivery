import express from 'express';
import {
  searchRestaurantsByFood,
  getSearchSuggestions,
} from '../controllers/searchController.js';

const router = express.Router();

// Public search endpoint
// GET /api/search/restaurants?q=...
router.get('/restaurants', searchRestaurantsByFood);

// Public suggestions endpoint
// GET /api/search/suggestions
router.get('/suggestions', getSearchSuggestions);

export default router;

