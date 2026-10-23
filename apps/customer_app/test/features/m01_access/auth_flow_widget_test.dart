import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:customer_app/features/m01_access/shared/application/auth_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/auth_fakes.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment(
    baseUrl: 'https://api.example.test/api/v1',
  );

  testWidgets('route guard sends a signed-out customer to access', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(environment, FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-acceso')), findsOneWidget);
    expect(find.byKey(const Key('nav-inicio')), findsNothing);
  });

  testWidgets('login validates locally before calling the backend', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(environment, repository));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(repository.lastLogin, isNull);
  });

  testWidgets('invalid credentials stay on access with a safe error', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..loginFailure = const AuthFailure(
        AuthFailureKind.invalidCredentials,
        'El correo o la contraseña no son correctos.',
      );
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(environment, repository));
    await tester.pumpAndSettle();

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ana@example.com');
    await tester.enterText(fields.at(1), 'incorrecta');
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-acceso')), findsOneWidget);
    expect(find.byKey(const Key('auth-error')), findsOneWidget);
    expect(
      find.text('El correo o la contraseña no son correctos.'),
      findsOneWidget,
    );
  });

  testWidgets('registered login persists the session and opens the shell', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(environment, repository, store: store));
    await tester.pumpAndSettle();

    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ana@example.com');
    await tester.enterText(fields.at(1), 'correcta123');
    await tester.ensureVisible(find.byKey(const Key('login-submit')));
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    expect(store.session?.isGuest, isFalse);
    expect(repository.lastLogin?.email, 'ana@example.com');
  });

  testWidgets('registration returns to access without creating a session', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(environment, repository, store: store));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('go-register')));
    await tester.tap(find.byKey(const Key('go-register')));
    await tester.pumpAndSettle();
    final Finder fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ana Torres');
    await tester.enterText(fields.at(1), 'ana@example.com');
    await tester.enterText(fields.at(2), 'correcta123');
    await tester.ensureVisible(find.byKey(const Key('registration-submit')));
    await tester.tap(find.byKey(const Key('registration-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-acceso')), findsOneWidget);
    expect(
      find.text('Cuenta creada. Ya puedes iniciar sesión.'),
      findsOneWidget,
    );
    expect(repository.lastRegistration?.displayName, 'Ana Torres');
    expect(store.session, isNull);
  });

  testWidgets('guest access creates a temporary session and opens the shell', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(environment, repository, store: store));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('go-guest')));
    await tester.tap(find.byKey(const Key('go-guest')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('guest-submit')));
    await tester.tap(find.byKey(const Key('guest-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    expect(store.session?.isGuest, isTrue);
    expect(store.session?.refreshToken, isNull);
  });

  testWidgets('authenticated routes reject access pages', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        environment,
        FakeAuthRepository(),
        store: MemoryAuthSessionStore(session: registeredSession()),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byKey(const Key('page-inicio')),
    );
    GoRouter.of(context).go('/acceso');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    expect(find.byKey(const Key('page-acceso')), findsNothing);
  });

  testWidgets('account logout revokes and clears the current session', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final MemoryAuthSessionStore store = MemoryAuthSessionStore(
      session: registeredSession(),
    );
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_app(environment, repository, store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account-actions')));
    await tester.pumpAndSettle();
    expect(
      find.text('¿Quieres cerrar tu sesión en este dispositivo?'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('logout-confirm')));
    await tester.pumpAndSettle();

    expect(repository.lastLogoutToken, 'new');
    expect(store.session, isNull);
    expect(find.byKey(const Key('page-acceso')), findsOneWidget);
    expect(find.text('Sesión cerrada.'), findsOneWidget);
  });

  testWidgets('access screens scroll without overflow on a narrow viewport', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_app(environment, FakeAuthRepository()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const Key('go-register')));
    await tester.tap(find.byKey(const Key('go-register')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-registro')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('registration-submit')));
    expect(tester.takeException(), isNull);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('go-guest')));
    await tester.tap(find.byKey(const Key('go-guest')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-invitado')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('guest-submit')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('access background reaches both edges on a wide phone', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(432, 900));
    await tester.pumpWidget(_app(environment, FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byKey(const Key('login-hero'))).dx, 0);
    expect(tester.getSize(find.byKey(const Key('login-hero'))).width, 432);
    expect(tester.getTopLeft(find.byKey(const Key('login-sheet'))).dx, 0);
    expect(tester.getSize(find.byKey(const Key('login-sheet'))).width, 432);
    expect(
      tester.getTopLeft(find.byKey(const Key('login-artwork-canvas'))).dx,
      21,
    );

    await tester.ensureVisible(find.byKey(const Key('go-guest')));
    await tester.tap(find.byKey(const Key('go-guest')));
    await tester.pumpAndSettle();
    final Finder overlay = find.ancestor(
      of: find.byKey(const Key('page-invitado')),
      matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(overlay, findsOneWidget);
    expect(
      tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(overlay)
          .value
          .statusBarIconBrightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });
}

CustomerApp _app(
  ApiEnvironment environment,
  FakeAuthRepository repository, {
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
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);
}
