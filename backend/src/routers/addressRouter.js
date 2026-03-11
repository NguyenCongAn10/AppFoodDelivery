import express from 'express';
import { 
    getAddresses, 
    addAddress, 
    updateAddress,
    deleteAddress 
} from '../controllers/addressController.js';
import { authenticate } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticate);

router.get('/', getAddresses);
router.post('/', addAddress);
router.patch('/:id', updateAddress);
router.delete('/:id', deleteAddress);

export default router;
