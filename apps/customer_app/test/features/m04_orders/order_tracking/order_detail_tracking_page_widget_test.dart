import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/order_tracking/application/order_tracking_controller.dart';
import 'package:customer_app/features/m04_orders/order_tracking/presentation/order_detail_tracking_page.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/order_tracking_fakes.dart';

void main() {
  group('OrderDetailTrackingPage', () {
    testWidgets('loads and renders tracking and order details', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository(
        order: fakeOrderSnapshot(
          id: 'ord-track-1',
          modality: FulfillmentMode.delivery,
          deliveryAddress: 'Av. Las Begonias 123',
          totalAmount: '48.50',
          lines: const <OrderLineSnapshot>[
            OrderLineSnapshot(
              productId: 'p-1',
              productName: 'Chaufa Especial',
              quantity: 2,
              unitPrice: '24.25',
            ),
          ],
        ),
        tracking: fakeTrackingSnapshot(
          orderId: 'ord-track-1',
          modality: FulfillmentMode.delivery,
          orderStatus: 'CONFIRMED',
          stage: 'EN_COCINA',
          kitchenStatus: 'PREPARING',
          totalAmount: '48.50',
          paidAmount: '24.25',
          balance: '24.25',
          paymentStatus: 'PARTIAL',
        ),
      );

      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeController = ThemeModeController();
      var advanceOpened = false;
      var paymentsOpened = false;
      var backed = false;
      addTearDown(() {
        controller.dispose();
        themeController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: OrderDetailTrackingPage(
            themeModeController: themeController,
            controller: controller,
            orderId: 'ord-track-1',
            onBackToOrders: () => backed = true,
            onViewAdvance: (_) => advanceOpened = true,
            onViewPayments: (_) => paymentsOpened = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-tracking')), findsOneWidget);
      expect(find.byKey(const Key('tracking-stage-card')), findsOneWidget);
      expect(find.textContaining('Etapa: EN_COCINA'), findsOneWidget);
      expect(find.byKey(const Key('tracking-modality-card')), findsOneWidget);
      expect(find.text('Entrega a domicilio'), findsOneWidget);
      expect(find.textContaining('Av. Las Begonias 123'), findsOneWidget);
      expect(find.byKey(const Key('tracking-products-card')), findsOneWidget);
      expect(find.textContaining('Chaufa Especial'), findsOneWidget);
      expect(find.byKey(const Key('tracking-payment-card')), findsOneWidget);
      expect(find.textContaining('Estado de pago: PARTIAL'), findsOneWidget);

      // Verify advance button exists for delivery
      expect(find.byKey(const Key('tracking-advance-button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('tracking-advance-button')));
      expect(advanceOpened, isTrue);

      // Verify payments button
      await tester.tap(find.byKey(const Key('tracking-payments-button')));
      expect(paymentsOpened, isTrue);

      // Verify back button
      await tester.tap(find.byKey(const Key('tracking-back-button')));
      expect(backed, isTrue);
    });

    testWidgets('shows error state and retries', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository();
      repo.orderError = const OrderFailure(
        OrderFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );

      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeController = ThemeModeController();
      addTearDown(() {
        controller.dispose();
        themeController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: OrderDetailTrackingPage(
            themeModeController: themeController,
            controller: controller,
            orderId: 'ord-fail',
            onBackToOrders: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-tracking-error')), findsOneWidget);
      expect(find.text('No pudimos consultar'), findsOneWidget);

      repo.orderError = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-order-tracking')), findsOneWidget);
    });

    testWidgets('opens order breakdown dialog and displays itemized details', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository(
        order: fakeOrderSnapshot(
          id: 'ord-breakdown-1',
          modality: FulfillmentMode.local,
          totalAmount: '35.00',
          lines: const <OrderLineSnapshot>[
            OrderLineSnapshot(
              productId: 'p-1',
              productName: 'Arroz Chaufa',
              quantity: 2,
              unitPrice: '17.50',
            ),
          ],
        ),
        tracking: fakeTrackingSnapshot(
          orderId: 'ord-breakdown-1',
          modality: FulfillmentMode.local,
          orderStatus: 'REQUESTED',
          stage: 'REQUESTED',
          totalAmount: '35.00',
          paidAmount: '0.00',
          balance: '35.00',
          paymentStatus: 'UNPAID',
        ),
      );

      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeController = ThemeModeController();
      addTearDown(() {
        controller.dispose();
        themeController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: OrderDetailTrackingPage(
            themeModeController: themeController,
            controller: controller,
            orderId: 'ord-breakdown-1',
            onBackToOrders: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap products card to open full breakdown
      await tester.tap(find.byKey(const Key('tracking-products-card')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('order-breakdown-dialog')), findsOneWidget);
      expect(find.text('Detalle del pedido'), findsOneWidget);
      expect(find.text('Total a pagar'), findsOneWidget);
      expect(find.text('S/ 35.00'), findsWidgets);
      expect(find.text('Cerrar'), findsOneWidget);

      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('order-breakdown-dialog')), findsNothing);
    });

    testWidgets('allows requesting cancellation with observation', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository(
        order: fakeOrderSnapshot(
          id: 'ord-cancel-1',
          modality: FulfillmentMode.pickup,
          totalAmount: '20.00',
          lines: const <OrderLineSnapshot>[
            OrderLineSnapshot(
              productId: 'p-1',
              productName: 'Tallarín Saltado',
              quantity: 1,
              unitPrice: '20.00',
            ),
          ],
        ),
        tracking: fakeTrackingSnapshot(
          orderId: 'ord-cancel-1',
          modality: FulfillmentMode.pickup,
          orderStatus: 'REQUESTED',
          stage: 'REQUESTED',
          totalAmount: '20.00',
          paidAmount: '0.00',
          balance: '20.00',
          paymentStatus: 'UNPAID',
        ),
      );

      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeController = ThemeModeController();
      addTearDown(() {
        controller.dispose();
        themeController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: OrderDetailTrackingPage(
            themeModeController: themeController,
            controller: controller,
            orderId: 'ord-cancel-1',
            onBackToOrders: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Cancellation button should be visible
      final Finder cancelBtn = find.byKey(const Key('tracking-cancel-button'));
      expect(cancelBtn, findsOneWidget);

      await tester.tap(cancelBtn);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cancellation-dialog')), findsOneWidget);

      // Enter observation
      await tester.enterText(
        find.byKey(const Key('cancellation-reason-input')),
        'Cambio de planes urgente',
      );
      await tester.pump();

      // Confirm cancellation
      await tester.tap(find.byKey(const Key('cancellation-confirm-action')));
      await tester.pumpAndSettle();

      // Verify cancellation card appeared with the observation
      expect(find.byKey(const Key('tracking-cancellation-card')), findsOneWidget);
      expect(find.textContaining('Cambio de planes urgente'), findsOneWidget);
      expect(find.byKey(const Key('tracking-cancel-button')), findsNothing);
    });
  });
}

Future<void> _configureSurface(WidgetTester tester, [Size size = const Size(390, 844)]) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
