import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/sync_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/ciudadano_dao.dart';
import '../datasources/local/daos/sync_queue_dao.dart';

class SyncRepositoryImpl implements SyncRepository {
  final SyncQueueDao _syncQueueDao;
  final CiudadanoDao _ciudadanoDao;
  final Dio _dio;
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  static const String _keyAuthToken = 'auth_token';

  SyncRepositoryImpl(this._syncQueueDao, this._ciudadanoDao, this._dio, this._prefs);

  @override
  Future<int> obtenerCantidadTareasPendientes() async {
    final pendientes = await _syncQueueDao.obtenerTareasPendientes();
    return pendientes.length;
  }

  @override
  Future<void> procesarColaSincronizacion() async {
    final pendientes = await _syncQueueDao.obtenerTareasPendientes();
    final token = _prefs.getString(_keyAuthToken);
    if (token == null || token.isEmpty) {
      throw Exception('Sincronización abortada: Sesión inactiva localmente.');
    }

    if (pendientes.isEmpty) {
      await _descargarCiudadanosServidor(token);
      return;
    }

    final tareasPayload = pendientes.map((t) => {
      'id': t.id,
      'tablaAfectada': t.tablaAfectada,
      'registroId': t.registroId,
      'operacion': t.operacion,
      'payload': t.payload,
    }).toList();

    try {
      final response = await _dio.post(
        '/api/sync',
        data: {'tareas': tareasPayload},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final resultados = response.data['data'] as List<dynamic>;

        for (final res in resultados) {
          final tareaId = res['id'] as String;
          final success = res['success'] as bool;
          final conflicto = res['conflicto'] as bool? ?? false;
          final unificadoId = res['unificadoId'] as String?;
          final datosServidor = res['datosServidor'];
          final errorMsg = res['error'] as String?;

          final tareaLocal = pendientes.firstWhere((t) => t.id == tareaId);

          if (success) {
            // Eliminar tarea de la cola SQLite local
            await _syncQueueDao.eliminarTarea(tareaId);

            if (tareaLocal.tablaAfectada == 'ciudadanos') {
              final payloadJson = jsonDecode(tareaLocal.payload);
              final ciudadanoIdLocal = tareaLocal.registroId;

              if (tareaLocal.operacion != 'DELETE') {
                if (unificadoId != null && datosServidor != null) {
                  // A. RESOLUCIÓN DE COLISIÓN DE DOCUMENTO (REMAPEO DE ID GANADOR):
                  // 1. Eliminar el registro provisional local viejo
                  final ciudadanoAnterior =
                      await _ciudadanoDao.obtenerCiudadanoPorId(ciudadanoIdLocal);
                  if (ciudadanoAnterior != null) {
                    await _ciudadanoDao.registrarVersionAnterior(
                      ciudadanoAnterior,
                      historialId: _uuid.v4(),
                      motivo: 'Antes de unificar por sincronizacion',
                    );
                  }
                  await _ciudadanoDao.eliminarCiudadanoLogico(ciudadanoIdLocal); 
                  
                  // 2. Insertar/Actualizar el registro unificado bajo el UUID ganador del servidor
                  final ciudadanoUnificado = CiudadanoLocal(
                    id: unificadoId,
                    documentoIdentidad: datosServidor['documento_identidad'] as String,
                    nombres: datosServidor['nombres'] as String,
                    apellidos: datosServidor['apellidos'] as String,
                    fechaNacimiento: DateTime.parse(datosServidor['fecha_nacimiento'] as String),
                    telefono: datosServidor['telefono'] as String?,
                    correo: datosServidor['correo'] as String?,
                    estadoSincronizacion: 'SINCRONIZADO',
                    registradoPorUsuarioId: payloadJson['registrado_por_usuario_id'] as String,
                    registradoEnDispositivoId: payloadJson['registrado_en_dispositivo_id'] as String,
                    version: datosServidor['version'] as int,
                    metadatosCampos: jsonEncode(datosServidor['metadatos_campos'] ?? {}),
                    createdAt: DateTime.parse(payloadJson['created_at'] as String? ?? DateTime.now().toIso8601String()),
                    updatedAt: DateTime.now(),
                  );
                  
                  await _ciudadanoDao.guardarCiudadano(ciudadanoUnificado);
                } else if (conflicto && datosServidor != null) {
                  // B. RESOLUCIÓN DE CONFLICTO LWW (EL SERVIDOR FUSIONÓ CAMPOS):
                  // Sobrescribimos el ciudadano local existente con los datos finales
                  final ciudadanoAnterior =
                      await _ciudadanoDao.obtenerCiudadanoPorId(ciudadanoIdLocal);
                  if (ciudadanoAnterior != null) {
                    await _ciudadanoDao.registrarVersionAnterior(
                      ciudadanoAnterior,
                      historialId: _uuid.v4(),
                      motivo: 'Antes de resolver conflicto de sincronizacion',
                    );
                  }
                  final ciudadanoConflicto = CiudadanoLocal(
                    id: ciudadanoIdLocal,
                    documentoIdentidad: datosServidor['documento_identidad'] as String,
                    nombres: datosServidor['nombres'] as String,
                    apellidos: datosServidor['apellidos'] as String,
                    fechaNacimiento: DateTime.parse(datosServidor['fecha_nacimiento'] as String),
                    telefono: datosServidor['telefono'] as String?,
                    correo: datosServidor['correo'] as String?,
                    estadoSincronizacion: 'SINCRONIZADO',
                    registradoPorUsuarioId: payloadJson['registrado_por_usuario_id'] as String,
                    registradoEnDispositivoId: payloadJson['registrado_en_dispositivo_id'] as String,
                    version: datosServidor['version'] as int,
                    metadatosCampos: jsonEncode(datosServidor['metadatos_campos'] ?? {}),
                    createdAt: DateTime.parse(payloadJson['created_at'] as String? ?? DateTime.now().toIso8601String()),
                    updatedAt: DateTime.now(),
                  );

                  await _ciudadanoDao.guardarCiudadano(ciudadanoConflicto);
                } else {
                  // C. FLUJO EXITOSO ESTÁNDAR: Actualizamos estado local
                  final versionSincronizada = payloadJson['version'] as int? ?? 1;
                  await _ciudadanoDao.actualizarEstadoSincronizacion(
                    ciudadanoIdLocal,
                    'SINCRONIZADO',
                    versionSincronizada,
                  );
                }
              }
            }
          } else {
            // Error parcial
            await _syncQueueDao.actualizarEstadoTarea(
              id: tareaId,
              estado: 'ERROR',
              intentos: tareaLocal.intentos + 1,
              ultimoError: errorMsg ?? 'Fallo en validación de servidor.',
            );
          }
        }

        await _descargarCiudadanosServidor(token);
      }
    } on DioException catch (e) {
      final networkError = e.response?.data?['message'] ?? 'Fallo de red en la comunicación.';
      for (final t in pendientes) {
        await _syncQueueDao.actualizarEstadoTarea(
          id: t.id,
          estado: 'ERROR',
          intentos: t.intentos + 1,
          ultimoError: networkError,
        );
      }
      throw Exception(networkError);
    }
  }

  Future<void> _descargarCiudadanosServidor(String token) async {
    final response = await _dio.get(
      '/api/citizens',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) return;

    final data = response.data['data'] as List<dynamic>;
    for (final raw in data) {
      final json = raw as Map<String, dynamic>;
      final id = json['id'] as String;
      final local = await _ciudadanoDao.obtenerCiudadanoPorId(id);

      if (local != null && local.estadoSincronizacion == 'PENDIENTE') {
        continue;
      }

      final ciudadano = CiudadanoLocal(
        id: id,
        documentoIdentidad:
            (json['documentoIdentidad'] ?? json['documento_identidad'])
                as String,
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        fechaNacimiento: DateTime.parse(
          (json['fechaNacimiento'] ?? json['fecha_nacimiento']) as String,
        ),
        telefono: json['telefono'] as String?,
        correo: json['correo'] as String?,
        estadoSincronizacion:
            (json['estadoSincronizacion'] ?? json['estado_sincronizacion'])
                    as String? ??
                'SINCRONIZADO',
        registradoPorUsuarioId:
            (json['registradoPorUsuarioId'] ??
                json['registrado_por_usuario_id']) as String,
        registradoEnDispositivoId:
            (json['registradoEnDispositivoId'] ??
                json['registrado_en_dispositivo_id']) as String,
        version: json['version'] as int? ?? 1,
        metadatosCampos: jsonEncode(
          json['metadatosCampos'] ?? json['metadatos_campos'] ?? {},
        ),
        createdAt: DateTime.parse(
          (json['createdAt'] ?? json['created_at']) as String,
        ),
        updatedAt: DateTime.parse(
          (json['updatedAt'] ?? json['updated_at']) as String,
        ),
      );

      await _ciudadanoDao.guardarCiudadano(ciudadano);
    }
  }
}
