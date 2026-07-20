import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../core/config';
import { UnauthorizedError, ForbiddenError } from '../core/exceptions';
import { prisma } from '../database/prisma';

export interface UserPayload {
  id: string;
  email: string;
  role?: string;
  device_uuid?: string; // Código único del dispositivo móvil guardado en el token
}

declare global {
  namespace Express {
    interface Request {
      user?: UserPayload;
    }
  }
}

/**
 * Middleware para autenticar requests y validar la exclusividad del dispositivo activo
 */
export const auth = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new UnauthorizedError('Access token is missing or invalid'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, config.JWT_SECRET) as UserPayload;

    // Buscar el estado del usuario y su dispositivo vinculado actualmente en base de datos
    const usuario = await prisma.usuario.findUnique({
      where: { id: decoded.id },
      include: { dispositivoActivo: true },
    });

    if (!usuario || usuario.deletedAt) {
      return next(new UnauthorizedError('Usuario inactivo o no encontrado'));
    }

    // Verificar dispositivo único activo
    if (
      !usuario.dispositivoActivo ||
      usuario.dispositivoActivo.codigoUnico !== decoded.device_uuid
    ) {
      return next(
        new UnauthorizedError(
          'Sesión inválida. Esta cuenta ha sido iniciada en otro dispositivo'
        )
      );
    }

    req.user = decoded;
    next();
  } catch (error) {
    return next(new UnauthorizedError('Invalid or expired access token'));
  }
};

/**
 * Middleware para asegurar que solo usuarios con rol ADMIN puedan continuar
 */
export const adminOnly = (
  req: Request,
  _res: Response,
  next: NextFunction
): void => {
  if (!req.user || req.user.role !== 'ADMIN') {
    return next(new ForbiddenError('Acceso denegado. Se requiere rol de Administrador'));
  }
  next();
};

