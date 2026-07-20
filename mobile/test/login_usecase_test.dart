import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/core/network/dispositivo_info.dart';
import 'package:mobile/domain/entities/usuario.dart';
import 'package:mobile/domain/repositories/usuario_repository.dart';
import 'package:mobile/domain/usecases/login_usecase.dart';

class MockUsuarioRepository extends Mock implements UsuarioRepository {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
class MockDispositivoInfo extends Mock implements DispositivoInfo {}

void main() {
  late LoginUseCase usecase;
  late MockUsuarioRepository mockRepository;
  late MockNetworkInfo mockNetworkInfo;
  late MockDispositivoInfo mockDispositivoInfo;

  setUp(() {
    mockRepository = MockUsuarioRepository();
    mockNetworkInfo = MockNetworkInfo();
    mockDispositivoInfo = MockDispositivoInfo();
    usecase = LoginUseCase(
      usuarioRepository: mockRepository,
      networkInfo: mockNetworkInfo,
      dispositivoInfo: mockDispositivoInfo,
    );
  });

  const tCorreo = 'test@sirc.gov';
  const tContrasena = 'contrasena123';
  const tUsuarioId = 'uuid-usuario-1';
  final tUsuario = Usuario(
    id: tUsuarioId,
    correo: tCorreo,
    nombre: 'Usuario Test',
    rol: 'REGISTRADOR',
    version: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test('Debe llamar al login ONLINE si hay conexión a internet', () async {
    // Arrange
    when(() => mockNetworkInfo.estaConectado).thenAnswer((_) async => true);
    when(() => mockDispositivoInfo.obtenerDeviceUuid()).thenReturn('device-uuid');
    when(() => mockDispositivoInfo.obtenerNombreDispositivo()).thenReturn('device-name');
    when(() => mockRepository.loginOnline(
          correo: any(named: 'correo'),
          contrasena: any(named: 'contrasena'),
          dispositivoCodigo: any(named: 'dispositivoCodigo'),
          dispositivoNombre: any(named: 'dispositivoNombre'),
        )).thenAnswer((_) async => tUsuario);

    // Act
    final resultado = await usecase.ejecutar(correo: tCorreo, contrasena: tContrasena);

    // Assert
    expect(resultado, tUsuario);
    verify(() => mockNetworkInfo.estaConectado).called(1);
    verify(() => mockRepository.loginOnline(
          correo: tCorreo,
          contrasena: tContrasena,
          dispositivoCodigo: 'device-uuid',
          dispositivoNombre: 'device-name',
        )).called(1);
    verifyNever(() => mockRepository.loginOffline(correo: any(named: 'correo'), contrasena: any(named: 'contrasena')));
  });

  test('Debe llamar al login OFFLINE si no hay conexión a internet', () async {
    // Arrange
    when(() => mockNetworkInfo.estaConectado).thenAnswer((_) async => false);
    when(() => mockRepository.loginOffline(
          correo: any(named: 'correo'),
          contrasena: any(named: 'contrasena'),
        )).thenAnswer((_) async => tUsuario);

    // Act
    final resultado = await usecase.ejecutar(correo: tCorreo, contrasena: tContrasena);

    // Assert
    expect(resultado, tUsuario);
    verify(() => mockNetworkInfo.estaConectado).called(1);
    verify(() => mockRepository.loginOffline(correo: tCorreo, contrasena: tContrasena)).called(1);
    verifyNever(() => mockRepository.loginOnline(
          correo: any(named: 'correo'),
          contrasena: any(named: 'contrasena'),
          dispositivoCodigo: any(named: 'dispositivoCodigo'),
          dispositivoNombre: any(named: 'dispositivoNombre'),
        ));
  });
}
