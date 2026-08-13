import 'package:drift/drift.dart';
import '../app_database.dart';

part 'ciudadano_dao.g.dart';

@DriftAccessor(tables: [Ciudadanos])
class CiudadanoDao extends DatabaseAccessor<AppDatabase> with _$CiudadanoDaoMixin {
  CiudadanoDao(AppDatabase db) : super(db);

  Stream<List<CiudadanoLocal>> listarCiudadanosReactivo({String? usuarioId, String? rol}) {
    final query = select(ciudadanos)..where((t) => t.deletedAt.isNull());
    if (!_esAdmin(rol) && usuarioId != null && usuarioId.isNotEmpty) {
      query.where((t) => t.registradoPorUsuarioId.equals(usuarioId));
    }
    return query.watch();
  }

  Future<List<CiudadanoLocal>> listarCiudadanos({String? usuarioId, String? rol}) {
    final query = select(ciudadanos)..where((t) => t.deletedAt.isNull());
    if (!_esAdmin(rol) && usuarioId != null && usuarioId.isNotEmpty) {
      query.where((t) => t.registradoPorUsuarioId.equals(usuarioId));
    }
    return query.get();
  }

  Future<CiudadanoLocal?> obtenerCiudadanoPorId(String id) {
    return (select(ciudadanos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> guardarCiudadano(CiudadanoLocal ciudadano) {
    return into(ciudadanos).insertOnConflictUpdate(ciudadano);
  }

  Future<void> registrarVersionAnterior(
    CiudadanoLocal ciudadano, {
    required String historialId,
    required String motivo,
  }) async {
    await customInsert(
      '''
      INSERT INTO ciudadano_historial (
        id,
        ciudadano_id,
        version,
        documento_identidad,
        nombres,
        apellidos,
        fecha_nacimiento,
        telefono,
        correo,
        estado_sincronizacion,
        registrado_por_usuario_id,
        registrado_en_dispositivo_id,
        metadatos_campos,
        original_created_at,
        original_updated_at,
        snapshot_created_at,
        motivo
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(historialId),
        Variable<String>(ciudadano.id),
        Variable<int>(ciudadano.version),
        Variable<String>(ciudadano.documentoIdentidad),
        Variable<String>(ciudadano.nombres),
        Variable<String>(ciudadano.apellidos),
        Variable<DateTime>(ciudadano.fechaNacimiento),
        Variable<String>(ciudadano.telefono),
        Variable<String>(ciudadano.correo),
        Variable<String>(ciudadano.estadoSincronizacion),
        Variable<String>(ciudadano.registradoPorUsuarioId),
        Variable<String>(ciudadano.registradoEnDispositivoId),
        Variable<String>(ciudadano.metadatosCampos),
        Variable<DateTime>(ciudadano.createdAt),
        Variable<DateTime>(ciudadano.updatedAt),
        Variable<DateTime>(DateTime.now()),
        Variable<String>(motivo),
      ],
      updates: {ciudadanos},
    );
  }

  Future<List<CiudadanoHistorialLocal>> listarHistorialCiudadano(
      String ciudadanoId) async {
    final rows = await customSelect(
      '''
      SELECT
        id,
        ciudadano_id AS ciudadanoId,
        version,
        documento_identidad AS documentoIdentidad,
        nombres,
        apellidos,
        fecha_nacimiento AS fechaNacimiento,
        telefono,
        correo,
        estado_sincronizacion AS estadoSincronizacion,
        registrado_por_usuario_id AS registradoPorUsuarioId,
        registrado_en_dispositivo_id AS registradoEnDispositivoId,
        metadatos_campos AS metadatosCampos,
        original_created_at AS originalCreatedAt,
        original_updated_at AS originalUpdatedAt,
        snapshot_created_at AS snapshotCreatedAt,
        motivo
      FROM ciudadano_historial
      WHERE ciudadano_id = ?
      ORDER BY version DESC, snapshot_created_at DESC
      ''',
      variables: [Variable<String>(ciudadanoId)],
      readsFrom: {ciudadanos},
    ).get();

    return rows.map((row) {
      return CiudadanoHistorialLocal(
        id: row.read<String>('id'),
        ciudadanoId: row.read<String>('ciudadanoId'),
        version: row.read<int>('version'),
        documentoIdentidad: row.read<String>('documentoIdentidad'),
        nombres: row.read<String>('nombres'),
        apellidos: row.read<String>('apellidos'),
        fechaNacimiento: row.read<DateTime>('fechaNacimiento'),
        telefono: row.readNullable<String>('telefono'),
        correo: row.readNullable<String>('correo'),
        estadoSincronizacion: row.read<String>('estadoSincronizacion'),
        registradoPorUsuarioId: row.read<String>('registradoPorUsuarioId'),
        registradoEnDispositivoId:
            row.read<String>('registradoEnDispositivoId'),
        metadatosCampos: row.readNullable<String>('metadatosCampos'),
        originalCreatedAt: row.read<DateTime>('originalCreatedAt'),
        originalUpdatedAt: row.read<DateTime>('originalUpdatedAt'),
        snapshotCreatedAt: row.read<DateTime>('snapshotCreatedAt'),
        motivo: row.read<String>('motivo'),
      );
    }).toList();
  }

  Future<void> eliminarCiudadanoLogico(String id) {
    return (update(ciudadanos)..where((t) => t.id.equals(id)))
        .write(CiudadanosCompanion(
          deletedAt: Value(DateTime.now()),
          estadoSincronizacion: const Value('PENDIENTE'),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<void> actualizarEstadoSincronizacion(String id, String estado, int version) {
    return (update(ciudadanos)..where((t) => t.id.equals(id)))
        .write(CiudadanosCompanion(
          estadoSincronizacion: Value(estado),
          version: Value(version),
        ));
  }

  Stream<int> contarCiudadanos({String? usuarioId, String? rol}) {
    final query = select(ciudadanos)..where((t) => t.deletedAt.isNull());
    if (!_esAdmin(rol) && usuarioId != null && usuarioId.isNotEmpty) {
      query.where((t) => t.registradoPorUsuarioId.equals(usuarioId));
    }
    return query.watch().map((list) => list.length);
  }

  bool _esAdmin(String? rol) => rol?.trim().toUpperCase() == 'ADMIN';
}

class CiudadanoHistorialLocal {
  final String id;
  final String ciudadanoId;
  final int version;
  final String documentoIdentidad;
  final String nombres;
  final String apellidos;
  final DateTime fechaNacimiento;
  final String? telefono;
  final String? correo;
  final String estadoSincronizacion;
  final String registradoPorUsuarioId;
  final String registradoEnDispositivoId;
  final String? metadatosCampos;
  final DateTime originalCreatedAt;
  final DateTime originalUpdatedAt;
  final DateTime snapshotCreatedAt;
  final String motivo;

  const CiudadanoHistorialLocal({
    required this.id,
    required this.ciudadanoId,
    required this.version,
    required this.documentoIdentidad,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    this.telefono,
    this.correo,
    required this.estadoSincronizacion,
    required this.registradoPorUsuarioId,
    required this.registradoEnDispositivoId,
    this.metadatosCampos,
    required this.originalCreatedAt,
    required this.originalUpdatedAt,
    required this.snapshotCreatedAt,
    required this.motivo,
  });
}
