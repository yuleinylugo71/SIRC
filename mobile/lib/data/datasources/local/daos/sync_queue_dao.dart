import 'package:drift/drift.dart';
import '../app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue, Ciudadanos])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(AppDatabase db) : super(db);

  Future<void> encolarTarea(SyncQueueLocal tarea) {
    return into(syncQueue).insert(tarea);
  }

  Future<List<SyncQueueLocal>> obtenerTareasPendientes() {
    return (select(syncQueue)
          ..where((t) => t.estado.equals('PENDIENTE') | t.estado.equals('ERROR'))
          ..where((t) => t.intentos.isSmallerThanValue(5))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();
  }

  Future<void> actualizarEstadoTarea({
    required String id,
    required String estado,
    int? intentos,
    String? ultimoError,
  }) {
    return (update(syncQueue)..where((t) => t.id.equals(id)))
        .write(SyncQueueCompanion(
          estado: Value(estado),
          intentos: intentos != null ? Value(intentos) : const Value.absent(),
          ultimoError: ultimoError != null ? Value(ultimoError) : const Value.absent(),
        ));
  }

  Future<void> eliminarTarea(String id) {
    return (delete(syncQueue)..where((t) => t.id.equals(id))).go();
  }

  // Transacción combinada: Guardar ciudadano local y encolar en sync_queue
  Future<void> guardarCiudadanoConCola({
    required CiudadanoLocal ciudadano,
    required SyncQueueLocal tarea,
  }) {
    return transaction(() async {
      await into(ciudadanos).insertOnConflictUpdate(ciudadano);
      await into(syncQueue).insert(tarea);
    });
  }

  // Transacción combinada: Eliminar ciudadano local y encolar en sync_queue
  Future<void> eliminarCiudadanoConCola({
    required String ciudadanoId,
    required SyncQueueLocal tarea,
  }) {
    return transaction(() async {
      await (update(ciudadanos)..where((t) => t.id.equals(ciudadanoId)))
          .write(CiudadanosCompanion(
            deletedAt: Value(DateTime.now()),
            estadoSincronizacion: const Value('PENDIENTE'),
            updatedAt: Value(DateTime.now()),
          ));
      
      await into(syncQueue).insert(tarea);
    });
  }

  Stream<int> contarTareasPendientes() {
    final query = select(syncQueue)
      ..where((t) => t.estado.equals('PENDIENTE') | t.estado.equals('ERROR'))
      ..where((t) => t.intentos.isSmallerThanValue(5));
    return query.watch().map((list) => list.length);
  }
}
