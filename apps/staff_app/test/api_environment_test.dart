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
}
