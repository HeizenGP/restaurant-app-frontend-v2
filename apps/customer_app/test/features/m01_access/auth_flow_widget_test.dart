import 'dart:async';

import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:customer_app/features/m01_access/shared/application/auth_contracts.dart';
import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_fakes.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment(
    baseUrl: 'https://api.example.test/api/v1',
  );

  testWidgets('route guard sends a signed-out customer to access', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(environment: environment, repository: FakeAuthRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-acceso')), findsOneWidget);
    expect(find.byKey(const Key('nav-inicio')), findsNothing);
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  testWidgets('login validates form before calling backend', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(environment: environment, repository: repository),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(repository.lastLogin, isNull);
  });

  testWidgets('invalid credentials display a safe inline error', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..loginFailure = const AuthFailure(
        AuthFailureKind.invalidCredentials,
        'El correo o la contraseña no son correctos.',
      );
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(environment: environment, repository: repository),
    );
    await tester.pumpAndSettle();
    final Finder fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'ana@example.com');
    await tester.enterText(fields.at(1), 'incorrecta');
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth-error')), findsOneWidget);
    expect(
      find.text('El correo o la contraseña no son correctos.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('page-acceso')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('go-register')));
    await tester.tap(find.byKey(const Key('go-register')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-registro')), findsOneWidget);
    expect(find.byKey(const Key('auth-error')), findsNothing);
  });

  testWidgets(
    'registration validates and returns to login without signing in',
    (WidgetTester tester) async {
      final FakeAuthRepository repository = FakeAuthRepository();
      final MemoryAuthSessionStore store = MemoryAuthSessionStore();
      await _configurePhoneSurface(tester, const Size(390, 844));
      await tester.pumpWidget(
        _app(environment: environment, repository: repository, store: store),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('go-register')));
      await tester.tap(find.byKey(const Key('go-register')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('page-registro')), findsOneWidget);

      final Finder fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ana Torres');
      await tester.enterText(fields.at(1), 'ana@example.com');
      await tester.enterText(fields.at(2), 'correcta123');
      await tester.ensureVisible(find.byKey(const Key('register-submit')));
      await tester.tap(find.byKey(const Key('register-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-acceso')), findsOneWidget);
      expect(
        find.text('Cuenta creada. Ya puedes iniciar sesión.'),
        findsOneWidget,
      );
      expect(repository.lastRegistration?.displayName, 'Ana Torres');
      expect(store.session, isNull);
    },
  );

  testWidgets('registration blocks system back while the request is pending', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..registrationCompleter = Completer<CustomerIdentity>();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(environment: environment, repository: repository),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('go-register')));
    await tester.tap(find.byKey(const Key('go-register')));
    await tester.pumpAndSettle();
    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ana Torres');
    await tester.enterText(fields.at(1), 'ana@example.com');
    await tester.enterText(fields.at(2), 'correcta123');
    await tester.ensureVisible(find.byKey(const Key('register-submit')));
    await tester.tap(find.byKey(const Key('register-submit')));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('page-registro')), findsOneWidget);
    expect(repository.lastRegistration, isNotNull);

    repository.registrationCompleter!.complete(customerIdentity);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-acceso')), findsOneWidget);
    expect(find.textContaining('Cuenta creada'), findsOneWidget);
  });

  testWidgets('guest access persists a temporary session and opens the shell', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(environment: environment, repository: repository, store: store),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('go-guest')));
    await tester.tap(find.byKey(const Key('go-guest')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-invitado')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('guest-submit')));
    await tester.tap(find.byKey(const Key('guest-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    expect(store.session?.isGuest, isTrue);
    expect(store.session?.refreshToken, isNull);
  });

  testWidgets('guest access blocks system back while the request is pending', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..guestCompleter = Completer<AuthSession>();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(environment: environment, repository: repository),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('go-guest')));
    await tester.tap(find.byKey(const Key('go-guest')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('guest-submit')));
    await tester.tap(find.byKey(const Key('guest-submit')));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('page-invitado')), findsOneWidget);
    expect(repository.guestCalls, 1);

    repository.guestCompleter!.complete(guestSession());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
  });

  testWidgets('account logout revokes and clears the session', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore(
      session: registeredSession(),
    );
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(environment: environment, repository: repository, store: store),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    expect(find.textContaining('CUENTA REGISTRADA'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('logout-submit')),
      360,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const Key('logout-submit')));
    await tester.pumpAndSettle();

    expect(repository.lastLogoutToken, 'new');
    expect(store.session, isNull);
    expect(find.byKey(const Key('page-acceso')), findsOneWidget);
    expect(find.text('Sesión cerrada.'), findsOneWidget);
  });

  testWidgets('account presents guest identity without inventing user data', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        environment: environment,
        repository: FakeAuthRepository(),
        store: MemoryAuthSessionStore(session: guestSession()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();

    expect(find.textContaining('SESIÓN INVITADA'), findsOneWidget);
    expect(find.text('Sesión temporal'), findsOneWidget);
    expect(find.text('ana@example.com'), findsNothing);
  });

  testWidgets('account adapts on a narrow screen with enlarged text', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      _app(
        environment: environment,
        repository: FakeAuthRepository(),
        store: MemoryAuthSessionStore(session: registeredSession()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const Key('logout-submit')),
      360,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('logout-submit')), findsOneWidget);
    expect(find.text('Preferencias'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('access UI supports dark theme and narrow Android screens', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.25;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      _app(environment: environment, repository: FakeAuthRepository()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('access-theme-toggle')));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byKey(const Key('page-acceso')),
    );
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

CustomerApp _app({
  required ApiEnvironment environment,
  required FakeAuthRepository repository,
  MemoryAuthSessionStore? store,
}) {
  return CustomerApp(
    environment: environment,
    authRepository: repository,
    sessionStore: store ?? MemoryAuthSessionStore(),
  );
}

Future<void> _configurePhoneSurface(
  WidgetTester tester,
  Size logicalSize,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = logicalSize;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}
