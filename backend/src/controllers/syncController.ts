import { Request, Response, NextFunction } from 'express';
import { SyncService } from '../services/syncService';
import { BadRequestError, UnauthorizedError } from '../core/exceptions';
import { logger } from '../core/logger';
import { prisma } from '../database/prisma';

const syncService = new SyncService();

export class SyncController {
  public async sincronizar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { tareas } = req.body;
      const user = req.user;

      if (!user || !user.device_uuid) {
        throw new UnauthorizedError('Identificación de dispositivo no provista en credenciales');
      }

      if (!tareas || !Array.isArray(tareas)) {
        throw new BadRequestError('El campo tareas es obligatorio y debe ser un array');
      }

      logger.info(
        `Recibido lote de sincronización de ${tareas.length} registros del usuario: ${user.email} y dispositivo: ${user.device_uuid}`
      );

      // El middleware 'auth' ya garantizó que user.device_uuid es el dispositivoActivoId del usuario en base de datos.
      // Ahora, mapeamos el dispositivo_uuid (que es el codigoUnico de tipo string) a su ID de tipo UUID.
      const dispositivo = await prisma.dispositivo.findUnique({
        where: { codigoUnico: user.device_uuid },
      });

      if (!dispositivo) {
        throw new BadRequestError('El dispositivo de origen no se encuentra registrado en el servidor');
      }

      const resultados = await syncService.procesarSincronizacion(
        tareas,
        user.id,
        dispositivo.id
      );

      res.status(200).json({
        status: 'success',
        data: resultados,
      });
    } catch (error) {
      next(error);
    }
  }
}
