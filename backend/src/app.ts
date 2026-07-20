import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';
import authRoutes from './routes/authRoutes';
import syncRoutes from './routes/syncRoutes';
import citizenRoutes from './routes/citizenRoutes';
import { errorHandler } from './middlewares/errorHandler';
import { logger } from './core/logger';
import { NotFoundError } from './core/exceptions';

const app: Application = express();

// Middlewares globales
app.use(cors());
app.use(express.json());

// Documentación de API interactiva (Swagger)
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/sync', syncRoutes);
app.use('/api/citizens', citizenRoutes);

// Logger de peticiones HTTP básico
app.use((req: Request, _res: Response, next: NextFunction) => {
  logger.info(`HTTP Request: ${req.method} ${req.originalUrl}`);
  next();
});

// Ruta de diagnóstico básica (Health Check)
app.get('/health', (_req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// Manejo de rutas no encontradas (404)
app.use((req: Request, _res: Response, next: NextFunction) => {
  next(new NotFoundError(`Route ${req.originalUrl} not found`));
});

// Manejador de errores global (Debe ir al final de las rutas)
app.use(errorHandler);

export default app;
