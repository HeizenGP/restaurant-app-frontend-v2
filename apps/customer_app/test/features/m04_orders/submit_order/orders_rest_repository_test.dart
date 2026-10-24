import 'dart:convert';

import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/infrastructure/orders_rest_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String baseUrl = 'https://api.example.test/api/v1';

  test(
    'POSTs the exact create contract with auth and idempotency headers',
    () async {
      late http.Request captured;
      final OrdersRestRepository repository = OrdersRestRepository(
        baseUri: Uri.parse('$baseUrl/'),
        client: MockClient((http.Request request) async {
          captured = request;
          return http.Response(jsonEncode(_responsePayload()), 201);
        }),
      );
      final CreateOrderCommand command = CreateOrderCommand(
        items: const <CreateOrderItem>[
          CreateOrderItem(
            productId: '22222222-2222-4222-8222-222222222222',
            quantity: 2,
          ),
        ],
        fulfillment: FulfillmentDraft.delivery(
          deliveryAddress: 'Av. Asia 10',
          contactName: 'Rosa',
          contactPhone: '999000111',
        ),
      );

      final OrderSnapshot order = await repository.createOrder(
        command,
        accessToken: 'access-token',
        idempotencyKey: 'order-key-1',
      );

      expect(captured.method, 'POST');
      expect(captured.url.toString(), '$baseUrl/orders');
      expect(captured.headers['accept'], 'application/json');
      expect(captured.headers['content-type'], 'application/json');
      expect(captured.headers['authorization'], 'Bearer access-token');
      expect(captured.headers['idempotency-key'], 'order-key-1');
      expect(jsonDecode(captured.body), <String, Object?>{
        'modality': 'DELIVERY',
        'items': <Object?>[
          <String, Object?>{
            'product_id': '22222222-2222-4222-8222-222222222222',
            'quantity': 2,
          },
        ],
        'table_id': null,
        'delivery_address': 'Av. Asia 10',
        'contact_name': 'Rosa',
        'contact_phone': '999000111',
      });
      expect(order.status, 'REQUESTED');
      expect(order.totalAmount, '24.50');
    },
  );

  test(
    'GETs only the owned order detail without an idempotency header',
    () async {
      late http.Request captured;
      final OrdersRestRepository repository = OrdersRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient((http.Request request) async {
          captured = request;
          return http.Response(jsonEncode(_responsePayload()), 200);
        }),
      );

      final OrderSnapshot order = await repository.getOrder(
        ' 11111111-1111-4111-8111-111111111111 ',
        accessToken: 'guest-access-token',
      );

      expect(captured.method, 'GET');
      expect(
        captured.url.toString(),
        '$baseUrl/orders/11111111-1111-4111-8111-111111111111',
      );
      expect(captured.headers['authorization'], 'Bearer guest-access-token');
      expect(captured.headers, isNot(contains('idempotency-key')));
      expect(order.id, '11111111-1111-4111-8111-111111111111');
    },
  );

  test('maps every documented HTTP status to a typed safe failure', () async {
    const Map<int, OrderFailureKind> cases = <int, OrderFailureKind>{
      401: OrderFailureKind.unauthorized,
      403: OrderFailureKind.forbidden,
      404: OrderFailureKind.notFound,
      409: OrderFailureKind.conflict,
      422: OrderFailureKind.validation,
      400: OrderFailureKind.validation,
      500: OrderFailureKind.server,
      503: OrderFailureKind.server,
    };

    for (final MapEntry<int, OrderFailureKind> entry in cases.entries) {
      final OrdersRestRepository repository = OrdersRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient(
          (_) async => http.Response(
            'backend detail must not escape: ${entry.key}',
            entry.key,
          ),
        ),
      );

      await expectLater(
        repository.createOrder(
          _pickupCommand(),
          accessToken: 'token',
          idempotencyKey: 'same-safe-key',
        ),
        throwsA(
          isA<OrderFailure>()
              .having(
                (OrderFailure value) => value.kind,
                'kind for ${entry.key}',
                entry.value,
              )
              .having(
                (OrderFailure value) => value.message,
                'safe message for ${entry.key}',
                isNot(contains('backend detail')),
              ),
        ),
      );
    }
  });

  test(
    'distinguishes product and idempotency conflicts from safe details',
    () async {
      const Map<String, OrderFailureKind> cases = <String, OrderFailureKind>{
        'Product is unavailable for a new request':
            OrderFailureKind.productUnavailable,
        'Idempotency-Key was already used for another request':
            OrderFailureKind.idempotencyConflict,
      };

      for (final MapEntry<String, OrderFailureKind> entry in cases.entries) {
        final OrdersRestRepository repository = OrdersRestRepository(
          baseUri: Uri.parse(baseUrl),
          client: MockClient(
            (_) async => http.Response(
              jsonEncode(<String, Object?>{'detail': entry.key}),
              409,
            ),
          ),
        );

        await expectLater(
          repository.createOrder(
            _pickupCommand(),
            accessToken: 'token',
            idempotencyKey: 'same-safe-key',
          ),
          throwsA(
            isA<OrderFailure>()
                .having((OrderFailure value) => value.kind, 'kind', entry.value)
                .having(
                  (OrderFailure value) => value.message,
                  'safe message',
                  isNot(contains(entry.key)),
                ),
          ),
        );
      }
    },
  );

  test(
    'maps timeout, transport and malformed success responses separately',
    () async {
      final OrdersRestRepository timeoutRepository = OrdersRestRepository(
        baseUri: Uri.parse(baseUrl),
        requestTimeout: const Duration(milliseconds: 1),
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response(jsonEncode(_responsePayload()), 201);
        }),
      );
      final OrdersRestRepository networkRepository = OrdersRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient((_) async => throw Exception('private host detail')),
      );
      final OrdersRestRepository malformedRepository = OrdersRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient((_) async => http.Response('{not-json', 201)),
      );

      Future<OrderSnapshot> create(OrdersRestRepository repository) {
        return repository.createOrder(
          _pickupCommand(),
          accessToken: 'token',
          idempotencyKey: 'safe-key',
        );
      }

      await expectLater(
        create(timeoutRepository),
        throwsA(_failureWithKind(OrderFailureKind.timeout)),
      );
      await expectLater(
        create(networkRepository),
        throwsA(
          isA<OrderFailure>()
              .having(
                (OrderFailure value) => value.kind,
                'kind',
                OrderFailureKind.network,
              )
              .having(
                (OrderFailure value) => value.message,
                'message',
                isNot(contains('private')),
              ),
        ),
      );
      await expectLater(
        create(malformedRepository),
        throwsA(_failureWithKind(OrderFailureKind.malformedResponse)),
      );
    },
  );

  test(
    'rejects invalid credentials, ids and idempotency keys before I/O',
    () async {
      int requests = 0;
      final OrdersRestRepository repository = OrdersRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient((_) async {
          requests += 1;
          return http.Response(jsonEncode(_responsePayload()), 201);
        }),
      );

      await expectLater(
        repository.createOrder(
          _pickupCommand(),
          accessToken: ' ',
          idempotencyKey: 'key',
        ),
        throwsA(_failureWithKind(OrderFailureKind.unauthorized)),
      );
      for (final String key in <String>['', '   ', 'x' * 129]) {
        await expectLater(
          repository.createOrder(
            _pickupCommand(),
            accessToken: 'token',
            idempotencyKey: key,
          ),
          throwsA(_failureWithKind(OrderFailureKind.validation)),
        );
      }
      await expectLater(
        repository.getOrder(' ', accessToken: 'token'),
        throwsA(_failureWithKind(OrderFailureKind.validation)),
      );
      expect(requests, 0);
    },
  );
}

Matcher _failureWithKind(OrderFailureKind kind) {
  return isA<OrderFailure>().having(
    (OrderFailure value) => value.kind,
    'kind',
    kind,
  );
}

CreateOrderCommand _pickupCommand() {
  return CreateOrderCommand(
    items: const <CreateOrderItem>[
      CreateOrderItem(
        productId: '22222222-2222-4222-8222-222222222222',
        quantity: 2,
      ),
    ],
    fulfillment: FulfillmentDraft.pickup(
      contactName: 'Rosa',
      contactPhone: '999000111',
    ),
  );
}

Map<String, Object?> _responsePayload() {
  return <String, Object?>{
    'id': '11111111-1111-4111-8111-111111111111',
    'modality': 'DELIVERY',
    'channel': 'APP',
    'status': 'REQUESTED',
    'table_id': null,
    'delivery_address': 'Av. Asia 10',
    'contact_name': 'Rosa',
    'contact_phone': '999000111',
    'total_amount': '24.50',
    'lines': <Object?>[
      <String, Object?>{
        'product_id': '22222222-2222-4222-8222-222222222222',
        'product_name_snapshot': 'Arroz chaufa',
        'quantity': 2,
        'unit_price_snapshot': '12.25',
      },
    ],
    'created_at': '2026-10-24T15:30:00Z',
    'decided_at': null,
    'table_verified_at': null,
  };
}
