import 'package:customer_app/features/m06_payments/view_payment_status/application/payment_status_contracts.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/domain/payment_models.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/infrastructure/payment_status_json_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentStatusJsonMapper.decodeAdvance', () {
    test('decodes unverified advance summary correctly', () {
      final Map<String, Object?> payload = <String, Object?>{
        'order_id': '00000000-0000-4000-8000-000000000201',
        'order_status': 'REQUESTED',
        'total_amount': '45.00',
        'required_amount': '22.50',
        'verified_amount': '0.00',
        'remaining_amount': '22.50',
        'verified_at': null,
      };

      final AdvanceSummary summary = PaymentStatusJsonMapper.decodeAdvance(payload);
      expect(summary.orderId, '00000000-0000-4000-8000-000000000201');
      expect(summary.orderStatus, 'REQUESTED');
      expect(summary.totalAmount, '45.00');
      expect(summary.requiredAmount, '22.50');
      expect(summary.verifiedAmount, '0.00');
      expect(summary.remainingAmount, '22.50');
      expect(summary.verifiedAt, isNull);
      expect(summary.isVerified, isFalse);
    });

    test('decodes verified advance summary with ISO timestamp', () {
      final Map<String, Object?> payload = <String, Object?>{
        'order_id': '00000000-0000-4000-8000-000000000201',
        'order_status': 'CONFIRMED',
        'total_amount': '50.00',
        'required_amount': '25.00',
        'verified_amount': '25.00',
        'remaining_amount': '0.00',
        'verified_at': '2026-10-24T18:00:00Z',
      };

      final AdvanceSummary summary = PaymentStatusJsonMapper.decodeAdvance(payload);
      expect(summary.isVerified, isTrue);
      expect(summary.verifiedAt, DateTime.utc(2026, 10, 24, 18));
      expect(summary.verifiedAmount, '25.00');
    });

    test('throws malformedResponse when advance payload is not a Map or missing fields', () {
      expect(
        () => PaymentStatusJsonMapper.decodeAdvance('not a map'),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.malformedResponse,
          ),
        ),
      );

      expect(
        () => PaymentStatusJsonMapper.decodeAdvance(<String, Object?>{
          'order_id': '123',
          // missing total_amount, etc.
        }),
        throwsA(isA<PaymentStatusFailure>()),
      );
    });
  });

  group('PaymentStatusJsonMapper.decodePayments', () {
    test('decodes payment summary with payments list', () {
      final Map<String, Object?> payload = <String, Object?>{
        'order_id': '00000000-0000-4000-8000-000000000201',
        'order_status': 'REQUESTED',
        'total_amount': '45.00',
        'paid_amount': '22.50',
        'balance': '22.50',
        'payment_status': 'PARTIAL',
        'payments': <Object?>[
          <String, Object?>{
            'id': 'pay-1',
            'kind': 'ADVANCE',
            'amount': '22.50',
            'method_code': 'YAPE',
            'reference_code': 'REF-123',
            'recorded_by_user_id': 'user-admin',
            'recorded_at': '2026-10-24T17:00:00Z',
          },
        ],
      };

      final PaymentSummary summary = PaymentStatusJsonMapper.decodePayments(payload);
      expect(summary.orderId, '00000000-0000-4000-8000-000000000201');
      expect(summary.paymentStatus, 'PARTIAL');
      expect(summary.payments.length, 1);
      final PaymentRecord first = summary.payments.first;
      expect(first.id, 'pay-1');
      expect(first.kind, 'ADVANCE');
      expect(first.amount, '22.50');
      expect(first.methodCode, 'YAPE');
      expect(first.referenceCode, 'REF-123');
      expect(first.recordedByUserId, 'user-admin');
    });

    test('rejects unexpected payment status or invalid kind', () {
      final Map<String, Object?> invalidStatus = <String, Object?>{
        'order_id': '123',
        'order_status': 'REQUESTED',
        'total_amount': '45.00',
        'paid_amount': '0.00',
        'balance': '45.00',
        'payment_status': 'UNKNOWN',
        'payments': <Object?>[],
      };

      expect(
        () => PaymentStatusJsonMapper.decodePayments(invalidStatus),
        throwsA(
          isA<PaymentStatusFailure>().having(
            (PaymentStatusFailure f) => f.kind,
            'kind',
            PaymentStatusFailureKind.malformedResponse,
          ),
        ),
      );
    });
  });
}
