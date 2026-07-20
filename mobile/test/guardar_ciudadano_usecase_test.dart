import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/domain/entities/ciudadano.dart';
import 'package:mobile/domain/repositories/ciudadano_repository.dart';
import 'package:mobile/domain/usecases/guardar_ciudadano_usecase.dart';

class MockCiudadanoRepository extends Mock implements CiudadanoRepository {}
class FakeCiudadano extends Fake implements Ciudadano {}

void main() {
  late GuardarCiudadanoUseCase usecase;
  late MockCiudadanoRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeCiudadano());
  });

  setUp(() {
    mockRepository = MockCiudadanoRepository();
    usecase = GuardarCiudadanoUseCase(mockRepository);
  });

  final tFechaNacimiento = DateTime(1995, 5, 15);

  test('Debe generar un ID y llamar a registrarCiudadano al crear un nuevo registro', () async {
    // Arrange
    when(() => mockRepository.registrarCiudadano(any())).thenAnswer((_) async => {});

    // Act
    await usecase.ejecutar(
      documentoIdentidad: '123456',
      nombres: 'Carlos',
      apellidos: 'Perez',
      fechaNacimiento: tFechaNacimiento,
      registradoPorUsuarioId: 'user-1',
      registradoEnDispositivoId: 'device-1',
    );

    // Assert
    verify(() => mockRepository.registrarCiudadano(any(that: isA<Ciudadano>().having(
      (c) => c.version, 'version inicial', 1
    )))).called(1);
    verifyNever(() => mockRepository.actualizarCiudadano(any()));
  });

  test('Debe llamar a actualizarCiudadano e incrementar versión al editar un ciudadano', () async {
    // Arrange
    when(() => mockRepository.actualizarCiudadano(any())).thenAnswer((_) async => {});
    when(() => mockRepository.obtenerCiudadanoPorId(any())).thenAnswer(
      (_) async => Ciudadano(
        id: 'uuid-existente',
        documentoIdentidad: '123456',
        nombres: 'Carlos',
        apellidos: 'Perez',
        fechaNacimiento: tFechaNacimiento,
        estadoSincronizacion: 'SINCRONIZADO',
        registradoPorUsuarioId: 'user-1',
        registradoEnDispositivoId: 'device-1',
        version: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Act
    await usecase.ejecutar(
      id: 'uuid-existente',
      documentoIdentidad: '123456',
      nombres: 'Carlos Modificado',
      apellidos: 'Perez',
      fechaNacimiento: tFechaNacimiento,
      registradoPorUsuarioId: 'user-1',
      registradoEnDispositivoId: 'device-1',
    );

    // Assert
    verify(() => mockRepository.obtenerCiudadanoPorId('uuid-existente')).called(1);
    verify(() => mockRepository.actualizarCiudadano(any(that: isA<Ciudadano>().having(
      (c) => c.version, 'versión incrementada', 3
    )))).called(1);
    verifyNever(() => mockRepository.registrarCiudadano(any()));
  });
}
