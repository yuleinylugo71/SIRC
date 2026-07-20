import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get estaConectado;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get estaConectado async {
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }
}
