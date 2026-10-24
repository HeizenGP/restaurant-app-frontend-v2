import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_fakes.dart';
import '../helpers/catalog_fakes.dart';
import '../helpers/order_tracking_fakes.dart';
import '../helpers/orders_fakes.dart';
import '../helpers/payment_fakes.dart';
import '../helpers/tables_fakes.dart';

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
    expect(find.byKey(const Key('home-empty-catalog')), findsNothing);
    expect(find.text('Arroces'), findsOneWidget);
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
    expect(find.byKey(const Key('catalog-empty-state')), findsNothing);
    expect(find.text(productOne.name), findsOneWidget);

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

  testWidgets('menu opens detail with the selected product and no extra GET', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final FakeCatalogRepository repository = FakeCatalogRepository();
    await tester.pumpWidget(
      CustomerApp(
        environment: environment,
        authRepository: FakeAuthRepository(refreshResult: registeredSession()),
        sessionStore: MemoryAuthSessionStore(session: registeredSession()),
        catalogRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-menu')));
    await tester.pumpAndSettle();
    final Finder shellOverlay = find.ancestor(
      of: find.byKey(const Key('page-menu')),
      matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(shellOverlay, findsOneWidget);
    expect(
      tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(shellOverlay)
          .value
          .statusBarIconBrightness,
      Brightness.dark,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('catalog-product-$productOneId')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-product-detail')), findsOneWidget);
    expect(find.text(productOne.name), findsOneWidget);
    expect(find.text('Precio · S/ 24.25'), findsOneWidget);
    expect(repository.productCalls, <String>[categoryOneId]);

    await tester.tap(find.byKey(const Key('product-add-to-cart')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-cart')), findsOneWidget);
    expect(find.text(productOne.name), findsOneWidget);
    expect(find.text('1 unidad · S/ 24.25'), findsOneWidget);
    expect(find.byKey(const Key('nav-menu')), findsOneWidget);
    expect(repository.productCalls, <String>[categoryOneId]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'cart submits local fulfillment once and consults the created order',
    (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await _configurePhoneSurface(tester, const Size(390, 844));
      final FakeTablesRepository tablesRepository = FakeTablesRepository();
      final FakeOrdersRepository ordersRepository = FakeOrdersRepository();
      await tester.pumpWidget(
        CustomerApp(
          environment: environment,
          authRepository: FakeAuthRepository(
            refreshResult: registeredSession(),
          ),
          sessionStore: MemoryAuthSessionStore(session: registeredSession()),
          catalogRepository: FakeCatalogRepository(),
          tablesRepository: tablesRepository,
          ordersRepository: ordersRepository,
        ),
      );
      await tester.pumpAndSettle();

      await _openCartWithProduct(tester);
      expect(
        tester
            .widget<ChifaButton>(find.byKey(const Key('cart-continue')))
            .onPressed,
        isNotNull,
      );

      await tester.tap(find.byKey(const Key('cart-continue')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-fulfillment-mode')), findsOneWidget);
      expect(find.byKey(const Key('nav-menu')), findsNothing);

      await tester.tap(find.byKey(const Key('fulfillment-mode-local')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-table-selection')), findsOneWidget);
      expect(tablesRepository.listCalls, 1);
      expect(find.text('Mesa A-01'), findsOneWidget);
      expect(find.text('Mesa A-02'), findsOneWidget);
      expect(
        tester
            .getSemantics(find.byKey(const Key('table-table-2')))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );

      await tester.tap(find.byKey(const Key('table-table-2')));
      await tester.pump();
      expect(
        tester
            .widget<ChifaButton>(find.byKey(const Key('table-finish')))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const Key('table-table-1')));
      await tester.pump();
      expect(
        tester
            .widget<ChifaButton>(find.byKey(const Key('table-finish')))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const Key('table-finish')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-review')), findsOneWidget);
      expect(tablesRepository.listCalls, 1);
      expect(find.text('1 producto · 1 unidad'), findsOneWidget);
      expect(find.text('Consumo en local · A-01'), findsOneWidget);
      expect(find.text('S/ 24.25 estimado por el carrito'), findsOneWidget);

      await tester.tap(find.byKey(const Key('order-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-submitted')), findsOneWidget);
      expect(find.text('Estado: REQUESTED'), findsOneWidget);
      expect(ordersRepository.createCommands, hasLength(1));
      expect(ordersRepository.detailIds, <String>[
        '00000000-0000-4000-8000-000000000201',
      ]);
      expect(ordersRepository.idempotencyKeys.single, isNotEmpty);
      expect(
        ordersRepository.createCommands.single.fulfillment,
        FulfillmentDraft.local(tableId: 'table-1'),
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('fulfillment mode opens pickup and delivery routes', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      CustomerApp(
        environment: environment,
        authRepository: FakeAuthRepository(refreshResult: registeredSession()),
        sessionStore: MemoryAuthSessionStore(session: registeredSession()),
        catalogRepository: FakeCatalogRepository(),
        tablesRepository: FakeTablesRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await _openCartWithProduct(tester);
    await tester.tap(find.byKey(const Key('cart-continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('fulfillment-mode-pickup')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-pickup-details')), findsOneWidget);
    expect(find.byKey(const Key('nav-menu')), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-fulfillment-mode')), findsOneWidget);

    await tester.tap(find.byKey(const Key('fulfillment-mode-delivery')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-delivery-details')), findsOneWidget);
    expect(find.byKey(const Key('nav-menu')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('advance and payment status routes render read-only summaries', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final FakePaymentStatusRepository paymentRepo = FakePaymentStatusRepository(
      advanceResponse: fakeAdvanceSummary(orderId: 'ord-nav-1'),
      paymentResponse: fakePaymentSummary(orderId: 'ord-nav-1'),
    );
    await tester.pumpWidget(
      CustomerApp(
        environment: environment,
        authRepository: FakeAuthRepository(refreshResult: registeredSession()),
        sessionStore: MemoryAuthSessionStore(session: registeredSession()),
        catalogRepository: FakeCatalogRepository(),
        paymentStatusRepository: paymentRepo,
      ),
    );
    await tester.pumpAndSettle();

    // Verify app starts authenticated
    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('orders tab navigates to detail tracking page on card tap', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final FakeOrderTrackingRepository trackingRepo = FakeOrderTrackingRepository(
      orders: <OrderSnapshot>[
        fakeOrderSnapshot(id: '00000000-0000-4000-8000-000000000201', status: 'CONFIRMED'),
      ],
      order: fakeOrderSnapshot(id: '00000000-0000-4000-8000-000000000201', status: 'CONFIRMED'),
      tracking: fakeTrackingSnapshot(orderId: '00000000-0000-4000-8000-000000000201', stage: 'EN_COCINA'),
    );

    await tester.pumpWidget(
      CustomerApp(
        environment: environment,
        authRepository: FakeAuthRepository(refreshResult: registeredSession()),
        sessionStore: MemoryAuthSessionStore(session: registeredSession()),
        catalogRepository: FakeCatalogRepository(),
        orderTrackingRepository: trackingRepo,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-pedidos')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-pedidos')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('order-card-00000000-0000-4000-8000-000000000201')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('order-card-00000000-0000-4000-8000-000000000201')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-order-tracking')), findsOneWidget);
    expect(find.textContaining('Etapa: EN_COCINA'), findsOneWidget);
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
    await _configurePhoneSurface(tester, const Size(432, 960));
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
    final Rect accountFrame = tester.getRect(
      find.byKey(const Key('account-content-frame')),
    );
    expect(accountFrame.left, 18);
    expect(accountFrame.right, 414);
    expect(accountCard.width, lessThanOrEqualTo(392));
    expect(accountCard.center.dx, closeTo(216, 0.5));
    expect(tester.takeException(), isNull);
  });
}

CustomerApp _authenticatedApp(ApiEnvironment environment) {
  return _appWithSession(environment, registeredSession());
}

Future<void> _openCartWithProduct(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-menu')));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(const ValueKey<String>('catalog-product-$productOneId')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('product-add-to-cart')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('page-cart')), findsOneWidget);
}

CustomerApp _appWithSession(ApiEnvironment environment, AuthSession session) {
  return CustomerApp(
    environment: environment,
    authRepository: FakeAuthRepository(refreshResult: session),
    sessionStore: MemoryAuthSessionStore(session: session),
    catalogRepository: FakeCatalogRepository(),
    orderTrackingRepository: FakeOrderTrackingRepository(
      orders: const <OrderSnapshot>[],
    ),
    paymentStatusRepository: FakePaymentStatusRepository(),
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
