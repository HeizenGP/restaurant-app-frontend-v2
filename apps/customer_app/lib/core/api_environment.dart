final class ApiEnvironment {
  ApiEnvironment({required String baseUrl}) : baseUri = _parseBaseUrl(baseUrl);

  factory ApiEnvironment.fromCompileTime() {
    return ApiEnvironment(baseUrl: _compiledBaseUrl);
  }

  static const String _compiledBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  final Uri baseUri;

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
