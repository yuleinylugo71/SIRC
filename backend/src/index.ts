import app from './app';
import { config } from './core/config';
import { logger } from './core/logger';
import { prisma } from './database/prisma';

const server = app.listen(config.PORT, () => {
  logger.info(`🚀 Server running in ${config.NODE_ENV} mode on port ${config.PORT}`);
});

const gracefulShutdown = async () => {
  logger.info('Shutting down server gracefully...');
  
  server.close(async () => {
    logger.info('HTTP server closed.');
    
    try {
      await prisma.$disconnect();
      logger.info('Database connection closed through Prisma.');
      process.exit(0);
    } catch (error) {
      logger.error('Error disconnecting Prisma client:', error);
      process.exit(1);
    }
  });

  // Timeout para forzar el apagado si se queda colgado (10 segundos)
  setTimeout(() => {
    logger.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Captura de excepciones no controladas a nivel de proceso
process.on('unhandledRejection', (reason: Error) => {
  logger.error(`Unhandled Rejection: ${reason.message}\nStack: ${reason.stack}`);
  // Opcional: Decidir si apagar o no. En producción, usualmente se apaga y PM2/Docker reinicia.
});

process.on('uncaughtException', (error: Error) => {
  logger.error(`Uncaught Exception: ${error.message}\nStack: ${error.stack}`);
  gracefulShutdown();
});
