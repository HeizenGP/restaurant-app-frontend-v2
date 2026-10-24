import 'package:customer_app/features/m04_orders/order_tracking/application/order_tracking_controller.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/order_tracking_fakes.dart';

void main() {
  group('OrderTrackingController', () {
    test('load populates order and tracking when successful', () async {
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository(
        order: fakeOrderSnapshot(id: 'ord-123', totalAmount: '35.00'),
        tracking: fakeTrackingSnapshot(orderId: 'ord-123', stage: 'EN_COCINA'),
      );

      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool loaded = await controller.load('ord-123');
      expect(loaded, isTrue);
      expect(controller.state.phase, OrderTrackingPhase.ready);
      expect(controller.state.order?.id, 'ord-123');
      expect(controller.state.order?.totalAmount, '35.00');
      expect(controller.state.tracking?.stage, 'EN_COCINA');
    });

    test('load fails with validation on empty orderId', () async {
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository();
      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool loaded = await controller.load('   ');
      expect(loaded, isFalse);
      expect(controller.state.phase, OrderTrackingPhase.failure);
      expect(controller.state.failure?.kind, OrderFailureKind.validation);
    });

    test('refreshes token once on 401', () async {
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository();
      int refreshCount = 0;
      repo.orderError = const OrderFailure(
        OrderFailureKind.unauthorized,
        'Unauthorized',
      );

      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async {
          refreshCount += 1;
          repo.orderError = null;
          return true;
        },
      );
      addTearDown(controller.dispose);

      final bool loaded = await controller.load('ord-123');
      expect(loaded, isTrue);
      expect(refreshCount, 1);
      expect(controller.state.phase, OrderTrackingPhase.ready);
    });

    test('retry re-attempts load after network failure', () async {
      final FakeOrderTrackingRepository repo = FakeOrderTrackingRepository();
      repo.trackingError = const OrderFailure(
        OrderFailureKind.network,
        'Network error',
      );

      final OrderTrackingController controller = OrderTrackingController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool loaded = await controller.load('ord-123');
      expect(loaded, isFalse);
      expect(controller.state.phase, OrderTrackingPhase.failure);
      expect(controller.state.canRetry, isTrue);

      repo.trackingError = null;
      final bool retried = await controller.retry();
      expect(retried, isTrue);
      expect(controller.state.phase, OrderTrackingPhase.ready);
    });
  });
}
