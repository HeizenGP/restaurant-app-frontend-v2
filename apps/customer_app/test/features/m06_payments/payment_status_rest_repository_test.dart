import 'dart:convert';

import 'package:customer_app/features/m06_payments/view_payment_status/application/payment_status_contracts.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/domain/payment_models.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/infrastructure/payment_status_rest_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final Uri baseUri = Uri.parse('http://example.com/api/v1');

  group('PaymentStatusRestRepository.getAdvance', () {
    test('successful 200 returns AdvanceSummary sending Authorization header', () async {
      late http.Request sentRequest;
      final MockClient client = MockClient((http.Request request) async {
        sentRequest = request;
        return http.Response(
          jsonEncode(<String, Object?>{
            'order_id': 'ord-1',
            'order_status': 'REQUESTED',
            'total_amount': '50.00',
            'required_amount': '25.00',
            'verified_amount': '0.00',
            'remaining_amount': '25.00',
            'verified_at': null,
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      final AdvanceSummary result = await repo.getAdvance(
        'ord-1',
        accessToken: 'token-abc',
      );

      expect(result.orderId, 'ord-1');
      expect(result.totalAmount, '50.00');
      expect(sentRequest.url.toString(), 'http://example.com/api/v1/orders/ord-1/advance');
      expect(sentRequest.headers['authorization'], 'Bearer token-abc');
      expect(sentRequest.headers['accept'], 'application/json');
    });

    test('401 throws unauthorized failure', () async {
      final MockClient client = MockClient((_) async => http.Response('Unauthorized', 401));
      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      expect(
        () => repo.getAdvance('ord-1', accessToken: 'token-abc'),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.unauthorized,
          ),
        ),
      );
    });

    test('403 throws forbidden failure', () async {
      final MockClient client = MockClient((_) async => http.Response('Forbidden', 403));
      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      expect(
        () => repo.getAdvance('ord-1', accessToken: 'token-abc'),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.forbidden,
          ),
        ),
      );
    });

    test('404 throws notFound failure', () async {
      final MockClient client = MockClient((_) async => http.Response('Not Found', 404));
      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      expect(
        () => repo.getAdvance('ord-1', accessToken: 'token-abc'),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.notFound,
          ),
        ),
      );
    });

    test('409 throws conflict failure', () async {
      final MockClient client = MockClient((_) async => http.Response('Conflict', 409));
      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      expect(
        () => repo.getAdvance('ord-1', accessToken: 'token-abc'),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.conflict,
          ),
        ),
      );
    });

    test('500 throws server failure', () async {
      final MockClient client = MockClient((_) async => http.Response('Error', 500));
      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      expect(
        () => repo.getAdvance('ord-1', accessToken: 'token-abc'),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.server,
          ),
        ),
      );
    });

    test('empty orderId or empty token throws validation/unauthorized', () async {
      final MockClient client = MockClient((_) async => http.Response('OK', 200));
      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      expect(
        () => repo.getAdvance('   ', accessToken: 'token'),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.validation,
          ),
        ),
      );

      expect(
        () => repo.getAdvance('ord-1', accessToken: ''),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.unauthorized,
          ),
        ),
      );
    });
  });

  group('PaymentStatusRestRepository.getPayments', () {
    test('successful 200 returns PaymentSummary', () async {
      final MockClient client = MockClient((_) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'order_id': 'ord-1',
            'order_status': 'REQUESTED',
            'total_amount': '50.00',
            'paid_amount': '0.00',
            'balance': '50.00',
            'payment_status': 'UNPAID',
            'payments': <Object?>[],
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final PaymentStatusRestRepository repo = PaymentStatusRestRepository(
        baseUri: baseUri,
        client: client,
      );

      final PaymentSummary summary = await repo.getPayments(
        'ord-1',
        accessToken: 'token-abc',
      );

      expect(summary.orderId, 'ord-1');
      expect(summary.paymentStatus, 'UNPAID');
      expect(summary.payments, isEmpty);
    });
  });
}
