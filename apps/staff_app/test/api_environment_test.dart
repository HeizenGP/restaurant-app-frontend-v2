import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api_environment.dart';

void main() {
  test('accepts an absolute HTTPS API URL', () {
    final ApiEnvironment environment = ApiEnvironment(
      baseUrl: 'https://api.example.test/api/v1',
    );

    expect(environment.baseUri.scheme, 'https');
    expect(environment.baseUri.path, '/api/v1');
  });

  test('rejects a non-HTTP API URL', () {
    expect(
      () => ApiEnvironment(baseUrl: 'file:///api/v1'),
      throwsArgumentError,
    );
  });

  test('resolves renderUrl when USE_RENDER is true', () {
    final String url = ApiEnvironment.resolveBaseUrl(
      overrideUseRender: true,
      overrideUseLocal: false,
    );
    expect(url, ApiEnvironment.renderUrl);
  });

  test('resolves localUrl when USE_LOCAL is true', () {
    final String url = ApiEnvironment.resolveBaseUrl(
      overrideUseRender: false,
      overrideUseLocal: true,
    );
    expect(url, ApiEnvironment.localUrl);
  });

  test('defaults to the same Render backend used by customer_app', () {
    final String url = ApiEnvironment.resolveBaseUrl(
      overrideUseRender: false,
      overrideUseLocal: false,
      overrideApiBaseUrl: '',
    );
    expect(url, ApiEnvironment.renderUrl);
  });
}
