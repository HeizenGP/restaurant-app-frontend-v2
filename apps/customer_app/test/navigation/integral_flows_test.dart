import 'dart:async';

import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/app/navigation/customer_router.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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

  group('10.10 — Integral customer flows', () {
    testWidgets('PICKUP full flow: browse -> cart -> pickup -> review -> submit -> advance & tracking', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final FakeOrdersRepository ordersRepo = FakeOrdersRepository();
      final FakePaymentStatusRepository paymentRepo = FakePaymentStatusRepository(
        advanceResponse: fakeAdvanceSummary(orderId: '00000000-0000-4000-8000-000000000201'),
      );
      final FakeOrderTrackingRepository trackingRepo = FakeOrderTrackingRepository(
        orders: <OrderSnapshot>[fakeOrderSnapshot(id: '00000000-0000-4000-8000-000000000201')],
        order: fakeOrderSnapshot(id: '00000000-0000-4000-8000-000000000201'),
        tracking: fakeTrackingSnapshot(orderId: '00000000-0000-4000-8000-000000000201', stage: 'EN_COCINA'),
      );

      await tester.pumpWidget(
        CustomerApp(
          environment: environment,
          authRepository: FakeAuthRepository(refreshResult: registeredSession()),
          sessionStore: MemoryAuthSessionStore(session: registeredSession()),
          catalogRepository: FakeCatalogRepository(),
          tablesRepository: FakeTablesRepository(),
          ordersRepository: ordersRepo,
          paymentStatusRepository: paymentRepo,
          orderTrackingRepository: trackingRepo,
        ),
      );
      await tester.pumpAndSettle();

      // 1. Catálogo -> seleccionar producto
      await tester.tap(find.byKey(const Key('nav-menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('catalog-product-$productOneId')));
      await tester.pumpAndSettle();

      // 2. Agregar al carrito
      await tester.tap(find.byKey(const Key('product-add-to-cart')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-cart')), findsOneWidget);
      await tester.tap(find.byKey(const Key('cart-continue')));
      await tester.pumpAndSettle();

      // 3. Modalidad PICKUP
      expect(find.byKey(const Key('page-fulfillment-mode')), findsOneWidget);
      await tester.tap(find.byKey(const Key('fulfillment-mode-pickup')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-pickup-details')), findsOneWidget);
      final Finder textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Carlos Mendoza');
      await tester.enterText(textFields.at(1), '987654321');
      await tester.tap(find.byKey(const Key('pickup-finish')));
      await tester.pumpAndSettle();

      // 4. Revisión y confirmación de pedido
      expect(find.byKey(const Key('page-order-review')), findsOneWidget);
      expect(find.textContaining('Carlos Mendoza'), findsOneWidget);

      await tester.tap(find.byKey(const Key('order-submit')));
      await tester.pumpAndSettle();

      // 5. Pantalla de confirmación REQUESTED
      expect(find.byKey(const Key('page-order-submitted')), findsOneWidget);
      expect(find.text('Estado: REQUESTED'), findsOneWidget);
      expect(ordersRepo.createCommands, hasLength(1));

      // 6. Consultar anticipo
      final BuildContext context = tester.element(find.byKey(const Key('page-order-submitted')));
      unawaited(
        GoRouter.of(context).pushNamed(
          CustomerRoutes.orderAdvance,
          pathParameters: <String, String>{'orderId': '00000000-0000-4000-8000-000000000201'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-advance-summary')), findsOneWidget);
      expect(find.textContaining('50 %'), findsWidgets);

      // 7. Retornar y consultar tracking
      unawaited(
        GoRouter.of(context).pushNamed(
          CustomerRoutes.orderTracking,
          pathParameters: <String, String>{'orderId': '00000000-0000-4000-8000-000000000201'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-tracking')), findsOneWidget);
      expect(find.textContaining('Etapa: EN_COCINA'), findsOneWidget);
    });

    testWidgets('DELIVERY full flow: browse -> cart -> delivery -> review -> submit', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final FakeOrdersRepository ordersRepo = FakeOrdersRepository();
      await tester.pumpWidget(
        CustomerApp(
          environment: environment,
          authRepository: FakeAuthRepository(refreshResult: registeredSession()),
          sessionStore: MemoryAuthSessionStore(session: registeredSession()),
          catalogRepository: FakeCatalogRepository(),
          tablesRepository: FakeTablesRepository(),
          ordersRepository: ordersRepo,
          paymentStatusRepository: FakePaymentStatusRepository(),
          orderTrackingRepository: FakeOrderTrackingRepository(orders: const <OrderSnapshot>[]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('catalog-product-$productOneId')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('product-add-to-cart')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cart-continue')));
      await tester.pumpAndSettle();

      // Elegir DELIVERY
      await tester.tap(find.byKey(const Key('fulfillment-mode-delivery')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-delivery-details')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('delivery-address')), 'Av. Javier Prado 1234');
      await tester.enterText(find.byKey(const Key('delivery-contact-name')), 'Carlos Mendoza');
      await tester.enterText(find.byKey(const Key('delivery-contact-phone')), '999888777');
      await tester.tap(find.byKey(const Key('delivery-finish')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-review')), findsOneWidget);
      expect(find.textContaining('Av. Javier Prado 1234'), findsOneWidget);

      await tester.tap(find.byKey(const Key('order-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-submitted')), findsOneWidget);
      expect(ordersRepo.createCommands.single.fulfillment.mode, FulfillmentMode.delivery);
    });

    testWidgets('Order submission exception and retry flow: error -> screen 18 -> retry succeeds', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final FakeOrdersRepository ordersRepo = FakeOrdersRepository();
      ordersRepo.createError = const OrderFailure(
        OrderFailureKind.network,
        'Sin conexión al servidor. Inténtalo de nuevo.',
      );

      await tester.pumpWidget(
        CustomerApp(
          environment: environment,
          authRepository: FakeAuthRepository(refreshResult: registeredSession()),
          sessionStore: MemoryAuthSessionStore(session: registeredSession()),
          catalogRepository: FakeCatalogRepository(),
          tablesRepository: FakeTablesRepository(),
          ordersRepository: ordersRepo,
          paymentStatusRepository: FakePaymentStatusRepository(),
          orderTrackingRepository: FakeOrderTrackingRepository(orders: const <OrderSnapshot>[]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-menu')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('catalog-product-$productOneId')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('product-add-to-cart')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cart-continue')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('fulfillment-mode-pickup')));
      await tester.pumpAndSettle();

      final Finder textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Carlos Mendoza');
      await tester.enterText(textFields.at(1), '987654321');
      await tester.tap(find.byKey(const Key('pickup-finish')));
      await tester.pumpAndSettle();

      // Submit con error de red
      await tester.tap(find.byKey(const Key('order-submit')));
      await tester.pumpAndSettle();

      // Debe abrir la pantalla 18 de excepciones
      expect(find.byKey(const Key('page-order-exception')), findsOneWidget);
      expect(find.textContaining('Sin conexión al servidor'), findsOneWidget);

      // Ahora restauramos el repo para que el reintento tenga éxito
      ordersRepo.createError = null;
      await tester.tap(find.byKey(const Key('order-exception-connection')));
      await tester.pumpAndSettle();

      // Reintento exitoso lleva a order submitted
      expect(find.byKey(const Key('page-order-submitted')), findsOneWidget);
    });
  });
}
