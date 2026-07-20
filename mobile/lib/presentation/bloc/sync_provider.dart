import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/usecases/procesar_sincronizacion_usecase.dart';

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {
  final String mensaje;
  SyncSuccess(this.mensaje);
}

class SyncError extends SyncState {
  final String mensaje;
  SyncError(this.mensaje);
}

class SyncNotifier extends StateNotifier<SyncState> {
  final ProcesarSincronizacionUseCase _procesarSincronizacionUseCase;

  SyncNotifier(this._procesarSincronizacionUseCase) : super(SyncInitial());

  Future<void> sincronizar() async {
    state = SyncLoading();
    try {
      final pendientes = await _procesarSincronizacionUseCase.obtenerTareasPendientes();
      if (pendientes == 0) {
        state = SyncSuccess('No hay cambios locales pendientes de sincronizar.');
        return;
      }

      await _procesarSincronizacionUseCase.ejecutar();
      state = SyncSuccess('Sincronización finalizada exitosamente.');
    } catch (e) {
      state = SyncError('Error en sincronización: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final usecase = ref.watch(procesarSincronizacionUseCaseProvider);
  return SyncNotifier(usecase);
});
