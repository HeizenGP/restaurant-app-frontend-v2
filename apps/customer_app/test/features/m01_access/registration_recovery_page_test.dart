import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m01_access/presentation/password_recovery_page.dart';
import 'package:customer_app/features/m01_access/presentation/registration_page.dart';
import 'package:customer_app/features/m01_access/shared/application/auth_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_fakes.dart';

void main() {
  testWidgets(
    'registration validates confirmation and sends only the password',
    (WidgetTester tester) async {
      final FakeAuthRepository repository = FakeAuthRepository();
      final AuthSessionController controller = _controller(repository);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _harness(
          RegistrationPage(
            controller: controller,
            onBackToSignIn: () {},
            onSuccess: () {},
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('register-name-input')),
        'Ana Torres',
      );
      await tester.enterText(
        find.byKey(const Key('register-email-input')),
        'ana@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register-password-input')),
        'Kairo123',
      );
      await tester.enterText(
        find.byKey(const Key('register-confirm-password-input')),
        'Kairo124',
      );
      await tester.ensureVisible(
        find.byKey(const Key('register-submit-button')),
      );
      await tester.tap(find.byKey(const Key('register-submit-button')));
      await tester.pump();
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      expect(repository.lastRegistration, isNull);

      await tester.enterText(
        find.byKey(const Key('register-confirm-password-input')),
        'Kairo123',
      );
      await tester.tap(find.byKey(const Key('register-submit-button')));
      await tester.pumpAndSettle();
      expect(repository.lastRegistration?.password, 'Kairo123');
    },
  );

  testWidgets('password recovery requests and confirms a one-time token', (
    WidgetTester tester,
  ) async {
    final FakeAuthRepository repository = FakeAuthRepository();
    final AuthSessionController controller = _controller(repository);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _harness(
        PasswordRecoveryPage(
          controller: controller,
          onBack: () {},
          onCompleted: () {},
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('recovery-email-input')),
      'ana@example.com',
    );
    await tester.tap(find.byKey(const Key('recovery-request-button')));
    await tester.pumpAndSettle();
    expect(repository.passwordResetRequestCalls, 1);
    expect(find.byKey(const Key('reset-token-input')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('reset-token-input')),
      'opaque-recovery-token-with-enough-length',
    );
    await tester.enterText(
      find.byKey(const Key('reset-password-input')),
      'NewKairo123',
    );
    await tester.enterText(
      find.byKey(const Key('reset-confirm-password-input')),
      'NewKairo123',
    );
    await tester.ensureVisible(find.byKey(const Key('reset-submit-button')));
    await tester.tap(find.byKey(const Key('reset-submit-button')));
    await tester.pumpAndSettle();
    expect(repository.passwordResetConfirmCalls, 1);
  });
}

AuthSessionController _controller(FakeAuthRepository repository) {
  return AuthSessionController(
    repository: repository,
    sessionStore: MemoryAuthSessionStore(),
    googleIdentityProvider: FakeGoogleIdentityProvider(),
  );
}

Widget _harness(Widget child) {
  return MaterialApp(
    theme: AsiaAppTheme.light,
    home: MediaQuery(
      data: const MediaQueryData(size: Size(390, 844), disableAnimations: true),
      child: child,
    ),
  );
}
