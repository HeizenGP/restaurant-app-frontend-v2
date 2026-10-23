import 'dart:async';

import 'package:customer_app/features/m01_access/shared/application/auth_contracts.dart';
import 'package:customer_app/features/m01_access/shared/application/auth_session_controller.dart';
import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_fakes.dart';

void main() {
  test('restores signed-out state when no secure session exists', () async {
    final AuthSessionController controller = AuthSessionController(
      repository: FakeAuthRepository(),
      sessionStore: MemoryAuthSessionStore(),
    );

    await controller.restore();

    expect(controller.state.status, AuthStatus.signedOut);
    expect(controller.state.session, isNull);
  });

  test('login persists the authenticated session', () async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    final AuthSessionController controller = AuthSessionController(
      repository: repository,
      sessionStore: store,
    );
    await controller.restore();

    final bool result = await controller.login(
      const LoginInput(email: 'Ana@Example.com', password: 'secret'),
    );

    expect(result, isTrue);
    expect(controller.state.status, AuthStatus.signedIn);
    expect(store.session?.refreshToken, 'refresh-token');
    expect(store.writeCount, 1);
    expect(repository.lastLogin?.email, 'Ana@Example.com');
  });

  test(
    'registration keeps the user signed out and exposes success notice',
    () async {
      final FakeAuthRepository repository = FakeAuthRepository();
      final MemoryAuthSessionStore store = MemoryAuthSessionStore();
      final AuthSessionController controller = AuthSessionController(
        repository: repository,
        sessionStore: store,
      );
      await controller.restore();

      final bool result = await controller.register(
        const RegistrationInput(
          displayName: 'Ana',
          email: 'ana@example.com',
          password: '12345678',
        ),
      );

      expect(result, isTrue);
      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.noticeMessage, contains('Cuenta creada'));
      expect(store.writeCount, 0);
    },
  );

  test('guest session persists without inventing a refresh token', () async {
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    final AuthSessionController controller = AuthSessionController(
      repository: FakeAuthRepository(),
      sessionStore: store,
    );
    await controller.restore();

    final bool result = await controller.continueAsGuest();

    expect(result, isTrue);
    expect(controller.state.session?.kind, AuthSessionKind.guest);
    expect(controller.state.session?.refreshToken, isNull);
    expect(store.writeCount, 1);
  });

  test('does not persist a guest session returned by login', () async {
    final FakeAuthRepository repository = FakeAuthRepository(
      loginResult: guestSession(),
    );
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    final AuthSessionController controller = AuthSessionController(
      repository: repository,
      sessionStore: store,
    );
    await controller.restore();

    final bool result = await controller.login(
      const LoginInput(email: 'ana@example.com', password: 'secret'),
    );

    expect(result, isFalse);
    expect(controller.state.status, AuthStatus.signedOut);
    expect(controller.state.errorMessage, contains('no válida'));
    expect(store.writeCount, 0);
  });

  test('does not persist a user session returned by guest access', () async {
    final FakeAuthRepository repository = FakeAuthRepository(
      guestResult: registeredSession(),
    );
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    final AuthSessionController controller = AuthSessionController(
      repository: repository,
      sessionStore: store,
    );
    await controller.restore();

    final bool result = await controller.continueAsGuest();

    expect(result, isFalse);
    expect(controller.state.status, AuthStatus.signedOut);
    expect(controller.state.errorMessage, contains('no válida'));
    expect(store.writeCount, 0);
  });

  test(
    'restore rotates a registered refresh token and saves the result',
    () async {
      final FakeAuthRepository repository = FakeAuthRepository(
        refreshResult: registeredSession(
          accessToken: 'rotated-access',
          refreshToken: 'rotated-refresh',
        ),
      );
      final MemoryAuthSessionStore store = MemoryAuthSessionStore(
        session: registeredSession(refreshToken: 'old-refresh'),
      );
      final AuthSessionController controller = AuthSessionController(
        repository: repository,
        sessionStore: store,
      );

      await controller.restore();

      expect(repository.lastRefreshToken, 'old-refresh');
      expect(controller.state.session?.accessToken, 'rotated-access');
      expect(store.session?.refreshToken, 'rotated-refresh');
    },
  );

  test('expired guest token is cleared instead of being refreshed', () async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore(
      session: guestSession(accessToken: expiredGuestJwt()),
    );
    final AuthSessionController controller = AuthSessionController(
      repository: repository,
      sessionStore: store,
      now: () => DateTime.utc(2026, 10, 22),
    );

    await controller.restore();

    expect(controller.state.status, AuthStatus.signedOut);
    expect(controller.state.noticeMessage, contains('invitado'));
    expect(repository.refreshCalls, 0);
    expect(store.clearCount, 1);
  });

  test('invalid refresh clears the persisted session', () async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..refreshFailure = const AuthFailure(
        AuthFailureKind.invalidSession,
        'expired',
      );
    final MemoryAuthSessionStore store = MemoryAuthSessionStore(
      session: registeredSession(),
    );
    final AuthSessionController controller = AuthSessionController(
      repository: repository,
      sessionStore: store,
    );

    await controller.restore();

    expect(controller.state.status, AuthStatus.signedOut);
    expect(store.session, isNull);
    expect(store.clearCount, 1);
  });

  test(
    'invalid refresh signs out in memory when secure storage cannot clear',
    () async {
      final FakeAuthRepository repository = FakeAuthRepository()
        ..refreshFailure = const AuthFailure(
          AuthFailureKind.invalidSession,
          'expired',
        );
      final MemoryAuthSessionStore store = MemoryAuthSessionStore(
        session: registeredSession(),
        throwOnClear: true,
      );
      final AuthSessionController controller = AuthSessionController(
        repository: repository,
        sessionStore: store,
      );

      await controller.restore();

      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.operation, AuthOperation.none);
      expect(controller.state.session, isNull);
      expect(controller.state.errorMessage, contains('credenciales guardadas'));
      expect(store.session, isNotNull);
      expect(store.clearCount, 2, reason: 'secure storage is retried once');
    },
  );

  test(
    'expired guest signs out in memory when secure storage cannot clear',
    () async {
      final MemoryAuthSessionStore store = MemoryAuthSessionStore(
        session: guestSession(accessToken: expiredGuestJwt()),
        throwOnClear: true,
      );
      final AuthSessionController controller = AuthSessionController(
        repository: FakeAuthRepository(),
        sessionStore: store,
        now: () => DateTime.utc(2026, 10, 22),
      );

      await controller.restore();

      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.operation, AuthOperation.none);
      expect(controller.state.session, isNull);
      expect(controller.state.errorMessage, contains('credenciales guardadas'));
      expect(store.clearCount, 2);
    },
  );

  test(
    'expired registered access stays outside shell when refresh is offline',
    () async {
      final FakeAuthRepository repository = FakeAuthRepository()
        ..refreshFailure = const AuthFailure(
          AuthFailureKind.network,
          'offline',
        );
      final MemoryAuthSessionStore store = MemoryAuthSessionStore(
        session: registeredSession(accessToken: expiredGuestJwt()),
      );
      final AuthSessionController controller = AuthSessionController(
        repository: repository,
        sessionStore: store,
        now: () => DateTime.utc(2026, 10, 22),
      );

      await controller.restore();

      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.errorMessage, contains('internet'));
      expect(
        store.session,
        isNotNull,
        reason: 'refresh can be retried on restart',
      );
    },
  );

  test(
    'malformed refresh response discards an untrusted stored session',
    () async {
      final FakeAuthRepository repository = FakeAuthRepository()
        ..refreshFailure = const AuthFailure(
          AuthFailureKind.malformedResponse,
          'bad response',
        );
      final MemoryAuthSessionStore store = MemoryAuthSessionStore(
        session: registeredSession(),
      );
      final AuthSessionController controller = AuthSessionController(
        repository: repository,
        sessionStore: store,
      );

      await controller.restore();

      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.errorMessage, contains('validar'));
      expect(store.session, isNull);
    },
  );

  test(
    'refresh is single-flight because the rotated token is one-use',
    () async {
      final FakeAuthRepository repository = FakeAuthRepository();
      final MemoryAuthSessionStore store = MemoryAuthSessionStore();
      final AuthSessionController controller = AuthSessionController(
        repository: repository,
        sessionStore: store,
      );
      await controller.restore();
      await controller.login(
        const LoginInput(email: 'ana@example.com', password: 'secret'),
      );
      repository.refreshCompleter = Completer<AuthSession>();

      final Future<bool> first = controller.refreshSession();
      final Future<bool> second = controller.refreshSession();
      expect(await second, isFalse);
      expect(repository.refreshCalls, 1);
      repository.refreshCompleter!.complete(
        registeredSession(
          accessToken: 'rotated-access',
          refreshToken: 'rotated-refresh',
        ),
      );
      expect(await first, isTrue);
      expect(store.session?.refreshToken, 'rotated-refresh');
    },
  );

  test(
    'logout always clears this device even if server confirmation fails',
    () async {
      final FakeAuthRepository repository = FakeAuthRepository()
        ..logoutFailure = const AuthFailure(AuthFailureKind.network, 'offline');
      final MemoryAuthSessionStore store = MemoryAuthSessionStore();
      final AuthSessionController controller = AuthSessionController(
        repository: repository,
        sessionStore: store,
      );
      await controller.restore();
      await controller.login(
        const LoginInput(email: 'ana@example.com', password: 'secret'),
      );

      await controller.logout();

      expect(repository.lastLogoutToken, 'access-token');
      expect(store.session, isNull);
      expect(controller.state.status, AuthStatus.signedOut);
      expect(controller.state.noticeMessage, contains('este dispositivo'));
    },
  );
}
