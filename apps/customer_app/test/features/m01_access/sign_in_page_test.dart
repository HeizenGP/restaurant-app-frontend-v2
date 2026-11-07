import 'dart:async';

import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m01_access/presentation/sign_in_page.dart';
import 'package:customer_app/features/m01_access/shared/application/auth_contracts.dart';
import 'package:customer_app/features/m01_access/shared/application/auth_session_controller.dart';
import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_fakes.dart';

void main() {
  testWidgets('renders the complete login hierarchy in light and dark themes', (
    WidgetTester tester,
  ) async {
    for (final ThemeMode mode in <ThemeMode>[ThemeMode.light, ThemeMode.dark]) {
      final FakeAuthRepository repository = FakeAuthRepository();
      final AuthSessionController controller = _controller(repository);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _SignInHarness(controller: controller, themeMode: mode),
      );
      await tester.pump();

      expect(find.byType(KairoLogo), findsOneWidget);
      expect(find.text('Bienvenido de vuelta'), findsOneWidget);
      expect(find.byKey(const Key('signin-email-input')), findsOneWidget);
      expect(find.byKey(const Key('signin-password-input')), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Continuar como invitado'), findsOneWidget);
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
      expect(find.text('Crear una cuenta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('validates locally and focuses the first invalid field', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final AuthSessionController controller = _controller(repository);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_SignInHarness(controller: controller));

    await tester.ensureVisible(find.byKey(const Key('signin-submit-button')));
    await tester.tap(find.byKey(const Key('signin-submit-button')));
    await tester.pump();

    expect(find.text('Ingresa tu correo electrónico.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
    expect(repository.loginCalls, 0);
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .focusNode
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('toggles password visibility with an accessible control', (
    WidgetTester tester,
  ) async {
    final AuthSessionController controller = _controller(FakeAuthRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(_SignInHarness(controller: controller));

    final Finder passwordField = find.byType(TextField).at(1);
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);

    await tester.tap(find.bySemanticsLabel('Mostrar contraseña'));
    await tester.pump();

    expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
    expect(find.bySemanticsLabel('Ocultar contraseña'), findsOneWidget);
  });

  testWidgets('shows loading, prevents duplicate login and completes once', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..loginCompleter = Completer<AuthSession>();
    final AuthSessionController controller = _controller(repository);
    addTearDown(controller.dispose);
    var successCount = 0;

    await tester.pumpWidget(
      _SignInHarness(
        controller: controller,
        onSuccess: () => successCount += 1,
      ),
    );
    await tester.enterText(
      find.byKey(const Key('signin-email-input')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('signin-password-input')),
      'correct-password',
    );
    await tester.ensureVisible(find.byKey(const Key('signin-submit-button')));
    await tester.tap(find.byKey(const Key('signin-submit-button')));
    await tester.pump();
    await tester.pump();

    expect(repository.loginCalls, 1);
    expect(find.text('Verificando acceso…'), findsOneWidget);

    await tester.tap(find.byKey(const Key('signin-submit-button')));
    await tester.pump();
    expect(repository.loginCalls, 1);

    repository.loginCompleter!.complete(registeredSession());
    await tester.pumpAndSettle();

    expect(successCount, 1);
    expect(find.text('Acceso confirmado'), findsOneWidget);
  });

  testWidgets('keeps credentials and presents a contextual server error', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository()
      ..loginFailure = const AuthFailure(
        AuthFailureKind.invalidCredentials,
        'El correo o la contraseña no son correctos.',
      );
    final AuthSessionController controller = _controller(repository);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_SignInHarness(controller: controller));

    await tester.enterText(
      find.byKey(const Key('signin-email-input')),
      'ana@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('signin-password-input')),
      'wrong-password',
    );
    await tester.ensureVisible(find.byKey(const Key('signin-submit-button')));
    await tester.tap(find.byKey(const Key('signin-submit-button')));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('El correo o la contraseña no son correctos.'),
      findsOneWidget,
    );
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('wrong-password'), findsOneWidget);
  });

  testWidgets('Google exchanges an ID token for the same KAIRO session', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final AuthSessionController controller = _controller(repository);
    addTearDown(controller.dispose);
    var successCount = 0;
    await tester.pumpWidget(
      _SignInHarness(
        controller: controller,
        onSuccess: () => successCount += 1,
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('signin-google-button')));
    await tester.tap(find.byKey(const Key('signin-google-button')));
    await tester.pumpAndSettle();

    expect(repository.googleLoginCalls, 1);
    expect(controller.state.status, AuthStatus.signedIn);
    expect(successCount, 1);
  });

  testWidgets('registration and guest actions remain reachable', (
    WidgetTester tester,
  ) async {
    final AuthSessionController controller = _controller(FakeAuthRepository());
    addTearDown(controller.dispose);
    var registerTaps = 0;
    var guestTaps = 0;
    await tester.pumpWidget(
      _SignInHarness(
        controller: controller,
        onRegister: () => registerTaps += 1,
        onGuest: () => guestTaps += 1,
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('signin-guest-button')));
    await tester.tap(find.byKey(const Key('signin-guest-button')));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const Key('signin-to-register-link')),
    );
    await tester.tap(find.byKey(const Key('signin-to-register-link')));
    await tester.pump();

    expect(guestTaps, 1);
    expect(registerTaps, 1);
  });

  testWidgets('reflows with large text and an open keyboard without overflow', (
    WidgetTester tester,
  ) async {
    final AuthSessionController controller = _controller(FakeAuthRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _SignInHarness(
        controller: controller,
        mediaQueryData: const MediaQueryData(
          size: Size(320, 568),
          viewInsets: EdgeInsets.only(bottom: 280),
          textScaler: TextScaler.linear(2),
          disableAnimations: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('signin-scroll-view')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('primary controls meet Android touch target guidance', (
    WidgetTester tester,
  ) async {
    final AuthSessionController controller = _controller(FakeAuthRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(_SignInHarness(controller: controller));
    await tester.pump();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}

AuthSessionController _controller(FakeAuthRepository repository) {
  return AuthSessionController(
    repository: repository,
    sessionStore: MemoryAuthSessionStore(),
    googleIdentityProvider: FakeGoogleIdentityProvider(),
  );
}

class _SignInHarness extends StatelessWidget {
  const _SignInHarness({
    required this.controller,
    this.themeMode = ThemeMode.light,
    this.mediaQueryData = const MediaQueryData(
      size: Size(390, 844),
      disableAnimations: true,
    ),
    this.onSuccess,
    this.onRegister,
    this.onGuest,
  });

  final AuthSessionController controller;
  final ThemeMode themeMode;
  final MediaQueryData mediaQueryData;
  final VoidCallback? onSuccess;
  final VoidCallback? onRegister;
  final VoidCallback? onGuest;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AsiaAppTheme.light,
      darkTheme: AsiaAppTheme.dark,
      themeMode: themeMode,
      home: MediaQuery(
        data: mediaQueryData,
        child: SignInPage(
          controller: controller,
          onRegisterTap: onRegister ?? () {},
          onGuestTap: onGuest ?? () {},
          onForgotPasswordTap: () {},
          onSuccess: onSuccess ?? () {},
        ),
      ),
    );
  }
}
