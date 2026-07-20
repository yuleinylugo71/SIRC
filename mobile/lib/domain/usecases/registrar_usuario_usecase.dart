import '../repositories/usuario_repository.dart';

class RegistrarUsuarioUseCase {
  final UsuarioRepository _usuarioRepository;

  RegistrarUsuarioUseCase(this._usuarioRepository);

  Future<void> ejecutar({
    required String correo,
    required String contrasena,
    required String nombre,
    required String token,
  }) async {
    if (correo.isEmpty || contrasena.isEmpty || nombre.isEmpty) {
      throw Exception('Todos los campos son obligatorios.');
    }
    
    // Validar formato básico de correo
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(correo)) {
      throw Exception('El correo electrónico no es válido.');
    }

    if (contrasena.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres.');
    }

    await _usuarioRepository.registrarRegistrador(
      correo: correo,
      contrasena: contrasena,
      nombre: nombre,
      token: token,
    );
  }
}
