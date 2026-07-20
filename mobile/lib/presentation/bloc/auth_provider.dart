import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/usecases/login_usecase.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  final String usuarioId;
  final String correo;
  final String dispositivoId;
  final String rol;

  AuthAuthenticated({
    required this.token,
    required this.usuarioId,
    required this.correo,
    required this.dispositivoId,
    required this.rol,
  });
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String mensaje;
  AuthError(this.mensaje);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final Ref _ref;

  AuthNotifier(this._loginUseCase, this._ref) : super(AuthInitial());

  Future<void> inicializarSesion() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    final usuarioId = prefs.getString('auth_usuario_id');
    final correo = prefs.getString('auth_usuario_correo');
    final dispositivoId = prefs.getString('auth_dispositivo_id');
    final rol = prefs.getString('auth_usuario_rol') ?? 'REGISTRADOR';

    if (token != null && usuarioId != null && correo != null && dispositivoId != null) {
      state = AuthAuthenticated(
        token: token,
        usuarioId: usuarioId,
        correo: correo,
        dispositivoId: dispositivoId,
        rol: rol,
      );
    } else {
      state = AuthUnauthenticated();
    }
  }

  Future<void> login(String correo, String contrasena) async {
    state = AuthLoading();
    try {
      final respuesta = await _loginUseCase.ejecutar(correo: correo, contrasena: contrasena);
      
      final prefs = _ref.read(sharedPreferencesProvider);
      var token = prefs.getString('auth_token');
      if (token == null) {
        token = 'offline-token';
        await prefs.setString('auth_token', token);
      }
      final dispositivoId = _ref.read(dispositivoInfoProvider).obtenerDeviceUuid();

      await prefs.setString('auth_usuario_id', respuesta.id);
      await prefs.setString('auth_usuario_correo', respuesta.correo);
      await prefs.setString('auth_usuario_rol', respuesta.rol);
      await prefs.setString('auth_dispositivo_id', dispositivoId);

      state = AuthAuthenticated(
        token: token,
        usuarioId: respuesta.id,
        correo: respuesta.correo,
        dispositivoId: dispositivoId,
        rol: respuesta.rol,
      );
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.remove('auth_token');
    await prefs.remove('auth_usuario_id');
    await prefs.remove('auth_usuario_correo');
    await prefs.remove('auth_usuario_rol');
    await prefs.remove('auth_dispositivo_id');
    state = AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final usecase = ref.watch(loginUseCaseProvider);
  return AuthNotifier(usecase, ref);
});
