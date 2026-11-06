final class ApiEnvironment {
  ApiEnvironment({required String baseUrl}) : baseUri = _parseBaseUrl(baseUrl);

  factory ApiEnvironment.fromCompileTime() {
    return ApiEnvironment(baseUrl: resolveBaseUrl());
  }

  /// URLs de entorno
  static const String renderUrl =
      'https://restaurant-app-backend-v2.onrender.com/api/v1';
  static const String localUrl = 'http://localhost:8000/api/v1';

  /// Variables de compilación
  static const bool useRender = bool.fromEnvironment('USE_RENDER');
  static const bool useLocal = bool.fromEnvironment('USE_LOCAL');

  final Uri baseUri;

  /// Resuelve la URL base evaluando las variables de compilación.
  ///
  /// Lanza un [StateError] si ambas variables están activadas o ambas desactivadas.
  static String resolveBaseUrl({
    bool? overrideUseRender,
    bool? overrideUseLocal,
  }) {
    final bool activeRender = overrideUseRender ?? useRender;
    final bool activeLocal = overrideUseLocal ?? useLocal;

    if (activeRender == activeLocal) {
      throw StateError(
        'Configuración de entorno inválida.\n'
        'Debe especificarse exactamente un entorno de ejecución mediante los parámetros de compilación:\n\n'
        '• Para utilizar Render:\n'
        '  flutter run --dart-define=USE_RENDER=true --dart-define=USE_LOCAL=false\n\n'
        '• Para utilizar Backend Local:\n'
        '  flutter run --dart-define=USE_RENDER=false --dart-define=USE_LOCAL=true\n\n'
        'Parámetros recibidos actualmente: USE_RENDER=$activeRender, USE_LOCAL=$activeLocal.',
      );
    }

    return activeRender ? renderUrl : localUrl;
  }

  static Uri _parseBaseUrl(String value) {
    final Uri uri = Uri.parse(value);
    if (!uri.hasScheme || !uri.hasAuthority) {
      throw ArgumentError.value(value, 'baseUrl', 'Must be an absolute URL');
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw ArgumentError.value(value, 'baseUrl', 'Must use HTTP or HTTPS');
    }
    return uri;
  }
}
