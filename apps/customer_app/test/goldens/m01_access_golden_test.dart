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
    testWidgets('access screen matches the $name M01 baseline', (
      WidgetTester tester,
    ) async {
      await _configureGolden(tester);
      const Key boundary = Key('m01-access-golden');
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: CustomerApp(
            environment: environment,
            initialThemeMode: mode,
            authRepository: FakeAuthRepository(),
            sessionStore: MemoryAuthSessionStore(),
            catalogRepository: FakeCatalogRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('m01_access_$name.png'),
      );
    });

    testWidgets('account screen matches the $name M01 baseline', (
      WidgetTester tester,
    ) async {
      await _configureGolden(tester);
      const Key boundary = Key('m01-account-golden');
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: CustomerApp(
            environment: environment,
            initialThemeMode: mode,
            authRepository: FakeAuthRepository(),
            sessionStore: MemoryAuthSessionStore(session: registeredSession()),
            catalogRepository: FakeCatalogRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-cuenta')));
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('m01_account_$name.png'),
      );
    });

    testWidgets('registration screen matches the $name M01 baseline', (
      WidgetTester tester,
    ) async {
      await _configureGolden(tester);
      const Key boundary = Key('m01-registration-golden');
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: CustomerApp(
            environment: environment,
            initialThemeMode: mode,
            authRepository: FakeAuthRepository(),
            sessionStore: MemoryAuthSessionStore(),
            catalogRepository: FakeCatalogRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('go-register')));
      await tester.tap(find.byKey(const Key('go-register')));
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('m01_registration_$name.png'),
      );
    });

    testWidgets('guest screen matches the $name M01 baseline', (
      WidgetTester tester,
    ) async {
      await _configureGolden(tester);
      const Key boundary = Key('m01-guest-golden');
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: CustomerApp(
            environment: environment,
            initialThemeMode: mode,
            authRepository: FakeAuthRepository(),
            sessionStore: MemoryAuthSessionStore(),
            catalogRepository: FakeCatalogRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('go-guest')));
      await tester.tap(find.byKey(const Key('go-guest')));
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('m01_guest_$name.png'),
      );
    });
  }
}

Future<void> _configureGolden(WidgetTester tester) async {
  await _loadAppFonts();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
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
