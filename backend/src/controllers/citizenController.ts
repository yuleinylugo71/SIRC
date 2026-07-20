import { Request, Response, NextFunction } from 'express';
import { prisma } from '../database/prisma';
import { BadRequestError, NotFoundError } from '../core/exceptions';
import { logger } from '../core/logger';
import { z } from 'zod';

// Esquema de Validación de Ciudadano con Zod
const ciudadanoSchema = z.object({
  documentoIdentidad: z.string().min(6).max(12),
  nombres: z.string().min(2),
  apellidos: z.string().min(2),
  fechaNacimiento: z.string().datetime(), // ISO String
  telefono: z.string().min(8).max(15).optional().nullable(),
  correo: z.string().email().optional().nullable(),
});

export class CitizenController {
  
  public async listar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const user = req.user;
      logger.info(`Listando ciudadanos activos para usuario: ${user?.email || 'desconocido'} (rol: ${user?.role || 'TODOS'})`);
      
      const whereCondition: any = { deletedAt: null };
      if (user && user.role !== 'ADMIN') {
        whereCondition.registradoPorUsuarioId = user.id;
      }

      const ciudadanos = await prisma.ciudadano.findMany({
        where: whereCondition,
        orderBy: { createdAt: 'desc' },
      });

      res.status(200).json({
        status: 'success',
        data: ciudadanos,
      });
    } catch (error) {
      next(error);
    }
  }

  public async crear(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const parsedBody = ciudadanoSchema.parse(req.body);
      const user = req.user!;

      // Validar cédula única
      const existente = await prisma.ciudadano.findUnique({
        where: { documentoIdentidad: parsedBody.documentoIdentidad },
      });

      if (existente) {
        throw new BadRequestError('El documento de identidad ingresado ya se encuentra registrado');
      }

      // Obtener el ID del dispositivo del token
      const dispositivo = await prisma.dispositivo.findUnique({
        where: { codigoUnico: user.device_uuid },
      });

      if (!dispositivo) {
        throw new BadRequestError('Dispositivo registrado no encontrado en el servidor');
      }

      const ahoraStr = new Date().toISOString();
      const metadatos = {
        nombres: ahoraStr,
        apellidos: ahoraStr,
        fecha_nacimiento: ahoraStr,
        telefono: ahoraStr,
        correo: ahoraStr,
        deleted_at: ahoraStr,
      };

      logger.info(`Creando ciudadano directo vía API: ${parsedBody.nombres} ${parsedBody.apellidos}`);

      const nuevo = await prisma.ciudadano.create({
        data: {
          documentoIdentidad: parsedBody.documentoIdentidad,
          nombres: parsedBody.nombres,
          apellidos: parsedBody.apellidos,
          fechaNacimiento: new Date(parsedBody.fechaNacimiento),
          telefono: parsedBody.telefono || null,
          correo: parsedBody.correo || null,
          estadoSincronizacion: 'SINCRONIZADO',
          registradoPorUsuarioId: user.id,
          registradoEnDispositivoId: dispositivo.id,
          version: 1,
          metadatosCampos: metadatos as any,
        },
      });

      res.status(201).json({
        status: 'success',
        data: nuevo,
      });
    } catch (error) {
      next(error);
    }
  }

  public async actualizar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { uuid } = req.params;
      const parsedBody = ciudadanoSchema.parse(req.body);

      const existente = await prisma.ciudadano.findUnique({
        where: { id: uuid },
      });

      if (!existente) {
        throw new NotFoundError('Ciudadano no encontrado');
      }

      // Evitar colisión de documento con otro registro
      const duplicado = await prisma.ciudadano.findFirst({
        where: {
          documentoIdentidad: parsedBody.documentoIdentidad,
          id: { not: uuid },
        },
      });

      if (duplicado) {
        throw new BadRequestError('El documento de identidad colisiona con otro ciudadano registrado');
      }

      // Algoritmo LWW por campo para modificaciones vía REST API
      const ahoraStr = new Date().toISOString();
      const metadatosServidor = (existente.metadatosCampos as any) || {};
      const metadatosActualizados = { ...metadatosServidor };

      if (existente.nombres !== parsedBody.nombres) metadatosActualizados.nombres = ahoraStr;
      if (existente.apellidos !== parsedBody.apellidos) metadatosActualizados.apellidos = ahoraStr;
      if (existente.fechaNacimiento.toISOString() !== new Date(parsedBody.fechaNacimiento).toISOString()) {
        metadatosActualizados.fecha_nacimiento = ahoraStr;
      }
      if (existente.telefono !== parsedBody.telefono) metadatosActualizados.telefono = ahoraStr;
      if (existente.correo !== parsedBody.correo) metadatosActualizados.correo = ahoraStr;

      logger.info(`Actualizando ciudadano directo vía API: ${existente.nombres} -> ${parsedBody.nombres}`);

      const actualizado = await prisma.ciudadano.update({
        where: { id: uuid },
        data: {
          documentoIdentidad: parsedBody.documentoIdentidad,
          nombres: parsedBody.nombres,
          apellidos: parsedBody.apellidos,
          fechaNacimiento: new Date(parsedBody.fechaNacimiento),
          telefono: parsedBody.telefono || null,
          correo: parsedBody.correo || null,
          version: existente.version + 1,
          metadatosCampos: metadatosActualizados as any,
          updatedAt: new Date(),
        },
      });

      res.status(200).json({
        status: 'success',
        data: actualizado,
      });
    } catch (error) {
      next(error);
    }
  }

  public async eliminar(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { uuid } = req.params;

      const existente = await prisma.ciudadano.findUnique({
        where: { id: uuid },
      });

      if (!existente) {
        throw new NotFoundError('Ciudadano no encontrado');
      }

      logger.info(`Eliminando lógicamente ciudadano directo vía API ID: ${uuid}`);

      await prisma.ciudadano.update({
        where: { id: uuid },
        data: {
          deletedAt: new Date(),
          updatedAt: new Date(),
        },
      });

      res.status(200).json({
        status: 'success',
        message: 'Ciudadano eliminado lógicamente en el servidor',
      });
    } catch (error) {
      next(error);
    }
  }
}
