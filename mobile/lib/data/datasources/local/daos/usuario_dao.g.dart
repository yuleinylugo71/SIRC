// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_dao.dart';

// ignore_for_file: type=lint
mixin _$UsuarioDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsuariosTable get usuarios => attachedDatabase.usuarios;
  UsuarioDaoManager get managers => UsuarioDaoManager(this);
}

class UsuarioDaoManager {
  final _$UsuarioDaoMixin _db;
  UsuarioDaoManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db.attachedDatabase, _db.usuarios);
}
