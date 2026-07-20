import { AuthService } from '../services/authService';
import { prisma } from '../database/prisma';
import bcrypt from 'bcrypt';

// Mock de Prisma
jest.mock('../database/prisma', () => ({
  prisma: {
    usuario: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    dispositivo: {
      upsert: jest.fn(),
      findUnique: jest.fn(),
    },
  },
}));

describe('AuthService - Pruebas Unitarias', () => {
  let authService: AuthService;

  beforeEach(() => {
    authService = new AuthService();
    jest.clearAllMocks();
  });

  test('Login exitoso online (Dispositivo exclusivo)', async () => {
    const hashContrasena = await bcrypt.hash('admin12345', 10);
    const mockUsuario = {
      id: 'uuid-usuario-1',
      correo: 'admin@sirc.gov',
      contrasena: hashContrasena,
      nombre: 'Admin SIRC',
      rol: 'ADMIN',
      dispositivoActivoId: null,
      deletedAt: null,
    };

    const mockDispositivo = {
      id: 'uuid-dispositivo-1',
      codigoUnico: 'device-codigo-1',
      nombre: 'Samsung Galaxy S22',
    };

    // Configurar mocks de Prisma
    (prisma.usuario.findUnique as jest.Mock).mockResolvedValue(mockUsuario);
    (prisma.dispositivo.upsert as jest.Mock).mockResolvedValue(mockDispositivo);
    (prisma.usuario.update as jest.Mock).mockResolvedValue(mockUsuario);

    const respuesta = await authService.login(
      'admin@sirc.gov',
      'admin12345',
      'device-codigo-1',
      'Samsung Galaxy S22'
    );

    expect(respuesta).toHaveProperty('token');
    expect(respuesta.usuario.correo).toBe('admin@sirc.gov');
    expect(prisma.usuario.findUnique).toHaveBeenCalledWith({
      where: { correo: 'admin@sirc.gov' },
    });
    expect(prisma.dispositivo.upsert).toHaveBeenCalled();
    expect(prisma.usuario.update).toHaveBeenCalledWith({
      where: { id: 'uuid-usuario-1' },
      data: { dispositivoActivoId: 'uuid-dispositivo-1' },
    });
  });

  test('Login fallido con contraseña incorrecta', async () => {
    const hashContrasena = await bcrypt.hash('admin12345', 10);
    const mockUsuario = {
      id: 'uuid-usuario-1',
      correo: 'admin@sirc.gov',
      contrasena: hashContrasena,
      rol: 'ADMIN',
      deletedAt: null,
    };

    (prisma.usuario.findUnique as jest.Mock).mockResolvedValue(mockUsuario);

    await expect(
      authService.login('admin@sirc.gov', 'contrasena_incorrecta', 'dev-code', 'dev-name')
    ).rejects.toThrow('Credenciales incorrectas');
  });

  test('Logout exitoso (Desvinculación de dispositivo activo)', async () => {
    (prisma.usuario.update as jest.Mock).mockResolvedValue({ id: 'uuid-usuario-1' });

    await authService.logout('uuid-usuario-1');

    expect(prisma.usuario.update).toHaveBeenCalledWith({
      where: { id: 'uuid-usuario-1' },
      data: { dispositivoActivoId: null },
    });
  });
});
