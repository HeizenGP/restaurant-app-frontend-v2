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
    expect(find.byKey(const Key('home-empty-catalog')), findsOneWidget);
    expect(find.text('Arroces'), findsNothing);
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
    expect(find.byKey(const Key('catalog-empty-state')), findsOneWidget);
    expect(find.text('Plato del catálogo'), findsNothing);

    await tester.tap(find.byKey(const Key('nav-pedidos')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-pedidos')), findsOneWidget);
    expect(find.byKey(const Key('orders-empty-state')), findsOneWidget);
    expect(find.textContaining('Pedido #'), findsNothing);

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-cuenta')), findsOneWidget);
    expect(find.text('Ana Torres'), findsWidgets);

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
    expect(find.text('Ana Torres'), findsWidgets);
    expect(find.text('ana@example.com'), findsWidgets);
    expect(find.text('CUENTA REGISTRADA'), findsOneWidget);
    expect(find.text('SESIÓN DE INVITADO'), findsNothing);
    expect(find.byKey(const Key('guest-account-empty-state')), findsNothing);

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();

    pageContext = tester.element(find.byKey(const Key('page-cuenta')));
    expect(Theme.of(pageContext).brightness, Brightness.dark);
    expect(find.text('Ana Torres'), findsWidgets);
    expect(find.text('ana@example.com'), findsWidgets);
    expect(find.text('CUENTA REGISTRADA'), findsOneWidget);
    expect(find.text('SESIÓN DE INVITADO'), findsNothing);
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

    await tester.ensureVisible(find.byKey(const Key('account-orders-action')));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const Key('account-orders-action'))).height,
      greaterThanOrEqualTo(47),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest account never appears as a registered customer', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_appWithSession(environment, guestSession()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();

    expect(find.text('Invitado'), findsOneWidget);
    expect(find.text('SESIÓN DE INVITADO'), findsOneWidget);
    expect(find.text('CUENTA REGISTRADA'), findsNothing);
    expect(find.text('correo@ejemplo.com'), findsNothing);
    expect(find.byKey(const Key('guest-account-empty-state')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile scrolls with large text and Android safe insets', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(
      tester,
      const Size(390, 844),
      padding: const FakeViewPadding(top: 44, bottom: 34),
    );
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(_authenticatedApp(environment));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const Key('page-cuenta'))).dy,
      greaterThanOrEqualTo(44),
    );
    await tester.ensureVisible(find.byKey(const Key('account-data-card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('account-data-card')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('account-orders-action'))).height,
      greaterThanOrEqualTo(47),
    );
    expect(
      tester.getBottomRight(find.byKey(const Key('account-data-card'))).dy,
      lessThanOrEqualTo(
        tester.getTopLeft(find.byKey(const Key('nav-inicio'))).dy,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile stays centered with a long identity on wide screens', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(600, 960));
    final CustomerIdentity identity = CustomerIdentity(
      id: 'customer-wide-profile',
      displayName: 'Nombre de cliente registrado considerablemente largo',
      email: 'cliente.registrado.con.correo.extenso@example.com',
      isActive: true,
      roles: const <String>['CUSTOMER'],
      createdAt: DateTime.utc(2026, 10, 23),
    );
    final AuthSession session = AuthSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      tokenType: 'bearer',
      kind: AuthSessionKind.user,
      user: identity,
    );
    await tester.pumpWidget(_appWithSession(environment, session));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();

    expect(find.text(identity.displayName), findsWidgets);
    expect(find.text(identity.email), findsWidgets);
    final Rect accountCard = tester.getRect(
      find.byKey(const Key('account-data-card')),
    );
    expect(accountCard.width, lessThanOrEqualTo(350));
    expect(accountCard.center.dx, closeTo(300, 0.5));
    expect(tester.takeException(), isNull);
  });
}

CustomerApp _authenticatedApp(ApiEnvironment environment) {
  return _appWithSession(environment, registeredSession());
}

CustomerApp _appWithSession(ApiEnvironment environment, AuthSession session) {
  return CustomerApp(
    environment: environment,
    authRepository: FakeAuthRepository(refreshResult: session),
    sessionStore: MemoryAuthSessionStore(session: session),
  );
}

Future<void> _configurePhoneSurface(
  WidgetTester tester,
  Size logicalSize, {
  FakeViewPadding padding = const FakeViewPadding(bottom: 24),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = logicalSize;
  tester.view.padding = padding;
  addTearDown(tester.view.reset);
}
