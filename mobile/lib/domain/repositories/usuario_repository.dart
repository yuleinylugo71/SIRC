import '../entities/usuario.dart';

abstract class UsuarioRepository {
  Future<Usuario?> obtenerSesionActiva();
  Future<void> cerrarSesion(String id);

  /**
   * Autenticación online contra el backend de SIRC.
   * Lanza excepciones de tipo Exception en caso de credenciales inválidas.
   */
  Future<Usuario> loginOnline({
    required String correo,
    required String contrasena,
    required String dispositivoCodigo,
    required String dispositivoNombre,
  });

  /**
   * Autenticación offline comprobando hashes bcrypt en base de datos Drift local.
   * Lanza excepciones si el usuario no existe localmente o la contraseña es inválida.
   */
  Future<Usuario> loginOffline({
    required String correo,
    required String contrasena,
  });

  /**
   * Registra un nuevo registrador en el servidor (Solo permitido para administradores).
   */
  Future<void> registrarRegistrador({
    required String correo,
    required String contrasena,
    required String nombre,
    required String token,
  });

  /**
   * Obtiene la lista de usuarios/agentes desde el servidor (Solo permitido para administradores).
   */
  Future<List<Usuario>> obtenerUsuarios({required String token});
}
