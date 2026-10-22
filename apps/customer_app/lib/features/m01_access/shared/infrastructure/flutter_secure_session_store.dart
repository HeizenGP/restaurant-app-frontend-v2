import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../application/auth_contracts.dart';
import '../domain/auth_models.dart';
import 'auth_json_mapper.dart';

class FlutterSecureSessionStore implements AuthSessionStore {
  FlutterSecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _sessionKey = 'chifa_asia.auth_session.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthSession?> read() async {
    final String? raw = await _storage.read(key: _sessionKey);
    if (raw == null) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      return AuthJsonMapper.decodeStoredSession(decoded);
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) {
    final String raw = jsonEncode(AuthJsonMapper.encodeStoredSession(session));
    return _storage.write(key: _sessionKey, value: raw);
  }

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}
