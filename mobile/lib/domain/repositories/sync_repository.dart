abstract class SyncRepository {
  Future<void> procesarColaSincronizacion();
  Future<int> obtenerCantidadTareasPendientes();
}
