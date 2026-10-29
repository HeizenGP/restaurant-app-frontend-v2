import '../application/auth_contracts.dart';
import '../domain/auth_models.dart';

abstract final class AuthJsonMapper {
  static CustomerIdentity decodeUser(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const AuthFailure(
        AuthFailureKind.malformedResponse,
        'El servidor devolvió una respuesta no válida.',
      );
    }
    try {
      final Object? rawRoles = value['roles'];
      if (rawRoles is! List<Object?>) {
        throw const FormatException('roles');
      }
      return CustomerIdentity(
        id: value['id']! as String,
        displayName: value['display_name']! as String,
        email: value['email']! as String,
        isActive: value['is_active']! as bool,
        roles: List<String>.unmodifiable(rawRoles.cast<String>()),
        createdAt: DateTime.parse(value['created_at']! as String),
        phone: value['phone'] as String?,
        avatarUrl: value['avatar_url'] as String?,
        savedCards: (value['saved_cards'] as List<dynamic>?) ?? const <dynamic>[],
        savedAddresses: (value['saved_addresses'] as List<dynamic>?) ?? const <dynamic>[],
      );
    } on Object {
      throw const AuthFailure(
        AuthFailureKind.malformedResponse,
        'El servidor devolvió una respuesta no válida.',
      );
    }
  }

  static AuthSession decodeSession(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const AuthFailure(
        AuthFailureKind.malformedResponse,
        'El servidor devolvió una respuesta no válida.',
      );
    }
    try {
      final AuthSessionKind kind = switch (value['session_kind']) {
        'USER' => AuthSessionKind.user,
        'GUEST' => AuthSessionKind.guest,
        _ => throw const FormatException('session_kind'),
      };
      final Object? rawRefresh = value['refresh_token'];
      final Object? rawUser = value['user'];
      final AuthSession session = AuthSession(
        accessToken: value['access_token']! as String,
        refreshToken: rawRefresh == null ? null : rawRefresh as String,
        tokenType: value['token_type']! as String,
        kind: kind,
        user: rawUser == null ? null : decodeUser(rawUser),
      );
      if (session.accessToken.isEmpty ||
          session.tokenType.toLowerCase() != 'bearer' ||
          (kind == AuthSessionKind.user &&
              (session.user == null ||
                  session.refreshToken == null ||
                  session.refreshToken!.isEmpty)) ||
          (kind == AuthSessionKind.guest &&
              (session.user != null || session.refreshToken != null))) {
        throw const FormatException('authentication response');
      }
      return session;
    } on AuthFailure {
      rethrow;
    } on Object {
      throw const AuthFailure(
        AuthFailureKind.malformedResponse,
        'El servidor devolvió una respuesta no válida.',
      );
    }
  }

  static Map<String, Object?> encodeStoredSession(AuthSession session) {
    return <String, Object?>{
      'schema_version': 1,
      'access_token': session.accessToken,
      'refresh_token': session.refreshToken,
      'token_type': session.tokenType,
      'session_kind': session.kind == AuthSessionKind.user ? 'USER' : 'GUEST',
      'user': switch (session.user) {
        null => null,
        final CustomerIdentity user => <String, Object?>{
          'id': user.id,
          'display_name': user.displayName,
          'email': user.email,
          'is_active': user.isActive,
          'roles': user.roles,
          'created_at': user.createdAt.toUtc().toIso8601String(),
          'phone': user.phone,
          'avatar_url': user.avatarUrl,
          'saved_cards': user.savedCards,
          'saved_addresses': user.savedAddresses,
        },
      },
    };
  }

  static AuthSession decodeStoredSession(Object? value) {
    if (value is! Map<String, Object?> || value['schema_version'] != 1) {
      throw const FormatException('Unsupported session schema');
    }
    return decodeSession(value);
  }
}
