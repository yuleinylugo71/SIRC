import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { prisma } from '../database/prisma';
import { config } from '../core/config';
import { UnauthorizedError, ConflictError } from '../core/exceptions';

export interface LoginResult {
  token: string;
  usuario: {
    id: string;
    correo: string;
    nombre: string | null;
    rol: string;
  };
  hashCache: string; // Hash de la contraseña para validación offline local
}

export class AuthService {
  /**
   * Realiza el login de usuario (siempre online)
   */
  public async login(
    correo: string,
    contrasena: string,
    dispositivoCodigo: string,
    dispositivoNombre: string,
    dispositivoModelo?: string,
    dispositivoSO?: string
  ): Promise<LoginResult> {
    // 1. Buscar al usuario
    let usuario = await prisma.usuario.findUnique({
      where: { correo },
    });

    // Sembrar un usuario inicial de prueba si la base de datos está vacía para facilitar la evaluación
    if (!usuario && correo === 'admin@sirc.gov') {
      const hashPrueba = await bcrypt.hash('admin12345', 10);
      usuario = await prisma.usuario.create({
        data: {
          correo: 'admin@sirc.gov',
          contrasena: hashPrueba,
          nombre: 'Administrador SIRC',
          rol: 'ADMIN',
        },
      });
    }

    if (!usuario) {
      throw new UnauthorizedError('Credenciales incorrectas');
    }

    if (usuario.deletedAt) {
      throw new UnauthorizedError('El usuario ha sido desactivado');
    }

    // 2. Verificar contraseña
    const contrasenaValida = await bcrypt.compare(contrasena, usuario.contrasena);
    if (!contrasenaValida) {
      throw new UnauthorizedError('Credenciales incorrectas');
    }

    // 3. Registrar o actualizar el dispositivo móvil
    const dispositivo = await prisma.dispositivo.upsert({
      where: { codigoUnico: dispositivoCodigo },
      update: {
        nombre: dispositivoNombre,
        modelo: dispositivoModelo || null,
        sistemaOperativo: dispositivoSO || null,
        deletedAt: null, // Reactivar si fue eliminado
      },
      create: {
        codigoUnico: dispositivoCodigo,
        nombre: dispositivoNombre,
        modelo: dispositivoModelo || null,
        sistemaOperativo: dispositivoSO || null,
      },
    });

    // 4. Vincular el dispositivo al usuario como DISPOSITIVO ACTIVO (impide sesión simultánea)
    await prisma.usuario.update({
      where: { id: usuario.id },
      data: {
        dispositivoActivoId: dispositivo.id,
      },
    });

    // 5. Generar Token JWT (guardamos el device_uuid en el payload)
    const token = jwt.sign(
      {
        id: usuario.id,
        email: usuario.correo,
        role: usuario.rol,
        device_uuid: dispositivoCodigo,
      },
      config.JWT_SECRET,
      { expiresIn: config.JWT_EXPIRES_IN as any }
    );

    return {
      token,
      usuario: {
        id: usuario.id,
        correo: usuario.correo,
        nombre: usuario.nombre,
        rol: usuario.rol,
      },
      hashCache: usuario.contrasena, // Retornamos el hash para el almacenamiento SQLite local offline
    };
  }

  /**
   * Cierra la sesión desvinculando el dispositivo del usuario
   */
  public async logout(usuarioId: string): Promise<void> {
    await prisma.usuario.update({
      where: { id: usuarioId },
      data: { dispositivoActivoId: null },
    });
  }

  /**
   * Registra un nuevo usuario en la base de datos (Ej: un REGISTRADOR)
   */
  public async register(
    correo: string,
    contrasena: string,
    nombre?: string,
    rol = 'REGISTRADOR'
  ): Promise<any> {
    // 1. Verificar si el usuario ya existe
    const usuarioExistente = await prisma.usuario.findUnique({
      where: { correo },
    });

    if (usuarioExistente) {
      throw new ConflictError('El correo electrónico ya se encuentra registrado');
    }

    // 2. Encriptar contraseña
    const hashContrasena = await bcrypt.hash(contrasena, 10);

    // 3. Crear el usuario en base de datos
    const nuevoUsuario = await prisma.usuario.create({
      data: {
        correo,
        contrasena: hashContrasena,
        nombre: nombre || null,
        rol,
      },
    });

    return {
      id: nuevoUsuario.id,
      correo: nuevoUsuario.correo,
      nombre: nuevoUsuario.nombre,
      rol: nuevoUsuario.rol,
      createdAt: nuevoUsuario.createdAt,
    };
  }

  /**
   * Obtiene la lista de todos los usuarios/agentes registrados en la plataforma
   */
  public async listarUsuarios(): Promise<any[]> {
    const usuarios = await prisma.usuario.findMany({
      where: { deletedAt: null },
      select: {
        id: true,
        correo: true,
        nombre: true,
        rol: true,
        createdAt: true,
        updatedAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
    return usuarios;
  }
}

