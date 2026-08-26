import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Configuración de la URL base de la API.
///
/// - Si se establece la variable de entorno `API_BASE_URL` al compilar
///   (por ejemplo con `--dart-define=API_BASE_URL=https://sirc.yuleiny.site/api`)
///   esa URL tendrá prioridad.
/// - En modo web y Android se utiliza la URL pública HTTPS del dominio.
/// - En otros entornos (por ejemplo pruebas locales) se mantiene la
///   lógica anterior para `localhost`.
class ApiConfig {
  // Permite sobreescribir la URL mediante `--dart-define`.
  static const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    // Si el compilador recibe una definición, la usamos siempre.
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    // Para la aplicación web y Android queremos siempre la URL pública.
    const publicUrl = 'https://sirc.yuleiny.site/api';
    if (kIsWeb) {
      return publicUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return publicUrl;
    }

    // Fallback for local development environments.
    return 'http://localhost:3000';
  }
}
