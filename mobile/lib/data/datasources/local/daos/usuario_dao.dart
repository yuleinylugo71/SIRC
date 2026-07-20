import 'package:drift/drift.dart';
import '../app_database.dart';

part 'usuario_dao.g.dart';

@DriftAccessor(tables: [Usuarios])
class UsuarioDao extends DatabaseAccessor<AppDatabase> with _$UsuarioDaoMixin {
  UsuarioDao(AppDatabase db) : super(db);

  Future<UsuarioLocal?> obtenerUsuarioPorId(String id) {
    return (select(usuarios)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<UsuarioLocal?> obtenerUsuarioActivo() {
    return (select(usuarios)..where((t) => t.deletedAt.isNull())).getSingleOrNull();
  }

  Future<void> guardarUsuario(UsuarioLocal usuario) async {
    await (delete(usuarios)..where((t) => t.correo.equals(usuario.correo))).go();
    await into(usuarios).insertOnConflictUpdate(usuario);
  }

  Future<void> eliminarUsuario(String id) {
    return (update(usuarios)..where((t) => t.id.equals(id)))
        .write(UsuariosCompanion(deletedAt: Value(DateTime.now())));
  }
}
