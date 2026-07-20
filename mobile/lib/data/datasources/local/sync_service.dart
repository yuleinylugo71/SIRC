import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../domain/usecases/procesar_sincronizacion_usecase.dart';

class SyncService {
  final ProcesarSincronizacionUseCase _procesarSincronizacionUseCase;
  final Connectivity _connectivity;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _sincronizando = false;

  SyncService({
    required ProcesarSincronizacionUseCase procesarSincronizacionUseCase,
    required Connectivity connectivity,
  })  : _procesarSincronizacionUseCase = procesarSincronizacionUseCase,
        _connectivity = connectivity;

  /**
   * Inicializa el motor de sincronización de fondo
   */
  void inicializar() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final tieneRed = !results.contains(ConnectivityResult.none);
      if (tieneRed) {
        _dispararSincronizacion();
      }
    });

    // Timer de reintento automático (cada 5 minutos)
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _dispararSincronizacion();
    });
  }

  Future<void> _dispararSincronizacion() async {
    if (_sincronizando) return;
    _sincronizando = true;

    try {
      final pendientes = await _procesarSincronizacionUseCase.obtenerTareasPendientes();
      if (pendientes > 0) {
        await _procesarSincronizacionUseCase.ejecutar();
      }
    } catch (e) {
      // Ignorar fallos de comunicación intermitentes
    } finally {
      _sincronizando = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
  }
}
