import 'package:drift/drift.dart';
import 'connection/connection_stub.dart'
    if (dart.library.js_util) 'connection/connection_web.dart'
    if (dart.library.ffi) 'connection/connection_native.dart' as conn;

import 'daos/usuario_dao.dart';
import 'daos/ciudadano_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

// Tabla Usuarios
@DataClassName('UsuarioLocal')
class Usuarios extends Table {
  TextColumn get id => text()();
  TextColumn get correo => text().unique()();
  TextColumn get contrasena => text()();
  TextColumn get nombre => text().nullable()();
  TextColumn get rol => text().withDefault(const Constant('REGISTRADOR'))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabla Ciudadanos
@DataClassName('CiudadanoLocal')
class Ciudadanos extends Table {
  TextColumn get id => text()();
  TextColumn get documentoIdentidad => text().unique()();
  TextColumn get nombres => text()();
  TextColumn get apellidos => text()();
  DateTimeColumn get fechaNacimiento => dateTime()();
  TextColumn get telefono => text().nullable()();
  TextColumn get correo => text().nullable()();
  TextColumn get estadoSincronizacion => text().withDefault(const Constant('PENDIENTE'))(); // PENDIENTE, SINCRONIZADO, CONFLICTO
  TextColumn get registradoPorUsuarioId => text().references(Usuarios, #id)();
  TextColumn get registradoEnDispositivoId => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get metadatosCampos => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Tabla Cola de Sincronización (Sync Queue)
@DataClassName('SyncQueueLocal')
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get tablaAfectada => text()(); // ciudadanos, usuarios
  TextColumn get registroId => text()(); // UUID del registro afectado
  TextColumn get operacion => text()(); // INSERT, UPDATE, DELETE
  TextColumn get payload => text()(); // Contenido JSON a enviar al backend
  TextColumn get estado => text().withDefault(const Constant('PENDIENTE'))(); // PENDIENTE, PROCESANDO, ERROR
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  TextColumn get ultimoError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Usuarios, Ciudadanos, SyncQueue], daos: [UsuarioDao, CiudadanoDao, SyncQueueDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(conn.abrirConexion());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        
        // Sembrar el usuario administrador por defecto para soporte de login offline instantáneo
        // Contraseña: admin12345 (hasheada con BCrypt)
        await into(usuarios).insert(UsuariosCompanion.insert(
          id: 'admin-uuid-local',
          correo: 'admin@sirc.gov',
          contrasena: r'$2a$10$QyxXOYvySW4UYpBFL/Ob9uXtJFzgNXsJnZLZ7owMwfk7KiUus7b6G',
          nombre: const Value('Administrador SIRC'),
          rol: const Value('ADMIN'),
          version: const Value(1),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
      },
      onUpgrade: (m, from, to) async {
        // Lógica de migraciones de base de datos futura
      },
    );
  }
}
