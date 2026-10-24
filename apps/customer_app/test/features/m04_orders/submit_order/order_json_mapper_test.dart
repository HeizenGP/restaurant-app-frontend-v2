import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/infrastructure/order_json_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderJsonMapper.encodeCreate', () {
    test('encodes only the backend fields required for local service', () {
      final CreateOrderCommand command = CreateOrderCommand(
        items: const <CreateOrderItem>[
          CreateOrderItem(productId: 'product-1', quantity: 2),
        ],
        fulfillment: FulfillmentDraft.local(tableId: ' table-1 '),
      );

      expect(OrderJsonMapper.encodeCreate(command), <String, Object?>{
        'modality': 'LOCAL',
        'items': <Object?>[
          <String, Object?>{'product_id': 'product-1', 'quantity': 2},
        ],
        'table_id': 'table-1',
        'delivery_address': null,
        'contact_name': null,
        'contact_phone': null,
      });
    });

    test(
      'encodes pickup contact without table, address, channel or totals',
      () {
        final CreateOrderCommand command = CreateOrderCommand(
          items: const <CreateOrderItem>[
            CreateOrderItem(productId: 'product-1', quantity: 1),
          ],
          fulfillment: FulfillmentDraft.pickup(
            contactName: ' Rosa ',
            contactPhone: ' 999 000 ',
          ),
        );

        expect(OrderJsonMapper.encodeCreate(command), <String, Object?>{
          'modality': 'PICKUP',
          'items': <Object?>[
            <String, Object?>{'product_id': 'product-1', 'quantity': 1},
          ],
          'table_id': null,
          'delivery_address': null,
          'contact_name': 'Rosa',
          'contact_phone': '999 000',
        });
      },
    );

    test(
      'encodes delivery address and contact without client-side amounts',
      () {
        final CreateOrderCommand command = CreateOrderCommand(
          items: const <CreateOrderItem>[
            CreateOrderItem(productId: 'product-1', quantity: 3),
          ],
          fulfillment: FulfillmentDraft.delivery(
            deliveryAddress: ' Av. Asia 10 ',
            contactName: ' Luis ',
            contactPhone: ' 988 ',
          ),
        );

        final Map<String, Object?> payload = OrderJsonMapper.encodeCreate(
          command,
        );

        expect(payload, <String, Object?>{
          'modality': 'DELIVERY',
          'items': <Object?>[
            <String, Object?>{'product_id': 'product-1', 'quantity': 3},
          ],
          'table_id': null,
          'delivery_address': 'Av. Asia 10',
          'contact_name': 'Luis',
          'contact_phone': '988',
        });
        expect(payload, isNot(contains('channel')));
        expect(payload, isNot(contains('total_amount')));
        expect(payload, isNot(contains('unit_price')));
      },
    );

    test('consolidates duplicate products into a canonical sorted payload', () {
      final CreateOrderCommand first = CreateOrderCommand(
        items: const <CreateOrderItem>[
          CreateOrderItem(productId: ' product-b ', quantity: 1),
          CreateOrderItem(productId: 'product-a', quantity: 2),
          CreateOrderItem(productId: 'product-b', quantity: 3),
        ],
        fulfillment: FulfillmentDraft.local(tableId: 'table-1'),
      );
      final CreateOrderCommand sameLogicalPayload = CreateOrderCommand(
        items: const <CreateOrderItem>[
          CreateOrderItem(productId: 'product-b', quantity: 4),
          CreateOrderItem(productId: 'product-a', quantity: 2),
        ],
        fulfillment: FulfillmentDraft.local(tableId: 'table-1'),
      );

      expect(first, sameLogicalPayload);
      expect(OrderJsonMapper.encodeCreate(first)['items'], <Object?>[
        <String, Object?>{'product_id': 'product-a', 'quantity': 2},
        <String, Object?>{'product_id': 'product-b', 'quantity': 4},
      ]);
    });

    test('rejects a consolidated quantity above the backend integer limit', () {
      expect(
        () => CreateOrderCommand(
          items: const <CreateOrderItem>[
            CreateOrderItem(productId: 'product-1', quantity: 2147483647),
            CreateOrderItem(productId: 'product-1', quantity: 1),
          ],
          fulfillment: FulfillmentDraft.local(tableId: 'table-1'),
        ),
        throwsArgumentError,
      );
    });

    test('rejects modality data that violates the backend contract', () {
      final List<FulfillmentDraft> invalidDrafts = <FulfillmentDraft>[
        FulfillmentDraft.local(tableId: ' '),
        FulfillmentDraft.pickup(contactName: ' ', contactPhone: '999'),
        FulfillmentDraft.pickup(contactName: 'Rosa', contactPhone: '9' * 31),
        FulfillmentDraft.delivery(
          deliveryAddress: ' ',
          contactName: 'Rosa',
          contactPhone: '999',
        ),
        FulfillmentDraft.delivery(
          deliveryAddress: 'a' * 1001,
          contactName: 'Rosa',
          contactPhone: '999',
        ),
      ];

      for (final FulfillmentDraft fulfillment in invalidDrafts) {
        expect(
          () => CreateOrderCommand(
            items: const <CreateOrderItem>[
              CreateOrderItem(productId: 'product-1', quantity: 1),
            ],
            fulfillment: fulfillment,
          ),
          throwsArgumentError,
        );
      }
    });
  });

  group('OrderJsonMapper.decodeOrder', () {
    test(
      'maps the immutable backend snapshot without parsing money as double',
      () {
        final OrderSnapshot order = OrderJsonMapper.decodeOrder(
          _responsePayload(status: 'REQUESTED'),
        );

        expect(order.id, '11111111-1111-4111-8111-111111111111');
        expect(order.modality, FulfillmentMode.delivery);
        expect(order.channel, 'APP');
        expect(order.status, 'REQUESTED');
        expect(order.deliveryAddress, 'Av. Asia 10');
        expect(order.totalAmount, '24.50');
        expect(order.totalAmount, isA<String>());
        expect(order.lines, hasLength(1));
        expect(order.lines.single.unitPrice, '12.25');
        expect(order.createdAt, DateTime.parse('2026-10-24T15:30:00Z'));
        expect(order.decidedAt, isNull);
        expect(order.tableVerifiedAt, isNull);
        expect(order.isRequested, isTrue);
      },
    );

    test('keeps an unknown future status as safe display data', () {
      final OrderSnapshot order = OrderJsonMapper.decodeOrder(
        _responsePayload(status: 'FUTURE_STATUS'),
      );

      expect(order.status, 'FUTURE_STATUS');
      expect(order.isRequested, isFalse);
    });

    test('rejects malformed decimals, lines and required nullable fields', () {
      final Map<String, Object?> numericAmount = _responsePayload()
        ..['total_amount'] = 24.5;
      final Map<String, Object?> emptyLines = _responsePayload()
        ..['lines'] = <Object?>[];
      final Map<String, Object?> missingNullable = _responsePayload()
        ..remove('decided_at');

      for (final Map<String, Object?> payload in <Map<String, Object?>>[
        numericAmount,
        emptyLines,
        missingNullable,
      ]) {
        expect(
          () => OrderJsonMapper.decodeOrder(payload),
          throwsA(
            isA<OrderFailure>().having(
              (OrderFailure value) => value.kind,
              'kind',
              OrderFailureKind.malformedResponse,
            ),
          ),
        );
      }
    });

    test('does not expose malformed response internals', () {
      expect(
        () => OrderJsonMapper.decodeOrder(<String, Object?>{
          'private_database_value': 'secret',
        }),
        throwsA(
          isA<OrderFailure>()
              .having(
                (OrderFailure value) => value.kind,
                'kind',
                OrderFailureKind.malformedResponse,
              )
              .having(
                (OrderFailure value) => value.message,
                'message',
                isNot(contains('secret')),
              ),
        ),
      );
    });
  });
}

Map<String, Object?> _responsePayload({String status = 'REQUESTED'}) {
  return <String, Object?>{
    'id': '11111111-1111-4111-8111-111111111111',
    'modality': 'DELIVERY',
    'channel': 'APP',
    'status': status,
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
