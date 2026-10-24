import 'dart:convert';

import 'package:customer_app/features/m04_orders/order_tracking/domain/order_tracking_models.dart';
import 'package:customer_app/features/m04_orders/order_tracking/infrastructure/order_tracking_rest_repository.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final Uri baseUri = Uri.parse('http://example.com/api/v1');

  group('OrderTrackingRestRepository', () {
    test('listOrders sends GET /orders with Bearer token and returns orders', () async {
      late http.Request capturedRequest;
      final MockClient client = MockClient((http.Request request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(<Object?>[
            <String, Object?>{
              'id': 'ord-1',
              'modality': 'LOCAL',
              'channel': 'APP',
              'status': 'REQUESTED',
              'table_id': 'tbl-1',
              'delivery_address': null,
              'contact_name': null,
              'contact_phone': null,
              'total_amount': '25.00',
              'lines': <Object?>[
                <String, Object?>{
                  'product_id': 'prod-1',
                  'product_name_snapshot': 'Chaufa',
                  'quantity': 1,
                  'unit_price_snapshot': '25.00',
                },
              ],
              'created_at': '2026-10-24T18:00:00Z',
              'decided_at': null,
              'table_verified_at': null,
            },
          ]),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final OrderTrackingRestRepository repo = OrderTrackingRestRepository(
        baseUri: baseUri,
        client: client,
      );

      final List<OrderSnapshot> orders =
          await repo.listOrders(accessToken: 'test-token');
      expect(orders.length, 1);
      expect(orders.first.id, 'ord-1');
      expect(capturedRequest.url.toString(), 'http://example.com/api/v1/orders');
      expect(capturedRequest.headers['authorization'], 'Bearer test-token');
    });

    test('getOrder sends GET /orders/{id}', () async {
      final MockClient client = MockClient((http.Request request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'id': 'ord-1',
            'modality': 'PICKUP',
            'channel': 'APP',
            'status': 'CONFIRMED',
            'table_id': null,
            'delivery_address': null,
            'contact_name': 'Juan',
            'contact_phone': null,
            'total_amount': '40.00',
            'lines': <Object?>[
              <String, Object?>{
                'product_id': 'prod-1',
                'product_name_snapshot': 'Tallarin',
                'quantity': 2,
                'unit_price_snapshot': '20.00',
              },
            ],
            'created_at': '2026-10-24T18:00:00Z',
            'decided_at': null,
            'table_verified_at': null,
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final OrderTrackingRestRepository repo = OrderTrackingRestRepository(
        baseUri: baseUri,
        client: client,
      );

      final OrderSnapshot order =
          await repo.getOrder('ord-1', accessToken: 'test-token');
      expect(order.id, 'ord-1');
      expect(order.totalAmount, '40.00');
    });

    test('getTracking sends GET /orders/{id}/tracking', () async {
      late http.Request capturedRequest;
      final MockClient client = MockClient((http.Request request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(<String, Object?>{
            'order_id': 'ord-1',
            'modality': 'LOCAL',
            'order_status': 'CONFIRMED',
            'stage': 'EN_COCINA',
            'kitchen_status': 'PREPARING',
            'fulfillment_kind': null,
            'total_amount': '30.00',
            'paid_amount': '30.00',
            'balance': '0.00',
            'payment_status': 'PAID',
            'created_at': '2026-10-24T18:00:00Z',
            'kitchen_started_at': '2026-10-24T18:05:00Z',
            'kitchen_ready_at': null,
            'fulfilled_at': null,
            'closed_at': null,
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });

      final OrderTrackingRestRepository repo = OrderTrackingRestRepository(
        baseUri: baseUri,
        client: client,
      );

      final OrderTrackingSnapshot tracking =
          await repo.getTracking('ord-1', accessToken: 'test-token');
      expect(tracking.orderId, 'ord-1');
      expect(tracking.stage, 'EN_COCINA');
      expect(capturedRequest.url.toString(), 'http://example.com/api/v1/orders/ord-1/tracking');
    });

    test('401, 403, 404, 500 error mapping', () async {
      for (final (int code, OrderFailureKind kind) in <(int, OrderFailureKind)>[
        (401, OrderFailureKind.unauthorized),
        (403, OrderFailureKind.forbidden),
        (404, OrderFailureKind.notFound),
        (500, OrderFailureKind.server),
      ]) {
        final MockClient client =
            MockClient((_) async => http.Response('Error', code));
        final OrderTrackingRestRepository repo = OrderTrackingRestRepository(
          baseUri: baseUri,
          client: client,
        );

        expect(
          () => repo.listOrders(accessToken: 'token'),
          throwsA(
            isA<OrderFailure>().having((OrderFailure f) => f.kind, 'kind', kind),
          ),
        );
      }
    });
  });
}
