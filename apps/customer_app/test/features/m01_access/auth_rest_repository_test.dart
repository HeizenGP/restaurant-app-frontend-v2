import 'dart:convert';

import 'package:customer_app/features/m01_access/shared/application/auth_contracts.dart';
import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:customer_app/features/m01_access/shared/infrastructure/auth_rest_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String baseUrl = 'https://api.example.test/api/v1';

  test('register follows the backend contract and normalizes email', () async {
    late http.Request captured;
    final AuthRestRepository repository = AuthRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient((http.Request request) async {
        captured = request;
        return http.Response(jsonEncode(_userJson), 201);
      }),
    );

    final CustomerIdentity user = await repository.register(
      const RegistrationInput(
        displayName: '  Ana Torres  ',
        email: '  ANA@EXAMPLE.COM ',
        password: 'correcta123',
      ),
    );

    expect(captured.url.toString(), '$baseUrl/auth/register');
    expect(captured.method, 'POST');
    expect(jsonDecode(captured.body), <String, Object>{
      'display_name': 'Ana Torres',
      'email': 'ana@example.com',
      'password': 'correcta123',
    });
    expect(user.displayName, 'Ana Torres');
    expect(user.roles, <String>['CUSTOMER']);
  });

  test('login decodes registered session with refresh token', () async {
    final AuthRestRepository repository = AuthRestRepository(
      baseUri: Uri.parse('$baseUrl/'),
      client: MockClient((http.Request request) async {
        expect(request.url.toString(), '$baseUrl/auth/login');
        expect(jsonDecode(request.body), <String, Object>{
          'email': 'ana@example.com',
          'password': 'secreto',
        });
        return http.Response(jsonEncode(_userSessionJson), 200);
      }),
    );

    final AuthSession session = await repository.login(
      const LoginInput(email: 'ANA@example.com', password: 'secreto'),
    );

    expect(session.kind, AuthSessionKind.user);
    expect(session.refreshToken, 'refresh-token');
    expect(session.user?.email, 'ana@example.com');
  });

  test('guest, refresh and logout use their exact contracts', () async {
    final List<http.Request> captured = <http.Request>[];
    final AuthRestRepository repository = AuthRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient((http.Request request) async {
        captured.add(request);
        return switch (request.url.path) {
          '/api/v1/auth/guest' => http.Response(
            jsonEncode(_guestSessionJson),
            201,
          ),
          '/api/v1/auth/refresh' => http.Response(
            jsonEncode(<String, Object?>{
              ..._userSessionJson,
              'access_token': 'rotated-access',
              'refresh_token': 'rotated-refresh',
            }),
            200,
          ),
          '/api/v1/auth/logout' => http.Response('', 204),
          _ => http.Response('', 404),
        };
      }),
    );

    final AuthSession guest = await repository.createGuestSession();
    final AuthSession refreshed = await repository.refresh('old-refresh');
    await repository.logout('access-token');

    expect(guest.kind, AuthSessionKind.guest);
    expect(guest.refreshToken, isNull);
    expect(guest.user, isNull);
    expect(jsonDecode(captured[1].body), <String, Object>{
      'refresh_token': 'old-refresh',
    });
    expect(refreshed.refreshToken, 'rotated-refresh');
    expect(captured[2].headers['authorization'], 'Bearer access-token');
    expect(captured[2].body, isEmpty);
  });

  for (final (int status, AuthFailureKind kind, String message)
      in <(int, AuthFailureKind, String)>[
        (401, AuthFailureKind.invalidCredentials, 'correo o la contraseña'),
        (409, AuthFailureKind.duplicateEmail, 'existe una cuenta'),
        (422, AuthFailureKind.validation, 'datos ingresados'),
        (503, AuthFailureKind.server, 'no está disponible'),
      ]) {
    test('maps register/login HTTP $status to a safe domain failure', () async {
      final AuthRestRepository repository = AuthRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object>{'detail': 'raw backend detail'}),
            status,
          ),
        ),
      );

      final Future<Object?> request = status == 401
          ? repository.login(
              const LoginInput(email: 'ana@example.com', password: 'bad'),
            )
          : repository.register(
              const RegistrationInput(
                displayName: 'Ana',
                email: 'ana@example.com',
                password: 'password',
              ),
            );

      await expectLater(
        request,
        throwsA(
          isA<AuthFailure>()
              .having((AuthFailure value) => value.kind, 'kind', kind)
              .having(
                (AuthFailure value) => value.message,
                'message',
                contains(message),
              ),
        ),
      );
    });
  }

  test('maps transport failures without leaking exception details', () async {
    final AuthRestRepository repository = AuthRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient((_) async => throw Exception('secret host details')),
    );

    await expectLater(
      repository.createGuestSession(),
      throwsA(
        isA<AuthFailure>()
            .having(
              (AuthFailure value) => value.kind,
              'kind',
              AuthFailureKind.network,
            )
            .having(
              (AuthFailure value) => value.message,
              'message',
              isNot(contains('secret')),
            ),
      ),
    );
  });

  test(
    'rejects a guest response that violates the nullable refresh contract',
    () async {
      final AuthRestRepository repository = AuthRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object?>{
              ..._guestSessionJson,
              'refresh_token': 'unexpected-refresh',
            }),
            201,
          ),
        ),
      );

      await expectLater(
        repository.createGuestSession(),
        throwsA(
          isA<AuthFailure>().having(
            (AuthFailure value) => value.kind,
            'kind',
            AuthFailureKind.malformedResponse,
          ),
        ),
      );
    },
  );
}

const Map<String, Object?> _userJson = <String, Object?>{
  'id': '7391d07c-b900-41c7-bc66-b5d198eb351d',
  'display_name': 'Ana Torres',
  'email': 'ana@example.com',
  'is_active': true,
  'roles': <String>['CUSTOMER'],
  'created_at': '2026-10-22T12:00:00Z',
};

const Map<String, Object?> _userSessionJson = <String, Object?>{
  'access_token': 'access-token',
  'refresh_token': 'refresh-token',
  'token_type': 'bearer',
  'session_kind': 'USER',
  'user': _userJson,
};

const Map<String, Object?> _guestSessionJson = <String, Object?>{
  'access_token': 'guest-access-token',
  'refresh_token': null,
  'token_type': 'bearer',
  'session_kind': 'GUEST',
  'user': null,
};
