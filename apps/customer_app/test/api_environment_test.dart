import 'package:customer_app/core/api_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts an absolute HTTP API URL', () {
    final ApiEnvironment environment = ApiEnvironment(
      baseUrl: 'https://api.example.test/api/v1',
    );

    expect(environment.baseUri.host, 'api.example.test');
    expect(environment.baseUri.path, '/api/v1');
  });

  test('rejects a relative API URL', () {
    expect(() => ApiEnvironment(baseUrl: '/api/v1'), throwsArgumentError);
  });
}
