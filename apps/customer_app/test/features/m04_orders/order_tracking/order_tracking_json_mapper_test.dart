import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/order_tracking/domain/order_tracking_models.dart';
import 'package:customer_app/features/m04_orders/order_tracking/infrastructure/order_tracking_json_mapper.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderTrackingJsonMapper.decodeOrdersList', () {
    test('decodes valid list of orders', () {
      final List<Object?> payload = <Object?>[
        <String, Object?>{
          'id': 'ord-1',
          'modality': 'LOCAL',
          'channel': 'APP',
          'status': 'REQUESTED',
          'table_id': 'tbl-1',
          'delivery_address': null,
          'contact_name': null,
          'contact_phone': null,
          'total_amount': '30.00',
          'lines': <Object?>[
            <String, Object?>{
              'product_id': 'prod-1',
              'product_name_snapshot': 'Chaufa',
              'quantity': 1,
              'unit_price_snapshot': '30.00',
            },
          ],
          'created_at': '2026-10-24T18:00:00Z',
          'decided_at': null,
          'table_verified_at': null,
        },
      ];

      final List<OrderSnapshot> orders =
          OrderTrackingJsonMapper.decodeOrdersList(payload);
      expect(orders.length, 1);
      expect(orders.first.id, 'ord-1');
      expect(orders.first.modality, FulfillmentMode.local);
      expect(orders.first.status, 'REQUESTED');
      expect(orders.first.totalAmount, '30.00');
    });

    test('throws malformedResponse if payload is not a list', () {
      expect(
        () => OrderTrackingJsonMapper.decodeOrdersList('not a list'),
        throwsA(
          isA<OrderFailure>().having(
            (OrderFailure f) => f.kind,
            'kind',
            OrderFailureKind.malformedResponse,
          ),
        ),
      );
    });
  });

  group('OrderTrackingJsonMapper.decodeTracking', () {
    test('decodes complete tracking response', () {
      final Map<String, Object?> payload = <String, Object?>{
        'order_id': 'ord-1',
        'modality': 'DELIVERY',
        'order_status': 'CONFIRMED',
        'stage': 'EN_COCINA',
        'kitchen_status': 'PREPARING',
        'fulfillment_kind': null,
        'total_amount': '50.00',
        'paid_amount': '25.00',
        'balance': '25.00',
        'payment_status': 'PARTIAL',
        'created_at': '2026-10-24T18:00:00Z',
        'kitchen_started_at': '2026-10-24T18:05:00Z',
        'kitchen_ready_at': null,
        'fulfilled_at': null,
        'closed_at': null,
      };

      final OrderTrackingSnapshot tracking =
          OrderTrackingJsonMapper.decodeTracking(payload);
      expect(tracking.orderId, 'ord-1');
      expect(tracking.modality, FulfillmentMode.delivery);
      expect(tracking.orderStatus, 'CONFIRMED');
      expect(tracking.stage, 'EN_COCINA');
      expect(tracking.kitchenStatus, 'PREPARING');
      expect(tracking.fulfillmentKind, isNull);
      expect(tracking.totalAmount, '50.00');
      expect(tracking.paidAmount, '25.00');
      expect(tracking.balance, '25.00');
      expect(tracking.paymentStatus, 'PARTIAL');
      expect(tracking.isPaid, isFalse);
      expect(tracking.hasBalance, isTrue);
      expect(tracking.kitchenStartedAt, DateTime.utc(2026, 10, 24, 18, 5));
    });

    test('throws malformedResponse if payload is invalid', () {
      expect(
        () => OrderTrackingJsonMapper.decodeTracking(<String, Object?>{
          'order_id': 'ord-1',
          // missing modality, stage, etc.
        }),
        throwsA(isA<OrderFailure>()),
      );
    });
  });
}
