import app from './app';
import { config } from './core/config';
import { logger } from './core/logger';
import { prisma } from './database/prisma';

const server = app.listen(config.PORT, () => {
  logger.info(`Server running in ${config.NODE_ENV} mode on port ${config.PORT}`);
});

server.on('error', (error: NodeJS.ErrnoException) => {
  if (error.code === 'EADDRINUSE') {
    logger.error(
      `Port ${config.PORT} is already in use. The backend is probably already running at http://localhost:${config.PORT}`
    );
    process.exit(1);
  }

  throw error;
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

  setTimeout(() => {
    logger.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

process.on('unhandledRejection', (reason: Error) => {
  logger.error(`Unhandled Rejection: ${reason.message}\nStack: ${reason.stack}`);
});

process.on('uncaughtException', (error: Error) => {
  logger.error(`Uncaught Exception: ${error.message}\nStack: ${error.stack}`);
  gracefulShutdown();
});
