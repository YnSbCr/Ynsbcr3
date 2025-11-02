/**
 * Express server ?rne?i - Error handling ile
 */
import express from 'express';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

const app = express();

// Middleware
app.use(express.json());

// ?rnek route
app.get('/api/health', (req, res) => {
  res.json({ success: true, data: { status: 'ok' } });
});

// 404 handler (t?m route'lardan sonra)
app.use(notFoundHandler);

// Error handler (en sonda)
app.use(errorHandler);

export default app;
