import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_fakes.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment(
    baseUrl: 'https://api.example.test/api/v1',
  );

  testWidgets('bottom navigation switches the four declarative branches', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_authenticatedApp(environment));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    expect(find.bySemanticsLabel('Menú'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Menú'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(find.byKey(const Key('nav-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-menu')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-pedidos')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-pedidos')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-cuenta')), findsOneWidget);
    expect(find.text('Ana Torres'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-inicio')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('theme control preserves the active route and account data', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_authenticatedApp(environment));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();

    BuildContext pageContext = tester.element(
      find.byKey(const Key('page-cuenta')),
    );
    expect(Theme.of(pageContext).brightness, Brightness.light);
    expect(find.text('Ana Torres'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();

    pageContext = tester.element(find.byKey(const Key('page-cuenta')));
    expect(Theme.of(pageContext).brightness, Brightness.dark);
    expect(find.text('Ana Torres'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('foundation remains usable on a narrow Android viewport', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_authenticatedApp(environment));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('nav-menu')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-menu')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-cuenta')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

CustomerApp _authenticatedApp(ApiEnvironment environment) {
  final AuthSession session = registeredSession();
  return CustomerApp(
    environment: environment,
    authRepository: FakeAuthRepository(refreshResult: session),
    sessionStore: MemoryAuthSessionStore(session: session),
  );
}

Future<void> _configurePhoneSurface(
  WidgetTester tester,
  Size logicalSize,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = logicalSize;
  tester.view.padding = const FakeViewPadding(bottom: 24);
  addTearDown(tester.view.reset);
}
