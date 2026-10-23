import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m01_access/continue_as_guest/presentation/guest_access_page.dart';
import 'package:customer_app/features/m01_access/register_account/presentation/registration_page.dart';
import 'package:customer_app/features/m01_access/shared/application/auth_session_controller.dart';
import 'package:customer_app/features/m01_access/sign_in/presentation/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_fakes.dart';

void main() {
  final List<_AccessVisualCase> cases = <_AccessVisualCase>[
    const _AccessVisualCase('01_login', _AccessScreen.login),
    const _AccessVisualCase('02_registration', _AccessScreen.registration),
    const _AccessVisualCase('03_guest', _AccessScreen.guest),
  ];

  setUpAll(_loadAppFonts);

  for (final _AccessVisualCase visualCase in cases) {
    for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
      ('light', ThemeMode.light),
      ('dark', ThemeMode.dark),
    ]) {
      testWidgets('${visualCase.name} matches the $suffix Flutter baseline', (
        WidgetTester tester,
      ) async {
        await _configureFigmaViewport(tester);
        final AuthSessionController controller = AuthSessionController(
          repository: FakeAuthRepository(),
          sessionStore: MemoryAuthSessionStore(),
        );
        addTearDown(controller.dispose);
        await controller.restore();
        const Key boundaryKey = Key('m01-access-golden');

        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              home: switch (visualCase.screen) {
                _AccessScreen.login => SignInPage(authController: controller),
                _AccessScreen.registration => RegistrationPage(
                  authController: controller,
                ),
                _AccessScreen.guest => GuestAccessPage(
                  authController: controller,
                ),
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await expectLater(
          find.byKey(boundaryKey),
          matchesGoldenFile('m01_access_${visualCase.name}_$suffix.png'),
        );
      });
    }
  }
}

enum _AccessScreen { login, registration, guest }

class _AccessVisualCase {
  const _AccessVisualCase(this.name, this.screen);

  final String name;
  final _AccessScreen screen;
}

Future<void> _configureFigmaViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);
}

Future<void> _loadAppFonts() async {
  final FontLoader bodyFont = FontLoader('DM Sans')
    ..addFont(rootBundle.load('assets/fonts/DMSans-Variable.ttf'));
  final FontLoader displayFont = FontLoader('Cormorant Garamond')
    ..addFont(rootBundle.load('assets/fonts/CormorantGaramond-Variable.ttf'));
  final FontLoader lucideFont =
      FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      );
  await Future.wait(<Future<void>>[
    bodyFont.load(),
    displayFont.load(),
    lucideFont.load(),
  ]);
}
