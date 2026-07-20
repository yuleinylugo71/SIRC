// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ciudadano_dao.dart';

// ignore_for_file: type=lint
mixin _$CiudadanoDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsuariosTable get usuarios => attachedDatabase.usuarios;
  $CiudadanosTable get ciudadanos => attachedDatabase.ciudadanos;
  CiudadanoDaoManager get managers => CiudadanoDaoManager(this);
}

class CiudadanoDaoManager {
  final _$CiudadanoDaoMixin _db;
  CiudadanoDaoManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db.attachedDatabase, _db.usuarios);
  $$CiudadanosTableTableManager get ciudadanos =>
      $$CiudadanosTableTableManager(_db.attachedDatabase, _db.ciudadanos);
}
