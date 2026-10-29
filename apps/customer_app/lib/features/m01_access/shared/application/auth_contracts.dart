import '../domain/auth_models.dart';

abstract interface class AuthRepository {
  Future<CustomerIdentity> register(RegistrationInput input);

  Future<AuthSession> login(LoginInput input);

  Future<AuthSession> createGuestSession();

  Future<AuthSession> refresh(String refreshToken);

  Future<void> logout(String accessToken);

  Future<CustomerIdentity> updateProfile({
    required String accessToken,
    String? displayName,
    String? phone,
    String? avatarUrl,
    List<Map<String, dynamic>>? savedCards,
    List<Map<String, dynamic>>? savedAddresses,
  });
}

abstract interface class AuthSessionStore {
  Future<AuthSession?> read();

  Future<void> write(AuthSession session);

  Future<void> clear();
}

enum AuthFailureKind {
  invalidCredentials,
  duplicateEmail,
  invalidSession,
  validation,
  network,
  server,
  malformedResponse,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind, this.message);

  final AuthFailureKind kind;
  final String message;

  @override
  String toString() => 'AuthFailure($kind, $message)';
}
