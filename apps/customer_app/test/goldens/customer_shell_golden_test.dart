import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_fakes.dart';
import '../helpers/catalog_fakes.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment(
    baseUrl: 'https://api.example.test/api/v1',
  );

  for (final (String name, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('home shell matches the $name visual baseline', (
      WidgetTester tester,
    ) async {
      await _loadAppFonts();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      const Key goldenBoundary = Key('customer-shell-golden');
      await tester.pumpWidget(
        RepaintBoundary(
          key: goldenBoundary,
          child: CustomerApp(
            environment: environment,
            initialThemeMode: mode,
            authRepository: FakeAuthRepository(),
            sessionStore: MemoryAuthSessionStore(session: guestSession()),
            catalogRepository: FakeCatalogRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(goldenBoundary),
        matchesGoldenFile('customer_shell_$name.png'),
      );
    });
  }
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
