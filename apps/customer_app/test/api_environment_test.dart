import 'package:customer_app/core/api_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEnvironment base URL validation', () {
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
  });

  group('ApiEnvironment compile-time selector (USE_RENDER vs USE_LOCAL)', () {
    test('resolves Render URL when USE_RENDER=true and USE_LOCAL=false', () {
      final String url = ApiEnvironment.resolveBaseUrl(
        overrideUseRender: true,
        overrideUseLocal: false,
      );

      expect(url, 'https://restaurant-app-backend-v2.onrender.com/api/v1');

      final ApiEnvironment env = ApiEnvironment(baseUrl: url);
      expect(env.baseUri.scheme, 'https');
      expect(env.baseUri.host, 'restaurant-app-backend-v2.onrender.com');
      expect(env.baseUri.path, '/api/v1');
    });

    test('resolves Local URL when USE_RENDER=false and USE_LOCAL=true', () {
      final String url = ApiEnvironment.resolveBaseUrl(
        overrideUseRender: false,
        overrideUseLocal: true,
      );

      expect(url, 'http://localhost:8000/api/v1');

      final ApiEnvironment env = ApiEnvironment(baseUrl: url);
      expect(env.baseUri.scheme, 'http');
      expect(env.baseUri.host, 'localhost');
      expect(env.baseUri.port, 8000);
      expect(env.baseUri.path, '/api/v1');
    });

    test('throws StateError when both USE_RENDER and USE_LOCAL are false', () {
      expect(
        () => ApiEnvironment.resolveBaseUrl(
          overrideUseRender: false,
          overrideUseLocal: false,
        ),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            allOf(
              contains('Configuración de entorno inválida'),
              contains('--dart-define=USE_RENDER=true --dart-define=USE_LOCAL=false'),
              contains('--dart-define=USE_RENDER=false --dart-define=USE_LOCAL=true'),
            ),
          ),
        ),
      );
    });

    test('throws StateError when both USE_RENDER and USE_LOCAL are true', () {
      expect(
        () => ApiEnvironment.resolveBaseUrl(
          overrideUseRender: true,
          overrideUseLocal: true,
        ),
        throwsA(
          isA<StateError>().having(
            (StateError e) => e.message,
            'message',
            allOf(
              contains('Configuración de entorno inválida'),
              contains('USE_RENDER=true, USE_LOCAL=true'),
            ),
          ),
        ),
      );
    });

    test('fromCompileTime reflects the active compile-time configuration', () {
      if (ApiEnvironment.useRender && !ApiEnvironment.useLocal) {
        final ApiEnvironment env = ApiEnvironment.fromCompileTime();
        expect(env.baseUri.toString(), ApiEnvironment.renderUrl);
      } else if (!ApiEnvironment.useRender && ApiEnvironment.useLocal) {
        final ApiEnvironment env = ApiEnvironment.fromCompileTime();
        expect(env.baseUri.toString(), ApiEnvironment.localUrl);
      } else {
        expect(() => ApiEnvironment.fromCompileTime(), throwsStateError);
      }
    });
  });
}
