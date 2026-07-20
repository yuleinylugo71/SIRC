import 'package:drift/drift.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ciudadano.dart';
import '../../domain/repositories/ciudadano_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/ciudadano_dao.dart';
import '../datasources/local/daos/sync_queue_dao.dart';

class CiudadanoRepositoryImpl implements CiudadanoRepository {
  final CiudadanoDao _ciudadanoDao;
  final SyncQueueDao _syncQueueDao;
  final _uuid = const Uuid();

  CiudadanoRepositoryImpl(this._ciudadanoDao, this._syncQueueDao);

  @override
  Stream<List<Ciudadano>> listarCiudadanosReactivo({String? usuarioId, String? rol}) {
    return _ciudadanoDao.listarCiudadanosReactivo(usuarioId: usuarioId, rol: rol).map(
      (locales) => locales.map(_mapToDomain).toList(),
    );
  }

  @override
  Future<List<Ciudadano>> listarCiudadanos({String? usuarioId, String? rol}) async {
    final locales = await _ciudadanoDao.listarCiudadanos(usuarioId: usuarioId, rol: rol);
    return locales.map(_mapToDomain).toList();
  }

  @override
  Future<Ciudadano?> obtenerCiudadanoPorId(String id) async {
    final local = await _ciudadanoDao.obtenerCiudadanoPorId(id);
    if (local == null) return null;
    return _mapToDomain(local);
  }

  @override
  Future<void> registrarCiudadano(Ciudadano ciudadano) async {
    final ahoraStr = DateTime.now().toIso8601String();
    
    // Inicializar marcas de tiempo para LWW por campo
    final metadatosIniciales = {
      'nombres': ahoraStr,
      'apellidos': ahoraStr,
      'fecha_nacimiento': ahoraStr,
      'telefono': ahoraStr,
      'correo': ahoraStr,
      'deleted_at': ahoraStr,
    };

    final metadatosJsonStr = jsonEncode(metadatosIniciales);

    final local = _mapToLocal(ciudadano).copyWith(
      metadatosCampos: Value(metadatosJsonStr),
    );
    
    final payloadMap = {
      'id': ciudadano.id,
      'documento_identidad': ciudadano.documentoIdentidad,
      'nombres': ciudadano.nombres,
      'apellidos': ciudadano.apellidos,
      'fecha_nacimiento': ciudadano.fechaNacimiento.toIso8601String(),
      'telefono': ciudadano.telefono,
      'correo': ciudadano.correo,
      'registrado_por_usuario_id': ciudadano.registradoPorUsuarioId,
      'registrado_en_dispositivo_id': ciudadano.registradoEnDispositivoId,
      'version': ciudadano.version,
      'metadatos_campos': metadatosIniciales,
    };

    final tarea = SyncQueueLocal(
      id: _uuid.v4(),
      tablaAfectada: 'ciudadanos',
      registroId: ciudadano.id,
      operacion: 'INSERT',
      payload: jsonEncode(payloadMap),
      estado: 'PENDIENTE',
      intentos: 0,
      createdAt: DateTime.now(),
    );

    await _syncQueueDao.guardarCiudadanoConCola(ciudadano: local, tarea: tarea);
  }

  @override
  Future<void> actualizarCiudadano(Ciudadano ciudadano) async {
    final ciudadanoExistente = await _ciudadanoDao.obtenerCiudadanoPorId(ciudadano.id);
    final ahoraStr = DateTime.now().toIso8601String();

    Map<String, dynamic> metadatosActuales = {};
    if (ciudadanoExistente != null && ciudadanoExistente.metadatosCampos != null) {
      try {
        metadatosActuales = jsonDecode(ciudadanoExistente.metadatosCampos!);
      } catch (e) {
        // Ignorar
      }
    }

    // Comparar cada campo para actualizar su marca de tiempo individual sólo si mutó
    if (ciudadanoExistente == null || ciudadanoExistente.nombres != ciudadano.nombres) {
      metadatosActuales['nombres'] = ahoraStr;
    }
    if (ciudadanoExistente == null || ciudadanoExistente.apellidos != ciudadano.apellidos) {
      metadatosActuales['apellidos'] = ahoraStr;
    }
    if (ciudadanoExistente == null || ciudadanoExistente.fechaNacimiento != ciudadano.fechaNacimiento) {
      metadatosActuales['fecha_nacimiento'] = ahoraStr;
    }
    if (ciudadanoExistente == null || ciudadanoExistente.telefono != ciudadano.telefono) {
      metadatosActuales['telefono'] = ahoraStr;
    }
    if (ciudadanoExistente == null || ciudadanoExistente.correo != ciudadano.correo) {
      metadatosActuales['correo'] = ahoraStr;
    }

    final metadatosJsonStr = jsonEncode(metadatosActuales);

    final local = _mapToLocal(ciudadano).copyWith(
      metadatosCampos: Value(metadatosJsonStr),
    );

    final payloadMap = {
      'id': ciudadano.id,
      'documento_identidad': ciudadano.documentoIdentidad,
      'nombres': ciudadano.nombres,
      'apellidos': ciudadano.apellidos,
      'fecha_nacimiento': ciudadano.fechaNacimiento.toIso8601String(),
      'telefono': ciudadano.telefono,
      'correo': ciudadano.correo,
      'registrado_por_usuario_id': ciudadano.registradoPorUsuarioId,
      'registrado_en_dispositivo_id': ciudadano.registradoEnDispositivoId,
      'version': ciudadano.version,
      'metadatos_campos': metadatosActuales,
    };

    final tarea = SyncQueueLocal(
      id: _uuid.v4(),
      tablaAfectada: 'ciudadanos',
      registroId: ciudadano.id,
      operacion: 'UPDATE',
      payload: jsonEncode(payloadMap),
      estado: 'PENDIENTE',
      intentos: 0,
      createdAt: DateTime.now(),
    );

    await _syncQueueDao.guardarCiudadanoConCola(ciudadano: local, tarea: tarea);
  }

  @override
  Future<void> eliminarCiudadano(String id) async {
    final ahoraStr = DateTime.now().toIso8601String();
    
    // Al eliminar, actualizamos los metadatos indicando cuándo se eliminó lógicamente
    final ciudadanoExistente = await _ciudadanoDao.obtenerCiudadanoPorId(id);
    Map<String, dynamic> metadatosActuales = {};
    if (ciudadanoExistente != null && ciudadanoExistente.metadatosCampos != null) {
      try {
        metadatosActuales = jsonDecode(ciudadanoExistente.metadatosCampos!);
      } catch (e) {
        // Ignorar
      }
    }
    metadatosActuales['deleted_at'] = ahoraStr;

    final tarea = SyncQueueLocal(
      id: _uuid.v4(),
      tablaAfectada: 'ciudadanos',
      registroId: id,
      operacion: 'DELETE',
      payload: jsonEncode({
        'id': id,
        'metadatos_campos': metadatosActuales,
      }),
      estado: 'PENDIENTE',
      intentos: 0,
      createdAt: DateTime.now(),
    );

    await _syncQueueDao.eliminarCiudadanoConCola(ciudadanoId: id, tarea: tarea);
  }

  Ciudadano _mapToDomain(CiudadanoLocal local) {
    return Ciudadano(
      id: local.id,
      documentoIdentidad: local.documentoIdentidad,
      nombres: local.nombres,
      apellidos: local.apellidos,
      fechaNacimiento: local.fechaNacimiento,
      telefono: local.telefono,
      correo: local.correo,
      estadoSincronizacion: local.estadoSincronizacion,
      registradoPorUsuarioId: local.registradoPorUsuarioId,
      registradoEnDispositivoId: local.registradoEnDispositivoId,
      version: local.version,
      metadatosCampos: local.metadatosCampos,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
    );
  }

  CiudadanoLocal _mapToLocal(Ciudadano domain) {
    return CiudadanoLocal(
      id: domain.id,
      documentoIdentidad: domain.documentoIdentidad,
      nombres: domain.nombres,
      apellidos: domain.apellidos,
      fechaNacimiento: domain.fechaNacimiento,
      telefono: domain.telefono,
      correo: domain.correo,
      estadoSincronizacion: domain.estadoSincronizacion,
      registradoPorUsuarioId: domain.registradoPorUsuarioId,
      registradoEnDispositivoId: domain.registradoEnDispositivoId,
      version: domain.version,
      metadatosCampos: domain.metadatosCampos,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt,
    );
  }
}
