final class ApiEnvironment {
  ApiEnvironment({required String baseUrl}) : baseUri = _parseBaseUrl(baseUrl);

  factory ApiEnvironment.fromCompileTime() {
    return ApiEnvironment(baseUrl: resolveBaseUrl());
  }

  /// URLs de entorno oficiales
  static const String renderUrl =
      'https://restaurant-app-backend-v2.onrender.com/api/v1';
  static const String localUrl = 'http://localhost:8000/api/v1';

  /// Variables de compilación
  static const bool useRender = bool.fromEnvironment('USE_RENDER');
  static const bool useLocal = bool.fromEnvironment('USE_LOCAL');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  final Uri baseUri;

  /// Resuelve la URL base evaluando variables de compilación.
  static String resolveBaseUrl({
    bool? overrideUseRender,
    bool? overrideUseLocal,
    String? overrideApiBaseUrl,
  }) {
    final String explicit = overrideApiBaseUrl ?? apiBaseUrl;
    if (explicit.isNotEmpty) {
      return explicit;
    }

    final bool activeRender = overrideUseRender ?? useRender;
    final bool activeLocal = overrideUseLocal ?? useLocal;

    if (activeRender && !activeLocal) {
      return renderUrl;
    }
    if (!activeRender && activeLocal) {
      return localUrl;
    }

    // Safe shared default: customer_app and staff_app must target the same API.
    // Local development remains explicit through USE_LOCAL=true.
    return renderUrl;
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
