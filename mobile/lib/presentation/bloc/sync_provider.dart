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
      final pendientes =
          await _procesarSincronizacionUseCase.obtenerTareasPendientes();

      await _procesarSincronizacionUseCase.ejecutar();
      state = SyncSuccess(
        pendientes == 0
            ? 'Datos actualizados desde el servidor.'
            : 'Sincronizacion finalizada exitosamente.',
      );
    } catch (e) {
      state = SyncError(_mensajeErrorUsuario(e));
    }
  }

  String _mensajeErrorUsuario(Object error) {
    final mensaje = error.toString().replaceAll('Exception: ', '');
    if (mensaje.contains('status code of 401') ||
        mensaje.contains('HTTP 401') ||
        mensaje.contains('no autorizada')) {
      return 'Sesion expirada o no autorizada. Cierra sesion e inicia nuevamente.';
    }

    if (mensaje.length > 180) {
      return 'No se pudo sincronizar. Verifica la sesion y la conexion con el servidor.';
    }

    return 'Error en sincronizacion: $mensaje';
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final usecase = ref.watch(procesarSincronizacionUseCaseProvider);
  return SyncNotifier(usecase);
});
