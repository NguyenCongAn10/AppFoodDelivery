import express from 'express';
import { createUser, getUser, updateUser  } from '../controllers/userController.js';
const router = express.Router();


router.post("/", createUser);
router.put("/:id", updateUser);
router.get("/:id", getUser);
export default router; 