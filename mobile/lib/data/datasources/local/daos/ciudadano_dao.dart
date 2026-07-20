import 'package:drift/drift.dart';
import '../app_database.dart';

part 'ciudadano_dao.g.dart';

@DriftAccessor(tables: [Ciudadanos])
class CiudadanoDao extends DatabaseAccessor<AppDatabase> with _$CiudadanoDaoMixin {
  CiudadanoDao(AppDatabase db) : super(db);

  Stream<List<CiudadanoLocal>> listarCiudadanosReactivo({String? usuarioId, String? rol}) {
    final query = select(ciudadanos)..where((t) => t.deletedAt.isNull());
    if (rol != 'ADMIN' && usuarioId != null && usuarioId.isNotEmpty) {
      query.where((t) => t.registradoPorUsuarioId.equals(usuarioId));
    }
    return query.watch();
  }

  Future<List<CiudadanoLocal>> listarCiudadanos({String? usuarioId, String? rol}) {
    final query = select(ciudadanos)..where((t) => t.deletedAt.isNull());
    if (rol != 'ADMIN' && usuarioId != null && usuarioId.isNotEmpty) {
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
    if (rol != 'ADMIN' && usuarioId != null && usuarioId.isNotEmpty) {
      query.where((t) => t.registradoPorUsuarioId.equals(usuarioId));
    }
    return query.watch().map((list) => list.length);
  }
}
