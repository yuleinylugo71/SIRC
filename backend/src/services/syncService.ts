import { prisma } from '../database/prisma';
import { logger } from '../core/logger';

export interface SyncTaskPayload {
  id: string; // ID de la tarea en la cola del cliente
  tablaAfectada: string;
  registroId: string;
  operacion: 'INSERT' | 'UPDATE' | 'DELETE';
  payload: string; // JSON Stringified
}

export interface SyncResult {
  id: string; // ID de la tarea en la cola del cliente
  success: boolean;
  conflicto?: boolean;
  unificadoId?: string; // ID ganador en caso de colisión de documento de identidad
  datosServidor?: any; // Objeto unificado final para sincronizar el cliente
  error?: string;
}

interface MetadatosCampos {
  nombres?: string;
  apellidos?: string;
  fecha_nacimiento?: string;
  telefono?: string;
  correo?: string;
  deleted_at?: string;
}

export class SyncService {
  /**
   * Procesa la cola de sincronización aplicando unificación por documento
   * y resolución de conflictos mediante Last Write Wins (LWW) por campo
   */
  public async procesarSincronizacion(
    tareas: SyncTaskPayload[],
    usuarioId: string,
    dispositivoId: string
  ): Promise<SyncResult[]> {
    const resultados: SyncResult[] = [];

    for (const tarea of tareas) {
      try {
        if (tarea.tablaAfectada !== 'ciudadanos') {
          resultados.push({
            id: tarea.id,
            success: false,
            error: `Tabla no soportada para sincronización: ${tarea.tablaAfectada}`,
          });
          continue;
        }

        const resultado = await this.sincronizarCiudadano(tarea, usuarioId, dispositivoId);
        resultados.push(resultado);
      } catch (error: any) {
        logger.error(`Error procesando resolución de conflictos en tarea sync ${tarea.id}: ${error.message}`);
        resultados.push({
          id: tarea.id,
          success: false,
          error: error.message || 'Error interno al reconciliar registro',
        });
      }
    }

    return resultados;
  }

  private async sincronizarCiudadano(
    tarea: SyncTaskPayload,
    usuarioId: string,
    dispositivoId: string
  ): Promise<SyncResult> {
    const payloadJson = JSON.parse(tarea.payload);
    const ciudadanoId = tarea.registroId;
    const documentoIdentidad = payloadJson.documento_identidad;

    // A. DETECCION DE DUPLICADOS POR NUMERO DE DOCUMENTO (CÉDULA)
    // Buscamos si existe un ciudadano registrado con el mismo documento pero con diferente ID (UUID)
    const duplicadoCédula = await prisma.ciudadano.findFirst({
      where: {
        documentoIdentidad,
        id: { not: ciudadanoId },
      },
    });

    if (duplicadoCédula) {
      logger.warn(
        `Colisión lógica detectada: Documento ${documentoIdentidad} enviado con ID ${ciudadanoId} ya existe con ID ${duplicadoCédula.id}. Iniciando unificación.`
      );

      // Unificamos bajo el UUID ganador del servidor (duplicadoCédula.id)
      const fusion = this.fusionarLwwPorCampo(
        duplicadoCédula,
        payloadJson,
        (duplicadoCédula.metadatosCampos as unknown as MetadatosCampos) || {},
        payloadJson.metadatos_campos || {}
      );

      // Actualizar el registro ganador en PostgreSQL con los campos fusionados
      const registroGanadorActualizado = await prisma.ciudadano.update({
        where: { id: duplicadoCédula.id },
        data: {
          nombres: fusion.datos.nombres,
          apellidos: fusion.datos.apellidos,
          fechaNacimiento: new Date(fusion.datos.fecha_nacimiento),
          telefono: fusion.datos.telefono,
          correo: fusion.datos.correo,
          version: Math.max(duplicadoCédula.version, payloadJson.version) + 1,
          metadatosCampos: fusion.metadatos as any,
          updatedAt: new Date(),
          deletedAt: fusion.datos.deleted_at ? new Date(fusion.datos.deleted_at) : null,
        },
      });

      await this.registrarLog(dispositivoId, usuarioId, `UNIFICACION_DUPLICADO_ID:${duplicadoCédula.id}`);

      // Retornar conflicto e indicarle al cliente el UUID ganador para unificar su base SQLite local
      return {
        id: tarea.id,
        success: true,
        conflicto: true,
        unificadoId: duplicadoCédula.id,
        datosServidor: {
          id: registroGanadorActualizado.id,
          documento_identidad: registroGanadorActualizado.documentoIdentidad,
          nombres: registroGanadorActualizado.nombres,
          apellidos: registroGanadorActualizado.apellidos,
          fecha_nacimiento: registroGanadorActualizado.fechaNacimiento.toISOString(),
          telefono: registroGanadorActualizado.telefono,
          correo: registroGanadorActualizado.correo,
          version: registroGanadorActualizado.version,
          metadatos_campos: registroGanadorActualizado.metadatosCampos,
        },
      };
    }

    // B. MANEJO DE OPERACION DELETE
    if (tarea.operacion === 'DELETE') {
      await prisma.ciudadano.updateMany({
        where: { id: ciudadanoId },
        data: {
          deletedAt: new Date(),
          updatedAt: new Date(),
        },
      });

      await this.registrarLog(dispositivoId, usuarioId, 'ELIMINACION_LWW');
      return { id: tarea.id, success: true };
    }

    // C. EDICIONES CONCURRENTES (LWW POR CAMPO) SOBRE EL MISMO ID
    const ciudadanoExistente = await prisma.ciudadano.findUnique({
      where: { id: ciudadanoId },
    });

    // Caso C.1: No existe en PostgreSQL -> CREAR
    if (!ciudadanoExistente) {
      await prisma.ciudadano.create({
        data: {
          id: ciudadanoId,
          documentoIdentidad: payloadJson.documento_identidad,
          nombres: payloadJson.nombres,
          apellidos: payloadJson.apellidos,
          fechaNacimiento: new Date(payloadJson.fecha_nacimiento),
          telefono: payloadJson.telefono || null,
          correo: payloadJson.correo || null,
          estadoSincronizacion: 'SINCRONIZADO',
          registradoPorUsuarioId: usuarioId,
          registradoEnDispositivoId: dispositivoId,
          version: payloadJson.version || 1,
          metadatosCampos: payloadJson.metadatos_campos || {},
          createdAt: new Date(payloadJson.created_at || new Date()),
          updatedAt: new Date(),
        },
      });

      await this.registrarLog(dispositivoId, usuarioId, 'CREACION_LWW');
      return { id: tarea.id, success: true };
    }

    // Caso C.2: Ya existe en PostgreSQL -> FUSIONAR LWW POR CAMPO
    const fusion = this.fusionarLwwPorCampo(
      ciudadanoExistente,
      payloadJson,
      (ciudadanoExistente.metadatosCampos as unknown as MetadatosCampos) || {},
      payloadJson.metadatos_campos || {}
    );

    // Actualizar registro en PostgreSQL
    const registroActualizado = await prisma.ciudadano.update({
      where: { id: ciudadanoId },
      data: {
        documentoIdentidad: payloadJson.documento_identidad, // La cédula usualmente no cambia o se mantiene
        nombres: fusion.datos.nombres,
        apellidos: fusion.datos.apellidos,
        fechaNacimiento: new Date(fusion.datos.fecha_nacimiento),
        telefono: fusion.datos.telefono,
        correo: fusion.datos.correo,
        version: Math.max(ciudadanoExistente.version, payloadJson.version) + 1,
        metadatosCampos: fusion.metadatos as any,
        updatedAt: new Date(),
        deletedAt: fusion.datos.deleted_at ? new Date(fusion.datos.deleted_at) : null,
      },
    });

    await this.registrarLog(dispositivoId, usuarioId, 'ACTUALIZACION_LWW');

    // Si el servidor ganó en alguna propiedad (es decir, ignoró la propiedad enviada por el cliente),
    // marcamos que hay un conflicto para obligar al cliente móvil a descargar los datos finales
    return {
      id: tarea.id,
      success: true,
      conflicto: fusion.servidorGano,
      datosServidor: {
        id: registroActualizado.id,
        documento_identidad: registroActualizado.documentoIdentidad,
        nombres: registroActualizado.nombres,
        apellidos: registroActualizado.apellidos,
        fecha_nacimiento: registroActualizado.fechaNacimiento.toISOString(),
        telefono: registroActualizado.telefono,
        correo: registroActualizado.correo,
        version: registroActualizado.version,
        metadatos_campos: registroActualizado.metadatosCampos,
      },
    };
  }

  /**
   * Algoritmo Last Write Wins (LWW) por campo
   */
  private fusionarLwwPorCampo(
    servidor: any,
    cliente: any,
    metadatosServidor: MetadatosCampos,
    metadatosCliente: MetadatosCampos
  ): { datos: any; metadatos: MetadatosCampos; servidorGano: boolean } {
    const camposMutables = ['nombres', 'apellidos', 'fecha_nacimiento', 'telefono', 'correo', 'deleted_at'];
    const datosFusionados: any = {};
    const metadatosFusionados: MetadatosCampos = {};
    let servidorGano = false;

    // Normalizar tipos en servidor para comparación
    const datosServidorNorm = {
      nombres: servidor.nombres,
      apellidos: servidor.apellidos,
      fecha_nacimiento: servidor.fechaNacimiento.toISOString(),
      telefono: servidor.telefono,
      correo: servidor.correo,
      deleted_at: servidor.deletedAt ? servidor.deletedAt.toISOString() : null,
    };

    for (const campo of camposMutables) {
      // Obtener marcas de tiempo de modificación (defecto a epoch si no existen)
      const fechaServidorStr = (metadatosServidor as any)[campo] || new Date(0).toISOString();
      const fechaClienteStr = (metadatosCliente as any)[campo] || new Date(0).toISOString();
      
      const tServidor = new Date(fechaServidorStr).getTime();
      const tCliente = new Date(fechaClienteStr).getTime();

      if (tCliente > tServidor) {
        // Gana el Cliente
        datosFusionados[campo] = (cliente as any)[campo];
        (metadatosFusionados as any)[campo] = fechaClienteStr;
      } else {
        // Gana el Servidor (Last Write Wins) o Empate (gana Servidor por consistencia)
        datosFusionados[campo] = (datosServidorNorm as any)[campo];
        (metadatosFusionados as any)[campo] = fechaServidorStr;
        
        // Si el valor del cliente era diferente y el servidor ganó, marcamos el flag de conflicto
        const valCliente = (cliente as any)[campo];
        const valServidor = (datosServidorNorm as any)[campo];
        if (valCliente !== valServidor) {
          servidorGano = true;
        }
      }
    }

    return {
      datos: datosFusionados,
      metadatos: metadatosFusionados,
      servidorGano,
    };
  }

  private async registrarLog(dispositivoId: string, usuarioId: string, operacion: string): Promise<void> {
    try {
      await prisma.logSincronizacion.create({
        data: {
          dispositivoId,
          usuarioId,
          estado: 'EXITOSO',
          registrosProcesados: 1,
          detalles: `Reconciliación LWW procesada: ${operacion}`,
        },
      });
    } catch (e) {
      // Ignorar
    }
  }
}
