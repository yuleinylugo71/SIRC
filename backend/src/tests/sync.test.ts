import { SyncService } from '../services/syncService';
import { prisma } from '../database/prisma';

// Mock de Prisma
jest.mock('../database/prisma', () => ({
  prisma: {
    ciudadano: {
      findUnique: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
    logSincronizacion: {
      create: jest.fn(),
    },
  },
}));

describe('SyncService - Motor de Sincronización e Idempotencia', () => {
  let syncService: SyncService;

  beforeEach(() => {
    syncService = new SyncService();
    jest.clearAllMocks();
  });

  test('sincronizar() - Inserción Idempotente exitosa', async () => {
    const tareaPayload = {
      id: 'tarea-id-1',
      tablaAfectada: 'ciudadanos',
      registroId: 'ciudadano-uuid-1',
      operacion: 'INSERT' as const,
      payload: JSON.stringify({
        documento_identidad: '123456',
        nombres: 'Carlos',
        apellidos: 'Perez',
        fecha_nacimiento: '1995-05-15T00:00:00.000Z',
        version: 1,
        metadatos_campos: { nombres: '2026-07-03T01:00:00.000Z' },
      }),
    };

    // Configurar mocks para indicar que no existe
    (prisma.ciudadano.findFirst as jest.Mock).mockResolvedValue(null); // No duplicados de cédula
    (prisma.ciudadano.findUnique as jest.Mock).mockResolvedValue(null); // No existe el ID

    const resultados = await syncService.procesarSincronizacion(
      [tareaPayload],
      'usuario-uuid',
      'dispositivo-uuid'
    );

    expect(resultados[0].success).toBe(true);
    expect(prisma.ciudadano.create).toHaveBeenCalled();
  });

  test('sincronizar() - Unificación de Duplicados por Documento (Remapeo de ID)', async () => {
    const tareaPayload = {
      id: 'tarea-id-1',
      tablaAfectada: 'ciudadanos',
      registroId: 'ciudadano-uuid-provisional',
      operacion: 'INSERT' as const,
      payload: JSON.stringify({
        documento_identidad: '123456',
        nombres: 'Carlos',
        apellidos: 'Perez',
        fecha_nacimiento: '1995-05-15T00:00:00.000Z',
        version: 1,
        metadatos_campos: { nombres: '2026-07-03T01:00:00.000Z' },
      }),
    };

    const mockGanadorServidor = {
      id: 'ciudadano-uuid-ganador-servidor',
      documentoIdentidad: '123456',
      nombres: 'Carlos',
      apellidos: 'Perez',
      fechaNacimiento: new Date('1995-05-15T00:00:00.000Z'),
      version: 2,
      metadatosCampos: { nombres: '2026-07-03T00:00:00.000Z' },
    };

    // Simular que ya existe un registro con la misma cédula pero diferente ID
    (prisma.ciudadano.findFirst as jest.Mock).mockResolvedValue(mockGanadorServidor);
    (prisma.ciudadano.update as jest.Mock).mockResolvedValue(mockGanadorServidor);

    const resultados = await syncService.procesarSincronizacion(
      [tareaPayload],
      'usuario-uuid',
      'dispositivo-uuid'
    );

    expect(resultados[0].success).toBe(true);
    expect(resultados[0].conflicto).toBe(true);
    expect(resultados[0].unificadoId).toBe('ciudadano-uuid-ganador-servidor');
    expect(prisma.ciudadano.update).toHaveBeenCalled();
  });

  test('sincronizar() - Ediciones Concurrentes LWW por Campo (Cliente Gana Campo)', async () => {
    const ahoraStr = new Date().toISOString();
    const antesStr = new Date(Date.now() - 60000).toISOString();

    const tareaPayload = {
      id: 'tarea-id-1',
      tablaAfectada: 'ciudadanos',
      registroId: 'ciudadano-uuid-1',
      operacion: 'UPDATE' as const,
      payload: JSON.stringify({
        documento_identidad: '123456',
        nombres: 'Juan Modificado',
        apellidos: 'Perez',
        fecha_nacimiento: '1995-05-15T00:00:00.000Z',
        version: 2,
        metadatos_campos: {
          nombres: ahoraStr, // Más reciente que el servidor
          telefono: antesStr,
        },
        telefono: '+5491122',
      }),
    };

    const mockServidorExistente = {
      id: 'ciudadano-uuid-1',
      documentoIdentidad: '123456',
      nombres: 'Juan Original',
      apellidos: 'Perez',
      fechaNacimiento: new Date('1995-05-15T00:00:00.000Z'),
      telefono: '111111',
      version: 1,
      metadatosCampos: {
        nombres: antesStr,
        telefono: ahoraStr, // Servidor tiene fecha de teléfono más reciente
      },
    };

    (prisma.ciudadano.findFirst as jest.Mock).mockResolvedValue(null);
    (prisma.ciudadano.findUnique as jest.Mock).mockResolvedValue(mockServidorExistente);
    (prisma.ciudadano.update as jest.Mock).mockResolvedValue(mockServidorExistente);

    const resultados = await syncService.procesarSincronizacion(
      [tareaPayload],
      'usuario-uuid',
      'dispositivo-uuid'
    );

    expect(resultados[0].success).toBe(true);
    // Verificamos que se llame a actualizar aplicando la unificación por marcas de tiempo
    expect(prisma.ciudadano.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          nombres: 'Juan Modificado', // Gana cliente por tener fecha más nueva
          telefono: '111111', // Gana servidor por tener fecha más nueva
        }),
      })
    );
  });
});
