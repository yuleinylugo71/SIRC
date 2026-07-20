import '../repositories/ciudadano_repository.dart';

class EliminarCiudadanoUseCase {
  final CiudadanoRepository _repository;

  EliminarCiudadanoUseCase(this._repository);

  Future<void> ejecutar(String id) {
    return _repository.eliminarCiudadano(id);
  }
}
