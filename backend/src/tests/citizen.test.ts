import { CitizenController } from '../controllers/citizenController';
import { prisma } from '../database/prisma';
import { Request, Response } from 'express';

// Mock de Prisma
jest.mock('../database/prisma', () => ({
  prisma: {
    ciudadano: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    dispositivo: {
      findUnique: jest.fn(),
    },
  },
}));

describe('CitizenController - Pruebas del CRUD API REST', () => {
  let controller: CitizenController;
  let mockRequest: Partial<Request>;
  let mockResponse: Partial<Response>;
  let nextMock: jest.Mock;

  beforeEach(() => {
    controller = new CitizenController();
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    nextMock = jest.fn();
    jest.clearAllMocks();
  });

  test('listar() - Retorna ciudadanos filtrados por registradoPorUsuarioId si es REGISTRADOR', async () => {
    const mockCiudadanos = [
      { id: 'uuid-1', documentoIdentidad: '123456', nombres: 'Juan', apellidos: 'Perez', deletedAt: null },
    ];
    (prisma.ciudadano.findMany as jest.Mock).mockResolvedValue(mockCiudadanos);

    const req = {
      user: { id: 'agente-123', email: 'agente@sirc.gov', role: 'REGISTRADOR' }
    } as Request;

    await controller.listar(req, mockResponse as Response, nextMock);

    expect(prisma.ciudadano.findMany).toHaveBeenCalledWith({
      where: { deletedAt: null, registradoPorUsuarioId: 'agente-123' },
      orderBy: { createdAt: 'desc' },
    });
    expect(mockResponse.status).toHaveBeenCalledWith(200);
    expect(mockResponse.json).toHaveBeenCalledWith({
      status: 'success',
      data: mockCiudadanos,
    });
  });

  test('crear() - Falla si el documento de identidad ya está registrado', async () => {
    mockRequest = {
      body: {
        documentoIdentidad: '123456',
        nombres: 'Juan',
        apellidos: 'Perez',
        fechaNacimiento: '1995-05-15T00:00:00.000Z',
      },
      user: {
        id: 'user-id',
        email: 'user@email.com',
        role: 'REGISTRADOR',
        device_uuid: 'device-uuid',
      },
    };

    // Simular que el documento ya existe
    (prisma.ciudadano.findUnique as jest.Mock).mockResolvedValue({ id: 'uuid-existente' });

    await controller.crear(mockRequest as Request, mockResponse as Response, nextMock);

    expect(nextMock).toHaveBeenCalledWith(
      expect.objectContaining({
        message: 'El documento de identidad ingresado ya se encuentra registrado',
      })
    );
  });
});
