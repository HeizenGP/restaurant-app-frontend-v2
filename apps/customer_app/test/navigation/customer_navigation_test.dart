import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_fakes.dart';
import '../helpers/catalog_fakes.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment(
    baseUrl: 'https://api.example.test/api/v1',
  );

  testWidgets('bottom navigation switches all declarative branches', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
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

    final SemanticsNode menuNode = tester.getSemantics(
      find.bySemanticsLabel('Menú'),
    );
    tester.binding.platformDispatcher.onSemanticsActionEvent!(
      SemanticsActionEvent(
        type: SemanticsAction.tap,
        viewId: tester.view.viewId,
        nodeId: menuNode.id,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-menu')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-pedidos')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-pedidos')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-cuenta')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-inicio')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('theme control switches the complete shell to dark mode', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_authenticatedApp(environment));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-pedidos')));
    await tester.pumpAndSettle();

    BuildContext pageContext = tester.element(
      find.byKey(const Key('page-pedidos')),
    );
    expect(Theme.of(pageContext).brightness, Brightness.light);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Activar tema oscuro'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(find.byKey(const Key('theme-toggle')));
    await tester.pumpAndSettle();

    pageContext = tester.element(find.byKey(const Key('page-pedidos')));
    expect(Theme.of(pageContext).brightness, Brightness.dark);
    expect(find.text('Mis pedidos'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('home category opens its catalog selection', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_authenticatedApp(environment));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('catalog-category-$categoryTwoId')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-menu')), findsOneWidget);
    expect(find.text('S/ 2.00 · No disponible para la venta'), findsOneWidget);
  });

  testWidgets('available product opens detail outside the bottom shell', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_authenticatedApp(environment));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('catalog-product-$productOneId')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-product-detail')), findsOneWidget);
    expect(find.text('Chaufa especial'), findsOneWidget);
    expect(find.byKey(const Key('nav-menu')), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-menu')), findsOneWidget);
    expect(find.byKey(const Key('nav-menu')), findsOneWidget);
  });

  testWidgets('shell remains usable on a narrow Android screen', (
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
  });
}

CustomerApp _authenticatedApp(ApiEnvironment environment) {
  return CustomerApp(
    environment: environment,
    authRepository: FakeAuthRepository(),
    sessionStore: MemoryAuthSessionStore(session: guestSession()),
    catalogRepository: FakeCatalogRepository(),
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
