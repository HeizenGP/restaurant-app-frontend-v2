import 'dart:async';
import 'dart:convert';

import 'package:customer_app/features/m01_access/shared/application/auth_contracts.dart';
import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';

class MemoryAuthSessionStore implements AuthSessionStore {
  MemoryAuthSessionStore({this.session, this.throwOnClear = false});

  AuthSession? session;
  bool throwOnClear;
  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<void> clear() async {
    clearCount += 1;
    if (throwOnClear) throw StateError('secure storage unavailable');
    session = null;
  }

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession value) async {
    writeCount += 1;
    session = value;
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AuthSession? loginResult,
    AuthSession? guestResult,
    AuthSession? refreshResult,
    CustomerIdentity? registrationResult,
  }) : loginResult = loginResult ?? registeredSession(),
       guestResult = guestResult ?? guestSession(),
       refreshResult = refreshResult ?? registeredSession(accessToken: 'new'),
       registrationResult = registrationResult ?? customerIdentity;

  AuthSession loginResult;
  AuthSession guestResult;
  AuthSession refreshResult;
  CustomerIdentity registrationResult;
  AuthFailure? loginFailure;
  AuthFailure? guestFailure;
  AuthFailure? refreshFailure;
  AuthFailure? registrationFailure;
  AuthFailure? logoutFailure;
  LoginInput? lastLogin;
  RegistrationInput? lastRegistration;
  String? lastRefreshToken;
  String? lastLogoutToken;
  int guestCalls = 0;
  int refreshCalls = 0;
  Completer<AuthSession>? guestCompleter;
  Completer<AuthSession>? refreshCompleter;
  Completer<CustomerIdentity>? registrationCompleter;

  @override
  Future<AuthSession> createGuestSession() async {
    guestCalls += 1;
    if (guestFailure case final AuthFailure failure) throw failure;
    if (guestCompleter case final Completer<AuthSession> completer) {
      return completer.future;
    }
    return guestResult;
  }

  @override
  Future<AuthSession> login(LoginInput input) async {
    lastLogin = input;
    if (loginFailure case final AuthFailure failure) throw failure;
    return loginResult;
  }

  @override
  Future<void> logout(String accessToken) async {
    lastLogoutToken = accessToken;
    if (logoutFailure case final AuthFailure failure) throw failure;
  }

  @override
  Future<CustomerIdentity> updateProfile({
    required String accessToken,
    String? displayName,
    String? phone,
    String? avatarUrl,
    List<Map<String, dynamic>>? savedCards,
    List<Map<String, dynamic>>? savedAddresses,
  }) async {
    return CustomerIdentity(
      id: registrationResult.id,
      displayName: displayName ?? registrationResult.displayName,
      email: registrationResult.email,
      isActive: registrationResult.isActive,
      roles: registrationResult.roles,
      createdAt: registrationResult.createdAt,
      phone: phone ?? registrationResult.phone,
      avatarUrl: avatarUrl ?? registrationResult.avatarUrl,
      savedCards: savedCards ?? registrationResult.savedCards,
      savedAddresses: savedAddresses ?? registrationResult.savedAddresses,
    );
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    refreshCalls += 1;
    lastRefreshToken = refreshToken;
    if (refreshFailure case final AuthFailure failure) throw failure;
    if (refreshCompleter case final Completer<AuthSession> completer) {
      return completer.future;
    }
    return refreshResult;
  }

  @override
  Future<CustomerIdentity> register(RegistrationInput input) async {
    lastRegistration = input;
    if (registrationFailure case final AuthFailure failure) throw failure;
    if (registrationCompleter
        case final Completer<CustomerIdentity> completer) {
      return completer.future;
    }
    return registrationResult;
  }
}

final CustomerIdentity customerIdentity = CustomerIdentity(
  id: '7391d07c-b900-41c7-bc66-b5d198eb351d',
  displayName: 'Ana Torres',
  email: 'ana@example.com',
  isActive: true,
  roles: const <String>['CUSTOMER'],
  createdAt: DateTime.utc(2026, 10, 22, 12),
);

AuthSession registeredSession({
  String accessToken = 'access-token',
  String refreshToken = 'refresh-token',
}) {
  return AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: 'bearer',
    kind: AuthSessionKind.user,
    user: customerIdentity,
  );
}

AuthSession guestSession({String? accessToken}) {
  return AuthSession(
    accessToken: accessToken ?? _futureJwt(),
    tokenType: 'bearer',
    kind: AuthSessionKind.guest,
  );
}

String expiredGuestJwt() => _jwtWithExpiry(946684800);

String _futureJwt() => _jwtWithExpiry(4102444800);

String _jwtWithExpiry(int expirySeconds) {
  final String header = base64Url.encode(utf8.encode('{"alg":"none"}'));
  final String payload = base64Url.encode(
    utf8.encode(jsonEncode(<String, Object>{'exp': expirySeconds})),
  );
  return '$header.$payload.signature';
}
