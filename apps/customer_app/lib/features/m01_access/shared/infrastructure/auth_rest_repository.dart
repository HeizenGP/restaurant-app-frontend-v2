import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../application/auth_contracts.dart';
import '../domain/auth_models.dart';
import 'auth_json_mapper.dart';

class AuthRestRepository implements AuthRepository {
  factory AuthRestRepository({
    required Uri baseUri,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) {
    return AuthRestRepository._(baseUri, client, requestTimeout);
  }

  AuthRestRepository._(this._baseUri, this._client, this.requestTimeout);

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<CustomerIdentity> register(RegistrationInput input) async {
    final http.Response response = await _post(
      'auth/register',
      body: <String, Object?>{
        'display_name': input.displayName.trim(),
        'email': input.email.trim().toLowerCase(),
        'password': input.password,
      },
    );
    if (response.statusCode != 201) {
      throw _failureFor(response, request: _AuthRequest.register);
    }
    return AuthJsonMapper.decodeUser(_decodeJson(response));
  }

  @override
  Future<AuthSession> login(LoginInput input) async {
    final http.Response response = await _post(
      'auth/login',
      body: <String, Object?>{
        'email': input.email.trim().toLowerCase(),
        'password': input.password,
      },
    );
    if (response.statusCode != 200) {
      throw _failureFor(response, request: _AuthRequest.login);
    }
    return AuthJsonMapper.decodeSession(_decodeJson(response));
  }

  @override
  Future<AuthSession> createGuestSession() async {
    final http.Response response = await _post('auth/guest');
    if (response.statusCode != 201) {
      throw _failureFor(response, request: _AuthRequest.guest);
    }
    return AuthJsonMapper.decodeSession(_decodeJson(response));
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    final http.Response response = await _post(
      'auth/refresh',
      body: <String, Object?>{'refresh_token': refreshToken},
    );
    if (response.statusCode != 200) {
      throw _failureFor(response, request: _AuthRequest.refresh);
    }
    return AuthJsonMapper.decodeSession(_decodeJson(response));
  }

  @override
  Future<void> logout(String accessToken) async {
    final http.Response response = await _post(
      'auth/logout',
      bearerToken: accessToken,
    );
    if (response.statusCode != 204) {
      throw _failureFor(response, request: _AuthRequest.logout);
    }
  }

  Future<http.Response> _post(
    String path, {
    Map<String, Object?>? body,
    String? bearerToken,
  }) async {
    try {
      return await _client
          .post(
            _endpoint(path),
            headers: <String, String>{
              'Accept': 'application/json',
              if (body != null) 'Content-Type': 'application/json',
              if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
            },
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(requestTimeout);
    } on AuthFailure {
      rethrow;
    } on Object {
      throw const AuthFailure(
        AuthFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );
    }
  }

  Uri _endpoint(String path) {
    final List<String> baseSegments = _baseUri.pathSegments
        .where((String segment) => segment.isNotEmpty)
        .toList(growable: false);
    return _baseUri.replace(
      pathSegments: <String>[...baseSegments, ...path.split('/')],
      query: null,
      fragment: null,
    );
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on Object {
      throw const AuthFailure(
        AuthFailureKind.malformedResponse,
        'El servidor devolvió una respuesta no válida.',
      );
    }
  }

  AuthFailure _failureFor(
    http.Response response, {
    required _AuthRequest request,
  }) {
    if (response.statusCode == 401) {
      if (request == _AuthRequest.login) {
        return const AuthFailure(
          AuthFailureKind.invalidCredentials,
          'El correo o la contraseña no son correctos.',
        );
      }
      return const AuthFailure(
        AuthFailureKind.invalidSession,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
    if (response.statusCode == 409 && request == _AuthRequest.register) {
      return const AuthFailure(
        AuthFailureKind.duplicateEmail,
        'Ya existe una cuenta con este correo.',
      );
    }
    if (response.statusCode == 422) {
      return const AuthFailure(
        AuthFailureKind.validation,
        'Revisa los datos ingresados e inténtalo nuevamente.',
      );
    }
    return const AuthFailure(
      AuthFailureKind.server,
      'Chifa ASIA no está disponible por el momento. Inténtalo nuevamente.',
    );
  }
}

enum _AuthRequest { register, login, guest, refresh, logout }
