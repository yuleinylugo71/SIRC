import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/authService';
import { BadRequestError } from '../core/exceptions';
import { logger } from '../core/logger';

const authService = new AuthService();

export class AuthController {
  public async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const {
        correo,
        contrasena,
        dispositivo_codigo,
        dispositivo_nombre,
        dispositivo_modelo,
        dispositivo_so,
      } = req.body;

      if (!correo || !contrasena || !dispositivo_codigo || !dispositivo_nombre) {
        throw new BadRequestError(
          'correo, contrasena, dispositivo_codigo y dispositivo_nombre son obligatorios'
        );
      }

      logger.info(`Intento de login online para: ${correo} desde dispositivo: ${dispositivo_nombre}`);

      const resultado = await authService.login(
        correo,
        contrasena,
        dispositivo_codigo,
        dispositivo_nombre,
        dispositivo_modelo,
        dispositivo_so
      );

      res.status(200).json({
        status: 'success',
        data: resultado,
      });
    } catch (error) {
      next(error);
    }
  }

  public async logout(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const user = req.user;
      if (!user) {
        res.status(200).json({ status: 'success', message: 'Sesión no activa' });
        return;
      }

      await authService.logout(user.id);
      logger.info(`Cierre de sesión para el usuario: ${user.email}`);

      res.status(200).json({
        status: 'success',
        message: 'Sesión cerrada exitosamente en el servidor',
      });
    } catch (error) {
      next(error);
    }
  }

  public async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { correo, contrasena, nombre, rol } = req.body;

      if (!correo || !contrasena) {
        throw new BadRequestError('correo y contrasena son obligatorios');
      }

      logger.info(`Administrador intentando registrar nuevo usuario: ${correo}`);

      const resultado = await authService.register(correo, contrasena, nombre, rol);

      res.status(201).json({
        status: 'success',
        message: 'Usuario registrado exitosamente',
        data: resultado,
      });
    } catch (error) {
      next(error);
    }
  }

  public async listarUsuarios(_req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      logger.info('Listando usuarios/agentes registrados en la plataforma');
      const usuarios = await authService.listarUsuarios();
      res.status(200).json({
        status: 'success',
        data: usuarios,
      });
    } catch (error) {
      next(error);
    }
  }
}
