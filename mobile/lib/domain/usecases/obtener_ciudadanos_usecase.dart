import '../entities/ciudadano.dart';
import '../repositories/ciudadano_repository.dart';

class ObtenerCiudadanosUseCase {
  final CiudadanoRepository _repository;

  ObtenerCiudadanosUseCase(this._repository);

  Stream<List<Ciudadano>> ejecutarReactivo({String? usuarioId, String? rol}) {
    return _repository.listarCiudadanosReactivo(usuarioId: usuarioId, rol: rol);
  }

  Future<List<Ciudadano>> ejecutar({String? usuarioId, String? rol}) {
    return _repository.listarCiudadanos(usuarioId: usuarioId, rol: rol);
  }

  Future<Ciudadano?> obtenerPorId(String id) {
    return _repository.obtenerCiudadanoPorId(id);
  }
}
