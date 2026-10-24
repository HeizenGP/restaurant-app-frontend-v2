import 'package:customer_app/features/m04_orders/order_tracking/application/order_history_controller.dart';
import 'package:customer_app/features/m04_orders/order_tracking/domain/order_tracking_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/order_tracking_fakes.dart';

void main() {
  group('OrderHistoryController', () {
    test('loadOrders populates state and applies filters', () async {
      final List<OrderSnapshot> mockOrders = <OrderSnapshot>[
        fakeOrderSnapshot(id: 'ord-req', status: 'REQUESTED'),
        fakeOrderSnapshot(id: 'ord-app', status: 'APPROVED'),
        fakeOrderSnapshot(id: 'ord-conf', status: 'CONFIRMED'),
        fakeOrderSnapshot(id: 'ord-close', status: 'CLOSED'),
      ];

      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository(
        orders: mockOrders,
      );

      final OrderHistoryController controller = OrderHistoryController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool loaded = await controller.loadOrders();
      expect(loaded, isTrue);
      expect(controller.state.phase, OrderHistoryPhase.ready);
      expect(controller.state.orders.length, 4);

      // Default filter 'all'
      expect(controller.state.filteredOrders.length, 4);

      // Filter 'pending'
      controller.setFilter(OrderHistoryFilter.pending);
      expect(controller.state.filteredOrders.length, 2);
      expect(
        controller.state.filteredOrders.map((OrderSnapshot o) => o.id),
        <String>['ord-req', 'ord-app'],
      );

      // Filter 'confirmed'
      controller.setFilter(OrderHistoryFilter.confirmed);
      expect(controller.state.filteredOrders.length, 2);
      expect(
        controller.state.filteredOrders.map((OrderSnapshot o) => o.id),
        <String>['ord-conf', 'ord-close'],
      );
    });

    test('refreshes token once on 401', () async {
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository();
      int refreshCount = 0;
      repo.listError = const OrderFailure(
        OrderFailureKind.unauthorized,
        'Unauthorized',
      );

      final OrderHistoryController controller = OrderHistoryController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async {
          refreshCount += 1;
          repo.listError = null;
          return true;
        },
      );
      addTearDown(controller.dispose);

      final bool loaded = await controller.loadOrders();
      expect(loaded, isTrue);
      expect(refreshCount, 1);
      expect(controller.state.phase, OrderHistoryPhase.ready);
    });

    test('failure allows safe retry when network error occurs', () async {
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository();
      repo.listError = const OrderFailure(
        OrderFailureKind.network,
        'Network error',
      );

      final OrderHistoryController controller = OrderHistoryController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool loaded = await controller.loadOrders();
      expect(loaded, isFalse);
      expect(controller.state.phase, OrderHistoryPhase.failure);
      expect(controller.state.canRetry, isTrue);

      repo.listError = null;
      final bool retried = await controller.retry();
      expect(retried, isTrue);
      expect(controller.state.phase, OrderHistoryPhase.ready);
    });
  });
}
