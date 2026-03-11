import express from 'express';
import dotenv from 'dotenv';
import userRouter from './routers/userRouter.js';
import authRouter from './routers/authRouter.js';
import foodsRouter from './routers/foodsRouter.js';
import ordersRouter from './routers/ordersRouter.js';
import shippersRouter from './routers/shippersRouter.js';
import categoryRouter from './routers/categoryRouter.js';
import addressRouter from './routers/addressRouter.js';
import prisma from './config/prisma.js';

// Load environment variables
dotenv.config();

const PORT = process.env.PORT || 3000;
const app = express();

// ===== MIDDLEWARES =====
// Parse JSON bodies
app.use(express.json());

// CORS middleware (allow all origins for development)
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    
    // Handle preflight requests
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

// Request logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// ===== ROUTES =====
// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        database: 'connected'
    });
});

// API routes
app.use('/api/auth', authRouter);
app.use('/api/foods', foodsRouter);
app.use('/api/orders', ordersRouter);
app.use('/api/shippers', shippersRouter);
app.use('/api/user', userRouter);
app.use('/api/categories', categoryRouter);
app.use('/api/addresses', addressRouter);

// 404 handler
app.use((req, res) => {
    res.status(404).json({ 
        error: 'Route not found',
        path: req.path 
    });
});

// ===== ERROR HANDLING =====
// Global error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    
    res.status(err.status || 500).json({
        error: err.message || 'Internal server error',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
});

// ===== START SERVER =====
const server = app.listen(PORT, async () => {
    console.log(`🚀 Server is running on port ${PORT}`);
    console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
    
    try {
        await prisma.$connect();
        console.log('✅ Prisma connected to Supabase successfully!');
    } catch (error) {
        console.error('❌ Prisma connection error:', error.message);
        process.exit(1);
    }
});

// ===== GRACEFUL SHUTDOWN =====
const gracefulShutdown = async (signal) => {
    console.log(`\n${signal} received. Closing server gracefully...`);
    
    server.close(async () => {
        console.log('HTTP server closed');
        
        try {
            await prisma.$disconnect();
            console.log('Prisma disconnected');
            process.exit(0);
        } catch (error) {
            console.error('Error during shutdown:', error);
            process.exit(1);
        }
    });
    
    // Force shutdown after 10 seconds
    setTimeout(() => {
        console.error('Forced shutdown after timeout');
        process.exit(1);
    }, 10000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
