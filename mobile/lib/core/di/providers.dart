import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/daos/ciudadano_dao.dart';
import '../../data/datasources/local/daos/sync_queue_dao.dart';
import '../../data/datasources/local/daos/usuario_dao.dart';
import '../../data/repositories/ciudadano_repository_impl.dart';
import '../../data/repositories/sync_repository_impl.dart';
import '../../data/repositories/usuario_repository_impl.dart';
import '../../domain/repositories/ciudadano_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../domain/usecases/eliminar_ciudadano_usecase.dart';
import '../../domain/usecases/guardar_ciudadano_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/obtener_ciudadanos_usecase.dart';
import '../../domain/usecases/procesar_sincronizacion_usecase.dart';
import '../../domain/usecases/registrar_usuario_usecase.dart';
import '../network/dispositivo_info.dart';
import '../network/network_info.dart';

// 1. Proveedores de Infraestructura
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Debe ser sobrescrito en main.dart');
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://pebbly-placard-fling.ngrok-free.dev',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'ngrok-skip-browser-warning': 'true',
    },
  ));
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(connectivityProvider));
});

// 2. Proveedores de DAOs (Drift)
final usuarioDaoProvider = Provider<UsuarioDao>((ref) {
  return ref.watch(appDatabaseProvider).usuarioDao;
});

final ciudadanoDaoProvider = Provider<CiudadanoDao>((ref) {
  return ref.watch(appDatabaseProvider).ciudadanoDao;
});

final syncQueueDaoProvider = Provider<SyncQueueDao>((ref) {
  return ref.watch(appDatabaseProvider).syncQueueDao;
});

// 3. Proveedores de Repositorios (Interfaces -> Implementaciones)
final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return UsuarioRepositoryImpl(
    ref.read(usuarioDaoProvider),
    ref.read(dioProvider),
    ref.read(sharedPreferencesProvider),
  );
});

final ciudadanoRepositoryProvider = Provider<CiudadanoRepository>((ref) {
  return CiudadanoRepositoryImpl(
    ref.read(ciudadanoDaoProvider),
    ref.read(syncQueueDaoProvider),
  );
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepositoryImpl(
    ref.read(syncQueueDaoProvider),
    ref.read(ciudadanoDaoProvider),
    ref.read(dioProvider),
    ref.read(sharedPreferencesProvider),
  );
});

final dispositivoInfoProvider = Provider<DispositivoInfo>((ref) {
  return DispositivoInfo(ref.read(sharedPreferencesProvider));
});

// 4. Proveedores de Casos de Uso
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    usuarioRepository: ref.read(usuarioRepositoryProvider),
    networkInfo: ref.read(networkInfoProvider),
    dispositivoInfo: ref.read(dispositivoInfoProvider),
  );
});

final guardarCiudadanoUseCaseProvider = Provider<GuardarCiudadanoUseCase>((ref) {
  return GuardarCiudadanoUseCase(ref.read(ciudadanoRepositoryProvider));
});

final obtenerCiudadanosUseCaseProvider = Provider<ObtenerCiudadanosUseCase>((ref) {
  return ObtenerCiudadanosUseCase(ref.read(ciudadanoRepositoryProvider));
});

final eliminarCiudadanoUseCaseProvider = Provider<EliminarCiudadanoUseCase>((ref) {
  return EliminarCiudadanoUseCase(ref.read(ciudadanoRepositoryProvider));
});

final procesarSincronizacionUseCaseProvider = Provider<ProcesarSincronizacionUseCase>((ref) {
  return ProcesarSincronizacionUseCase(ref.read(syncRepositoryProvider));
});

final registrarUsuarioUseCaseProvider = Provider<RegistrarUsuarioUseCase>((ref) {
  return RegistrarUsuarioUseCase(ref.read(usuarioRepositoryProvider));
});
