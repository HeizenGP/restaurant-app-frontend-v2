import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../domain/auth_models.dart';
import 'auth_contracts.dart';

enum AuthStatus { restoring, signedOut, signedIn }

enum AuthOperation { none, signIn, register, guest, refresh, logout }

@immutable
class AuthState {
  const AuthState({
    required this.status,
    this.operation = AuthOperation.none,
    this.session,
    this.errorMessage,
    this.noticeMessage,
  });

  const AuthState.restoring() : this(status: AuthStatus.restoring);

  final AuthStatus status;
  final AuthOperation operation;
  final AuthSession? session;
  final String? errorMessage;
  final String? noticeMessage;

  bool get isBusy => operation != AuthOperation.none;

  AuthState copyWith({
    AuthStatus? status,
    AuthOperation? operation,
    AuthSession? session,
    bool clearSession = false,
    String? errorMessage,
    bool clearError = false,
    String? noticeMessage,
    bool clearNotice = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      session: clearSession ? null : session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      noticeMessage: clearNotice ? null : noticeMessage ?? this.noticeMessage,
    );
  }
}

class AuthSessionController extends ChangeNotifier {
  factory AuthSessionController({
    required AuthRepository repository,
    required AuthSessionStore sessionStore,
    DateTime Function()? now,
  }) {
    return AuthSessionController._(
      repository,
      sessionStore,
      now ?? DateTime.now,
    );
  }

  AuthSessionController._(this._repository, this._sessionStore, this._now);

  final AuthRepository _repository;
  final AuthSessionStore _sessionStore;
  final DateTime Function() _now;
  final ValueNotifier<AuthStatus> _navigationStatus = ValueNotifier<AuthStatus>(
    AuthStatus.restoring,
  );
  Timer? _sessionTimer;

  AuthState _state = const AuthState.restoring();

  AuthState get state => _state;

  Listenable get navigationRefresh => _navigationStatus;

  Future<void> restore() async {
    _setState(const AuthState.restoring());
    try {
      final AuthSession? stored = await _sessionStore.read();
      if (stored == null) {
        _setState(const AuthState(status: AuthStatus.signedOut));
        return;
      }

      if (stored.isGuest) {
        if (_isExpired(stored.accessToken)) {
          await _clearStoredSessionAndSignOut(
            noticeMessage:
                'Tu sesión de invitado terminó. Puedes continuar otra vez.',
          );
          return;
        }
        _setState(AuthState(status: AuthStatus.signedIn, session: stored));
        _scheduleSessionMaintenance(stored);
        return;
      }

      final String? refreshToken = stored.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearStoredSessionAndSignOut(
          noticeMessage: 'Tu sesión terminó. Inicia sesión nuevamente.',
        );
        return;
      }

      try {
        final AuthSession refreshed = _requireSessionKind(
          await _repository.refresh(refreshToken),
          AuthSessionKind.user,
        );
        await _sessionStore.write(refreshed);
        _setState(AuthState(status: AuthStatus.signedIn, session: refreshed));
        _scheduleSessionMaintenance(refreshed);
      } on AuthFailure catch (failure) {
        if (failure.kind == AuthFailureKind.invalidSession ||
            failure.kind == AuthFailureKind.invalidCredentials) {
          await _clearStoredSessionAndSignOut(
            noticeMessage: 'Tu sesión terminó. Inicia sesión nuevamente.',
          );
          return;
        }
        if (failure.kind == AuthFailureKind.malformedResponse ||
            failure.kind == AuthFailureKind.validation) {
          await _clearStoredSessionAndSignOut(
            errorMessage:
                'No pudimos validar tu sesión. Inicia sesión nuevamente.',
          );
          return;
        }
        if (_isExpired(stored.accessToken)) {
          _setState(
            AuthState(
              status: AuthStatus.signedOut,
              errorMessage: failure.kind == AuthFailureKind.network
                  ? 'Conéctate a internet para renovar tu sesión.'
                  : 'No pudimos renovar tu sesión. Inicia sesión nuevamente.',
            ),
          );
          return;
        }
        _setState(
          AuthState(
            status: AuthStatus.signedIn,
            session: stored,
            noticeMessage: failure.message,
          ),
        );
        _scheduleSessionMaintenance(stored);
      }
    } on Object {
      _setState(
        const AuthState(
          status: AuthStatus.signedOut,
          errorMessage: 'No pudimos recuperar tu sesión de forma segura.',
        ),
      );
    }
  }

  Future<bool> register(RegistrationInput input) async {
    if (_state.isBusy) return false;
    _setState(
      _state.copyWith(
        operation: AuthOperation.register,
        clearError: true,
        clearNotice: true,
      ),
    );
    try {
      await _repository.register(input);
      _setState(
        const AuthState(
          status: AuthStatus.signedOut,
          noticeMessage: 'Cuenta creada. Ya puedes iniciar sesión.',
        ),
      );
      return true;
    } on AuthFailure catch (failure) {
      _finishWithFailure(failure);
      return false;
    } on Object {
      _finishWithUnexpectedFailure();
      return false;
    }
  }

  Future<bool> login(LoginInput input) async {
    if (_state.isBusy) return false;
    _setState(
      _state.copyWith(
        operation: AuthOperation.signIn,
        clearError: true,
        clearNotice: true,
      ),
    );
    try {
      final AuthSession session = _requireSessionKind(
        await _repository.login(input),
        AuthSessionKind.user,
      );
      await _sessionStore.write(session);
      _setState(AuthState(status: AuthStatus.signedIn, session: session));
      _scheduleSessionMaintenance(session);
      return true;
    } on AuthFailure catch (failure) {
      _finishWithFailure(failure);
      return false;
    } on Object {
      _finishWithUnexpectedFailure();
      return false;
    }
  }

  Future<bool> continueAsGuest() async {
    if (_state.isBusy) return false;
    _setState(
      _state.copyWith(
        operation: AuthOperation.guest,
        clearError: true,
        clearNotice: true,
      ),
    );
    try {
      final AuthSession session = _requireSessionKind(
        await _repository.createGuestSession(),
        AuthSessionKind.guest,
      );
      await _sessionStore.write(session);
      _setState(AuthState(status: AuthStatus.signedIn, session: session));
      _scheduleSessionMaintenance(session);
      return true;
    } on AuthFailure catch (failure) {
      _finishWithFailure(failure);
      return false;
    } on Object {
      _finishWithUnexpectedFailure();
      return false;
    }
  }

  Future<bool> refreshSession() async {
    final AuthSession? current = _state.session;
    final String? refreshToken = current?.refreshToken;
    if (_state.isBusy ||
        current == null ||
        current.isGuest ||
        refreshToken == null) {
      return false;
    }

    _setState(
      _state.copyWith(
        operation: AuthOperation.refresh,
        clearError: true,
        clearNotice: true,
      ),
    );
    try {
      final AuthSession refreshed = _requireSessionKind(
        await _repository.refresh(refreshToken),
        AuthSessionKind.user,
      );
      await _sessionStore.write(refreshed);
      _setState(AuthState(status: AuthStatus.signedIn, session: refreshed));
      _scheduleSessionMaintenance(refreshed);
      return true;
    } on AuthFailure catch (failure) {
      if (failure.kind == AuthFailureKind.invalidSession ||
          failure.kind == AuthFailureKind.invalidCredentials) {
        await _clearStoredSessionAndSignOut(
          noticeMessage: 'Tu sesión terminó. Inicia sesión nuevamente.',
        );
      } else if (failure.kind == AuthFailureKind.malformedResponse ||
          failure.kind == AuthFailureKind.validation) {
        await _clearStoredSessionAndSignOut(
          errorMessage:
              'No pudimos validar tu sesión. Inicia sesión nuevamente.',
        );
      } else if (_isExpired(current.accessToken)) {
        _setState(
          AuthState(
            status: AuthStatus.signedOut,
            errorMessage: failure.kind == AuthFailureKind.network
                ? 'Conéctate a internet para renovar tu sesión.'
                : 'No pudimos renovar tu sesión. Inicia sesión nuevamente.',
          ),
        );
      } else {
        _finishWithFailure(failure);
      }
      return false;
    } on Object {
      await _clearStoredSessionAndSignOut(
        errorMessage: 'No pudimos renovar tu sesión de forma segura. Inicia sesión nuevamente.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    if (_state.isBusy) return;
    final String? accessToken = _state.session?.accessToken;
    _setState(
      _state.copyWith(
        operation: AuthOperation.logout,
        clearError: true,
        clearNotice: true,
      ),
    );

    String notice = 'Sesión cerrada.';
    try {
      if (accessToken != null) {
        await _repository.logout(accessToken);
      }
    } on Object {
      notice = 'Sesión cerrada en este dispositivo. No pudimos confirmarlo con el servidor.';
    }
    await _clearStoredSessionAndSignOut(noticeMessage: notice);
  }

  void clearMessages() {
    if (_state.errorMessage == null && _state.noticeMessage == null) return;
    _setState(_state.copyWith(clearError: true, clearNotice: true));
  }

  AuthSession _requireSessionKind(
    AuthSession session,
    AuthSessionKind expectedKind,
  ) {
    if (session.kind != expectedKind) {
      throw const AuthFailure(
        AuthFailureKind.malformedResponse,
        'El servidor devolvió una respuesta no válida.',
      );
    }
    return session;
  }

  void _finishWithFailure(AuthFailure failure) {
    _setState(
      _state.copyWith(
        operation: AuthOperation.none,
        errorMessage: failure.message,
        clearNotice: true,
      ),
    );
  }

  void _finishWithUnexpectedFailure() {
    _setState(
      _state.copyWith(
        operation: AuthOperation.none,
        errorMessage: 'Ocurrió un error inesperado. Inténtalo nuevamente.',
        clearNotice: true,
      ),
    );
  }

  void _setState(AuthState value) {
    _state = value;
    if (_navigationStatus.value != value.status) {
      _navigationStatus.value = value.status;
    }
    notifyListeners();
  }

  void _scheduleSessionMaintenance(AuthSession session) {
    _sessionTimer?.cancel();
    final DateTime? expiry = _jwtExpiry(session.accessToken);
    if (expiry == null) return;
    final Duration remaining = expiry.difference(_now().toUtc());
    if (session.isGuest) {
      _sessionTimer = Timer(
        remaining.isNegative ? Duration.zero : remaining,
        () => unawaited(_expireGuestSession()),
      );
      return;
    }
    final Duration refreshDelay = remaining - const Duration(seconds: 30);
    _sessionTimer = Timer(
      refreshDelay.isNegative ? Duration.zero : refreshDelay,
      () => unawaited(_refreshFromTimer()),
    );
  }

  Future<void> _refreshFromTimer() async {
    if (_state.status != AuthStatus.signedIn ||
        _state.session?.isGuest == true) {
      return;
    }
    if (_state.isBusy) {
      _sessionTimer = Timer(
        const Duration(seconds: 5),
        () => unawaited(_refreshFromTimer()),
      );
      return;
    }
    final bool refreshed = await refreshSession();
    if (!refreshed && _state.status == AuthStatus.signedIn) {
      _sessionTimer = Timer(
        const Duration(seconds: 30),
        () => unawaited(_refreshFromTimer()),
      );
    }
  }

  Future<void> _expireGuestSession() async {
    if (_state.session?.isGuest != true) return;
    await _clearStoredSessionAndSignOut(
      noticeMessage:
          'Tu sesión de invitado terminó. Puedes continuar otra vez.',
    );
  }

  Future<void> _clearStoredSessionAndSignOut({
    String? noticeMessage,
    String? errorMessage,
  }) async {
    _sessionTimer?.cancel();
    _setState(
      const AuthState(
        status: AuthStatus.signedOut,
        operation: AuthOperation.logout,
      ),
    );

    var cleared = false;
    for (var attempt = 0; attempt < 2 && !cleared; attempt += 1) {
      try {
        await _sessionStore.clear();
        cleared = true;
      } on Object {
        // Secure storage can fail transiently; retry once without restoring the
        // invalid session to memory.
      }
    }

    _setState(
      AuthState(
        status: AuthStatus.signedOut,
        noticeMessage: cleared ? noticeMessage : null,
        errorMessage: cleared ? errorMessage : 'La sesión se cerró en la app, pero no pudimos limpiar las credenciales guardadas. Inténtalo nuevamente.',
      ),
    );
  }

  bool _isExpired(String token) {
    final DateTime? expiry = _jwtExpiry(token);
    return expiry == null || !expiry.isAfter(_now().toUtc());
  }

  DateTime? _jwtExpiry(String token) {
    try {
      final List<String> segments = token.split('.');
      if (segments.length != 3) return null;
      final String normalized = base64Url.normalize(segments[1]);
      final Object? decoded = jsonDecode(
        utf8.decode(base64Url.decode(normalized)),
      );
      if (decoded is! Map<String, Object?>) return null;
      final Object? exp = decoded['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
    } on Object {
      return null;
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _navigationStatus.dispose();
    super.dispose();
  }
}
