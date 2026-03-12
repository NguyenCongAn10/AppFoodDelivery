import express from 'express';
const router = express.Router();
import * as favoritesController from '../controllers/favoritesController.js';
import { authenticate } from '../middleware/auth.js';

router.use(authenticate);

router.get('/', favoritesController.getFavorites);
router.post('/toggle', favoritesController.toggleFavorite);

export default router;
