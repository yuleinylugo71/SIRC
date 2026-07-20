import { PrismaClient } from '@prisma/client';
import { logger } from '../core/logger';

const prismaClientSingleton = () => {
  const client = new PrismaClient({
    log: [
      { emit: 'event', level: 'query' },
      { emit: 'stdout', level: 'info' },
      { emit: 'stdout', level: 'warn' },
      { emit: 'stdout', level: 'error' },
    ],
  });

  return client;
};

declare global {
  // eslint-disable-next-line no-var
  var prismaGlobal: undefined | ReturnType<typeof prismaClientSingleton>;
}

export const prisma = globalThis.prismaGlobal ?? prismaClientSingleton();

if (process.env.NODE_ENV !== 'production') {
  globalThis.prismaGlobal = prisma;
}

// Canalizar queries a través de nuestro logger del sistema en nivel debug
// Solo si el tipo lo permite
try {
  (prisma as any).$on('query', (e: any) => {
    logger.debug(`DB Query: ${e.query} - Params: ${e.params} - Duration: ${e.duration}ms`);
  });
} catch (error) {
  // Ignorar si no se ha configurado el emitter
}
