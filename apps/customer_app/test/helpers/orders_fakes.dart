import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';

final class FakeOrdersRepository implements OrdersRepository {
  FakeOrdersRepository({OrderSnapshot? response})
    : response = response ?? requestedOrderSnapshot();

  final OrderSnapshot response;
  final List<CreateOrderCommand> createCommands = <CreateOrderCommand>[];
  final List<String> createTokens = <String>[];
  final List<String> idempotencyKeys = <String>[];
  final List<String> detailIds = <String>[];
  final List<String> detailTokens = <String>[];

  @override
  Future<OrderSnapshot> createOrder(
    CreateOrderCommand command, {
    required String accessToken,
    required String idempotencyKey,
  }) async {
    createCommands.add(command);
    createTokens.add(accessToken);
    idempotencyKeys.add(idempotencyKey);
    return response;
  }

  @override
  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  }) async {
    detailIds.add(orderId);
    detailTokens.add(accessToken);
    return response;
  }
}

OrderSnapshot requestedOrderSnapshot({
  String id = '00000000-0000-4000-8000-000000000201',
}) {
  return OrderSnapshot(
    id: id,
    modality: FulfillmentMode.local,
    channel: 'APP',
    status: 'REQUESTED',
    tableId: 'table-1',
    totalAmount: '24.25',
    lines: const <OrderLineSnapshot>[
      OrderLineSnapshot(
        productId: 'product-1',
        productName: 'Arroz chaufa especial',
        quantity: 1,
        unitPrice: '24.25',
      ),
    ],
    createdAt: DateTime.utc(2026, 10, 24, 12),
  );
}
