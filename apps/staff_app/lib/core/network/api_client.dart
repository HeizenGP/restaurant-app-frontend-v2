import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api_environment.dart';
import '../storage/auth_storage.dart';

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  final int statusCode;
  final String message;
  final dynamic body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({
    required this.environment,
    required this.storage,
    http.Client? httpClient,
    this.onAuthExpired,
  }) : _client = httpClient ?? http.Client();

  final ApiEnvironment environment;
  final AuthStorage storage;
  final http.Client _client;
  final VoidCallback? onAuthExpired;

  Uri _resolveUri(String path, [Map<String, dynamic>? queryParameters]) {
    final String cleanPath = path.startsWith('/') ? path : '/$path';
    final Uri base = environment.baseUri;

    // Remove double /api/v1 if path already includes it or starts with base.path
    String finalPath = base.path;
    if (cleanPath.startsWith('/api/v1')) {
      finalPath = cleanPath;
    } else {
      finalPath = '${base.path}$cleanPath'.replaceAll('//', '/');
    }

    final Map<String, String>? query = queryParameters?.map(
      (String k, dynamic v) => MapEntry<String, String>(k, v.toString()),
    );

    return base.replace(path: finalPath, queryParameters: query);
  }

  Future<Map<String, String>> _buildHeaders({
    bool requiresAuth = true,
    bool requiresIdempotency = false,
  }) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final String? token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (requiresIdempotency) {
      headers['Idempotency-Key'] =
          'kairo-${DateTime.now().millisecondsSinceEpoch}-${UniqueKey().hashCode}';
    }

    return headers;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final Uri uri = _resolveUri(path, queryParameters);
    final Map<String, String> headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    http.Response response = await _client.get(uri, headers: headers);

    if (response.statusCode == 401 && requiresAuth) {
      final bool refreshed = await _tryRefreshToken();
      if (refreshed) {
        final Map<String, String> retryHeaders = await _buildHeaders(
          requiresAuth: true,
        );
        response = await _client.get(uri, headers: retryHeaders);
      } else {
        onAuthExpired?.call();
        throw const ApiException(
          statusCode: 401,
          message: 'Sesión expirada. Por favor ingrese de nuevo.',
        );
      }
    }

    return _parseResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    bool requiresIdempotency = false,
  }) async {
    final Uri uri = _resolveUri(path, queryParameters);
    final Map<String, String> headers = await _buildHeaders(
      requiresAuth: requiresAuth,
      requiresIdempotency: requiresIdempotency,
    );

    final String? encodedBody = body != null ? jsonEncode(body) : null;
    http.Response response = await _client.post(
      uri,
      headers: headers,
      body: encodedBody,
    );

    if (response.statusCode == 401 && requiresAuth) {
      final bool refreshed = await _tryRefreshToken();
      if (refreshed) {
        final Map<String, String> retryHeaders = await _buildHeaders(
          requiresAuth: true,
          requiresIdempotency: requiresIdempotency,
        );
        response = await _client.post(
          uri,
          headers: retryHeaders,
          body: encodedBody,
        );
      } else {
        onAuthExpired?.call();
        throw const ApiException(
          statusCode: 401,
          message: 'Sesión expirada. Por favor ingrese de nuevo.',
        );
      }
    }

    return _parseResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final Uri uri = _resolveUri(path, queryParameters);
    final Map<String, String> headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    final String? encodedBody = body != null ? jsonEncode(body) : null;
    http.Response response = await _client.patch(
      uri,
      headers: headers,
      body: encodedBody,
    );

    if (response.statusCode == 401 && requiresAuth) {
      final bool refreshed = await _tryRefreshToken();
      if (refreshed) {
        final Map<String, String> retryHeaders = await _buildHeaders(
          requiresAuth: true,
        );
        response = await _client.patch(
          uri,
          headers: retryHeaders,
          body: encodedBody,
        );
      } else {
        onAuthExpired?.call();
        throw const ApiException(
          statusCode: 401,
          message: 'Sesión expirada. Por favor ingrese de nuevo.',
        );
      }
    }

    return _parseResponse(response);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final Uri uri = _resolveUri(path, queryParameters);
    final Map<String, String> headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    final String? encodedBody = body != null ? jsonEncode(body) : null;
    http.Response response = await _client.put(
      uri,
      headers: headers,
      body: encodedBody,
    );

    if (response.statusCode == 401 && requiresAuth) {
      final bool refreshed = await _tryRefreshToken();
      if (refreshed) {
        final Map<String, String> retryHeaders = await _buildHeaders(
          requiresAuth: true,
        );
        response = await _client.put(
          uri,
          headers: retryHeaders,
          body: encodedBody,
        );
      } else {
        onAuthExpired?.call();
        throw const ApiException(
          statusCode: 401,
          message: 'Sesión expirada. Por favor ingrese de nuevo.',
        );
      }
    }

    return _parseResponse(response);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    final Uri uri = _resolveUri(path, queryParameters);
    final Map<String, String> headers = await _buildHeaders(
      requiresAuth: requiresAuth,
    );

    http.Response response = await _client.delete(uri, headers: headers);

    if (response.statusCode == 401 && requiresAuth) {
      final bool refreshed = await _tryRefreshToken();
      if (refreshed) {
        final Map<String, String> retryHeaders = await _buildHeaders(
          requiresAuth: true,
        );
        response = await _client.delete(uri, headers: retryHeaders);
      } else {
        onAuthExpired?.call();
        throw const ApiException(
          statusCode: 401,
          message: 'Sesión expirada. Por favor ingrese de nuevo.',
        );
      }
    }

    return _parseResponse(response);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final String? refreshToken = await storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final Uri refreshUri = _resolveUri('/auth/refresh');
      final http.Response res = await _client.post(
        refreshUri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'refresh_token': refreshToken}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final dynamic data = jsonDecode(res.body);
        if (data is Map<String, dynamic> && data['access_token'] != null) {
          await storage.saveTokens(
            accessToken: data['access_token'] as String,
            refreshToken: data['refresh_token'] as String?,
          );
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  dynamic _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    String errorMessage = 'Error de servidor (${response.statusCode})';
    dynamic bodyData;
    try {
      bodyData = jsonDecode(response.body);
      if (bodyData is Map<String, dynamic>) {
        if (bodyData['detail'] != null) {
          final dynamic detail = bodyData['detail'];
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List && detail.isNotEmpty) {
            final dynamic first = detail.first;
            if (first is Map && first['msg'] != null) {
              errorMessage = first['msg'].toString();
            }
          }
        } else if (bodyData['message'] != null) {
          errorMessage = bodyData['message'].toString();
        }
      }
    } catch (_) {
      // Ignored
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMessage,
      body: bodyData,
    );
  }
}
