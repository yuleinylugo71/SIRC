import { Request, Response, NextFunction, ErrorRequestHandler } from 'express';
import { AppError } from '../core/exceptions';
import { logger } from '../core/logger';
import { config } from '../core/config';

export const errorHandler: ErrorRequestHandler = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  const isDevelopment = config.NODE_ENV === 'development';

  if (err instanceof AppError) {
    logger.warn(`AppError [${err.statusCode}]: ${err.message} - Path: ${req.originalUrl}`);
    res.status(err.statusCode).json({
      status: 'error',
      statusCode: err.statusCode,
      message: err.message,
      ...(isDevelopment && { stack: err.stack }),
    });
    return;
  }

  // Manejo de errores de parsing de JSON de Express u otros errores genéricos con statusCode
  const statusCode = (err as any).statusCode || (err as any).status || 500;
  
  if (statusCode < 500) {
    logger.warn(`HTTP Error [${statusCode}]: ${err.message} - Path: ${req.originalUrl}`);
    res.status(statusCode).json({
      status: 'error',
      statusCode,
      message: err.message,
      ...(isDevelopment && { stack: err.stack }),
    });
    return;
  }

  // Error inesperado o del sistema (500)
  logger.error(`Unhandled Error: ${err.message}\nStack: ${err.stack}`);
  
  res.status(500).json({
    status: 'error',
    statusCode: 500,
    message: isDevelopment ? err.message : 'Internal Server Error',
    ...(isDevelopment && { stack: err.stack }),
  });
};
