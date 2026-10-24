import 'package:customer_app/features/m06_payments/view_payment_status/application/payment_status_contracts.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/application/payment_status_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/payment_fakes.dart';

void main() {
  group('PaymentStatusController', () {
    test('loadAdvance updates phase to ready when successful', () async {
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository(
        advanceResponse: fakeAdvanceSummary(orderId: 'ord-1', totalAmount: '60.00'),
      );
      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => 'valid-token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool result = await controller.loadAdvance('ord-1');
      expect(result, isTrue);
      expect(controller.state.phase, PaymentStatusPhase.ready);
      expect(controller.state.view, PaymentStatusView.advance);
      expect(controller.state.advance?.totalAmount, '60.00');
      expect(repo.advanceOrderIds, <String>['ord-1']);
      expect(repo.advanceTokens, <String>['valid-token']);
    });

    test('loadPayments updates phase to ready when successful', () async {
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository(
        paymentResponse: fakePaymentSummary(orderId: 'ord-1', paymentStatus: 'PAID'),
      );
      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => 'valid-token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool result = await controller.loadPayments('ord-1');
      expect(result, isTrue);
      expect(controller.state.phase, PaymentStatusPhase.ready);
      expect(controller.state.view, PaymentStatusView.payments);
      expect(controller.state.paymentSummary?.paymentStatus, 'PAID');
    });

    test('refreshes token once on 401 unauthorized and succeeds on retry', () async {
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository();
      var currentToken = 'expired-token';

      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => currentToken,
        refreshAccessToken: () async {
          currentToken = 'fresh-token';
          return true;
        },
      );
      addTearDown(controller.dispose);

      repo.advanceResponse = fakeAdvanceSummary(orderId: 'ord-1');
      // On first call throw 401
      repo.advanceError = const PaymentStatusFailure(
        PaymentStatusFailureKind.unauthorized,
        'Unauthorized',
      );

      // But when token is refreshed, succeed
      // We can mock that by checking token in repo or clear error after first call
      int refreshCalls = 0;
      final PaymentStatusController controllerWithRefresher = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => currentToken,
        refreshAccessToken: () async {
          refreshCalls += 1;
          currentToken = 'fresh-token';
          repo.advanceError = null; // clear error so retry succeeds
          return true;
        },
      );
      addTearDown(controllerWithRefresher.dispose);

      final bool result = await controllerWithRefresher.loadAdvance('ord-1');
      expect(result, isTrue);
      expect(refreshCalls, 1);
      expect(controllerWithRefresher.state.phase, PaymentStatusPhase.ready);
    });

    test('fails safely with validation when orderId is empty', () async {
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository();
      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      final bool result = await controller.loadAdvance('  ');
      expect(result, isFalse);
      expect(controller.state.phase, PaymentStatusPhase.failure);
      expect(controller.state.failure?.kind, PaymentStatusFailureKind.validation);
    });

    test('retry re-attempts the failed operation when safe', () async {
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository();
      repo.advanceError = const PaymentStatusFailure(
        PaymentStatusFailureKind.network,
        'Network error',
      );

      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      addTearDown(controller.dispose);

      await controller.loadAdvance('ord-1');
      expect(controller.state.phase, PaymentStatusPhase.failure);
      expect(controller.state.canRetry, isTrue);

      // Fix network and retry
      repo.advanceError = null;
      final bool retryResult = await controller.retry();
      expect(retryResult, isTrue);
      expect(controller.state.phase, PaymentStatusPhase.ready);
    });
  });
}
