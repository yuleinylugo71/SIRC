import 'package:bcrypt/bcrypt.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/local/app_database.dart';
import '../datasources/local/daos/usuario_dao.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioDao _usuarioDao;
  final Dio _dio;
  final SharedPreferences _prefs;

  static const String _keyAuthToken = 'auth_token';

  UsuarioRepositoryImpl(this._usuarioDao, this._dio, this._prefs);

  @override
  Future<Usuario?> obtenerSesionActiva() async {
    final local = await _usuarioDao.obtenerUsuarioActivo();
    if (local == null) return null;
    return _mapToDomain(local);
  }

  @override
  Future<void> cerrarSesion(String id) async {
    // 1. Borrado lógico en base de datos local
    await _usuarioDao.eliminarUsuario(id);
    
    // 2. Limpiar SharedPreferences (token JWT)
    await _prefs.remove(_keyAuthToken);
  }

  @override
  Future<Usuario> loginOnline({
    required String correo,
    required String contrasena,
    required String dispositivoCodigo,
    required String dispositivoNombre,
  }) async {
    try {
      // 1. Llamar al endpoint del backend
      // En desarrollo usamos una URL genérica. En producción vendría de una configuración de red.
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'correo': correo,
          'contrasena': contrasena,
          'dispositivo_codigo': dispositivoCodigo,
          'dispositivo_nombre': dispositivoNombre,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final token = data['token'] as String;
        final hashCache = data['hashCache'] as String;
        final rawUser = data['usuario'];

        // 2. Guardar JWT Token en SharedPreferences
        await _prefs.setString(_keyAuthToken, token);

        // 3. Crear modelo local con el hash de contraseña devuelto por el servidor
        final localUser = UsuarioLocal(
          id: rawUser['id'] as String,
          correo: rawUser['correo'] as String,
          contrasena: hashCache, // Guardamos la contraseña hasheada para logins offline
          nombre: rawUser['nombre'] as String?,
          rol: rawUser['rol'] as String,
          version: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 4. Guardar en SQLite local
        await _usuarioDao.guardarUsuario(localUser);

        return _mapToDomain(localUser);
      } else {
        throw Exception('Error en el servidor al intentar iniciar sesión');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Error de conexión con el servidor';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<Usuario> loginOffline({
    required String correo,
    required String contrasena,
  }) async {
    // 1. Buscar si existe el usuario registrado localmente en la base de datos
    final local = await _usuarioDao.obtenerUsuarioActivo();
    
    if (local == null || local.correo != correo) {
      throw Exception('Usuario no registrado localmente. Requiere iniciar sesión online la primera vez.');
    }

    // 2. Validar contraseña localmente usando bcrypt.checkpw
    final esValida = BCrypt.checkpw(contrasena, local.contrasena);
    if (!esValida) {
      throw Exception('Credenciales locales incorrectas.');
    }

    return _mapToDomain(local);
  }

  @override
  Future<void> registrarRegistrador({
    required String correo,
    required String contrasena,
    required String nombre,
    required String token,
  }) async {
    try {
      await _dio.post(
        '/api/auth/register',
        data: {
          'correo': correo,
          'contrasena': contrasena,
          'nombre': nombre,
          'rol': 'REGISTRADOR',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Error de conexión con el servidor';
      throw Exception(errorMsg);
    }
  }

  @override
  Future<List<Usuario>> obtenerUsuarios({required String token}) async {
    try {
      final response = await _dio.get(
        '/api/auth/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List list = response.data['data'];
        return list.map((json) {
          return Usuario(
            id: json['id'],
            correo: json['correo'],
            nombre: json['nombre'],
            rol: json['rol'] ?? 'REGISTRADOR',
            version: 1,
            createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
            updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
          );
        }).toList();
      }
      return [];
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Error al obtener la lista de usuarios';
      throw Exception(errorMsg);
    }
  }

  Usuario _mapToDomain(UsuarioLocal local) {
    return Usuario(
      id: local.id,
      correo: local.correo,
      nombre: local.nombre,
      rol: local.rol,
      version: local.version,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
    );
  }
}
