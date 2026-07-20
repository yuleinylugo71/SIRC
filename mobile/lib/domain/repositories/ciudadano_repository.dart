import '../entities/ciudadano.dart';

abstract class CiudadanoRepository {
  Stream<List<Ciudadano>> listarCiudadanosReactivo({String? usuarioId, String? rol});
  Future<List<Ciudadano>> listarCiudadanos({String? usuarioId, String? rol});
  Future<Ciudadano?> obtenerCiudadanoPorId(String id);
  Future<void> registrarCiudadano(Ciudadano ciudadano);
  Future<void> actualizarCiudadano(Ciudadano ciudadano);
  Future<void> eliminarCiudadano(String id);
}
