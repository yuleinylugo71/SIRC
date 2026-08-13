import { prisma } from '../database/prisma';

export async function registrarVersionCiudadano(
  ciudadano: any,
  motivo: string
): Promise<void> {
  await (prisma as any).ciudadanoHistorial.create({
    data: {
      ciudadanoId: ciudadano.id,
      version: ciudadano.version,
      documentoIdentidad: ciudadano.documentoIdentidad,
      nombres: ciudadano.nombres,
      apellidos: ciudadano.apellidos,
      fechaNacimiento: ciudadano.fechaNacimiento,
      telefono: ciudadano.telefono,
      correo: ciudadano.correo,
      estadoSincronizacion: ciudadano.estadoSincronizacion,
      registradoPorUsuarioId: ciudadano.registradoPorUsuarioId,
      registradoEnDispositivoId: ciudadano.registradoEnDispositivoId,
      metadatosCampos: ciudadano.metadatosCampos as any,
      originalCreatedAt: ciudadano.createdAt,
      originalUpdatedAt: ciudadano.updatedAt,
      motivo,
    },
  });
}
