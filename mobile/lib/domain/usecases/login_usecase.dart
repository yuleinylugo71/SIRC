import '../../core/network/dispositivo_info.dart';
import '../../core/network/network_info.dart';
import '../entities/usuario.dart';
import '../repositories/usuario_repository.dart';

class LoginUseCase {
  final UsuarioRepository _usuarioRepository;
  final NetworkInfo _networkInfo;
  final DispositivoInfo _dispositivoInfo;

  LoginUseCase({
    required UsuarioRepository usuarioRepository,
    required NetworkInfo networkInfo,
    required DispositivoInfo dispositivoInfo,
  })  : _usuarioRepository = usuarioRepository,
        _networkInfo = networkInfo,
        _dispositivoInfo = dispositivoInfo;

  Future<Usuario> ejecutar({
    required String correo,
    required String contrasena,
  }) async {
    final tieneConexion = await _networkInfo.estaConectado;

    if (tieneConexion) {
      try {
        final codigoDispositivo = _dispositivoInfo.obtenerDeviceUuid();
        final nombreDispositivo = _dispositivoInfo.obtenerNombreDispositivo();

        return await _usuarioRepository.loginOnline(
          correo: correo,
          contrasena: contrasena,
          dispositivoCodigo: codigoDispositivo,
          dispositivoNombre: nombreDispositivo,
        );
      } catch (e) {
        // Fallback offline en caso de error de red o timeout
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('conexión') || 
            errorStr.contains('connection') || 
            errorStr.contains('socketexception') ||
            errorStr.contains('timeout')) {
          return await _usuarioRepository.loginOffline(
            correo: correo,
            contrasena: contrasena,
          );
        }
        rethrow;
      }
    } else {
      return await _usuarioRepository.loginOffline(
        correo: correo,
        contrasena: contrasena,
      );
    }
  }
}
