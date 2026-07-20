import '../repositories/sync_repository.dart';

class ProcesarSincronizacionUseCase {
  final SyncRepository _repository;

  ProcesarSincronizacionUseCase(this._repository);

  Future<void> ejecutar() async {
    await _repository.procesarColaSincronizacion();
  }

  Future<int> obtenerTareasPendientes() {
    return _repository.obtenerCantidadTareasPendientes();
  }
}
