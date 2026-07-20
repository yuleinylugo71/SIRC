import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DispositivoInfo {
  static const String _keyDeviceUuid = 'device_uuid';
  final SharedPreferences _prefs;

  DispositivoInfo(this._prefs);

  /**
   * Obtiene o genera un UUID único y persistente para este dispositivo móvil
   */
  String obtenerDeviceUuid() {
    String? uuid = _prefs.getString(_keyDeviceUuid);
    if (uuid == null || uuid.isEmpty) {
      uuid = const Uuid().v4();
      _prefs.setString(_keyDeviceUuid, uuid);
    }
    return uuid;
  }

  /**
   * Obtiene el nombre del dispositivo para presentarlo al servidor
   */
  String obtenerNombreDispositivo() {
    // En producción usaríamos device_info_plus para obtener el modelo exacto (ej. "Samsung S24")
    // Colocamos un stub multiplataforma genérico
    return "Dispositivo Móvil SIRC";
  }
}
