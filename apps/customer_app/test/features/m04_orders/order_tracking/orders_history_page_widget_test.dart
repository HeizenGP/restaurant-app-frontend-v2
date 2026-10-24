import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/order_tracking/application/order_history_controller.dart';
import 'package:customer_app/features/m04_orders/order_tracking/presentation/orders_history_page.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/order_tracking_fakes.dart';

void main() {
  group('OrdersHistoryPage', () {
    testWidgets('renders empty state when no orders exist', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository(
        orders: <OrderSnapshot>[],
      );
      final OrderHistoryController controller = OrderHistoryController(
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
          home: OrdersHistoryPage(
            themeModeController: themeController,
            controller: controller,
            onOpenOrderDetail: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-pedidos')), findsOneWidget);
      expect(find.byKey(const Key('filter-all')), findsOneWidget);
      expect(find.byKey(const Key('filter-pending')), findsOneWidget);
      expect(find.byKey(const Key('filter-confirmed')), findsOneWidget);
      expect(find.byKey(const Key('orders-empty-state')), findsOneWidget);
      expect(find.text('Sin pedidos'), findsOneWidget);
    });

    testWidgets('renders order cards and filters interactively', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final List<OrderSnapshot> mockOrders = <OrderSnapshot>[
        fakeOrderSnapshot(id: 'ord-req-1', status: 'REQUESTED'),
        fakeOrderSnapshot(id: 'ord-conf-1', status: 'CONFIRMED'),
      ];
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository(
        orders: mockOrders,
      );
      final OrderHistoryController controller = OrderHistoryController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeController = ThemeModeController();
      String? selectedOrderId;
      addTearDown(() {
        controller.dispose();
        themeController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: OrdersHistoryPage(
            themeModeController: themeController,
            controller: controller,
            onOpenOrderDetail: (String id) => selectedOrderId = id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey<String>('order-card-ord-req-1')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('order-card-ord-conf-1')), findsOneWidget);

      // Tap filter 'Pendientes'
      await tester.tap(find.byKey(const Key('filter-pending')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('order-card-ord-req-1')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('order-card-ord-conf-1')), findsNothing);

      // Tap filter 'Confirmados'
      await tester.tap(find.byKey(const Key('filter-confirmed')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('order-card-ord-req-1')), findsNothing);
      expect(find.byKey(const ValueKey<String>('order-card-ord-conf-1')), findsOneWidget);

      // Tap order card
      await tester.tap(find.byKey(const ValueKey<String>('order-card-ord-conf-1')));
      expect(selectedOrderId, 'ord-conf-1');
    });

    testWidgets('renders error state and retries', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository();
      repo.listError = const OrderFailure(
        OrderFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );
      final OrderHistoryController controller = OrderHistoryController(
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
          home: OrdersHistoryPage(
            themeModeController: themeController,
            controller: controller,
            onOpenOrderDetail: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('orders-error-state')), findsOneWidget);
      expect(find.text('No pudimos cargar pedidos'), findsOneWidget);

      repo.listError = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('orders-empty-state')), findsNothing);
      expect(find.byType(ChifaCard), findsWidgets);
    });
  });
}

Future<void> _configureSurface(WidgetTester tester, [Size size = const Size(390, 844)]) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
