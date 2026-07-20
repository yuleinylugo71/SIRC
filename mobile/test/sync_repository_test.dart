import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/data/repositories/sync_repository_impl.dart';
import 'package:mobile/data/datasources/local/app_database.dart';
import 'package:mobile/data/datasources/local/daos/ciudadano_dao.dart';
import 'package:mobile/data/datasources/local/daos/sync_queue_dao.dart';

class MockSyncQueueDao extends Mock implements SyncQueueDao {}
class MockCiudadanoDao extends Mock implements CiudadanoDao {}
class MockDio extends Mock implements Dio {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class FakeCiudadanoLocal extends Fake implements CiudadanoLocal {}
class FakeSyncQueueLocal extends Fake implements SyncQueueLocal {}

void main() {
  late SyncRepositoryImpl repository;
  late MockSyncQueueDao mockSyncQueueDao;
  late MockCiudadanoDao mockCiudadanoDao;
  late MockDio mockDio;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(FakeCiudadanoLocal());
    registerFallbackValue(FakeSyncQueueLocal());
  });

  setUp(() {
    mockSyncQueueDao = MockSyncQueueDao();
    mockCiudadanoDao = MockCiudadanoDao();
    mockDio = MockDio();
    mockPrefs = MockSharedPreferences();
    repository = SyncRepositoryImpl(mockSyncQueueDao, mockCiudadanoDao, mockDio, mockPrefs);
  });

  test('Debe procesar cola local y eliminar tareas sincronizadas exitosamente', () async {
    // Arrange
    final tTarea = SyncQueueLocal(
      id: 'tarea-uuid-1',
      tablaAfectada: 'ciudadanos',
      registroId: 'ciudadano-uuid-1',
      operacion: 'INSERT',
      payload: jsonEncode({'id': 'ciudadano-uuid-1', 'version': 1}),
      estado: 'PENDIENTE',
      intentos: 0,
      createdAt: DateTime.now(),
    );

    when(() => mockSyncQueueDao.obtenerTareasPendientes()).thenAnswer((_) async => [tTarea]);
    when(() => mockPrefs.getString('auth_token')).thenReturn('token-jwt');
    
    final mockResponse = Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: {
        'data': [
          {
            'id': 'tarea-uuid-1',
            'success': true,
            'conflicto': false,
            'unificadoId': null,
          }
        ]
      },
    );

    when(() => mockDio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => mockResponse);

    when(() => mockSyncQueueDao.eliminarTarea(any())).thenAnswer((_) async => 1);
    when(() => mockCiudadanoDao.actualizarEstadoSincronizacion(any(), any(), any())).thenAnswer((_) async => true);

    // Act
    await repository.procesarColaSincronizacion();

    // Assert
    verify(() => mockSyncQueueDao.obtenerTareasPendientes()).called(1);
    verify(() => mockDio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).called(1);
    verify(() => mockSyncQueueDao.eliminarTarea('tarea-uuid-1')).called(1);
    verify(() => mockCiudadanoDao.actualizarEstadoSincronizacion('ciudadano-uuid-1', 'SINCRONIZADO', 1)).called(1);
  });
}
