import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/order_tracking/application/order_tracking_contracts.dart';
import 'package:customer_app/features/m04_orders/order_tracking/domain/order_tracking_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';

final class FakeOrderTrackingRepository implements OrderTrackingRepository {
  FakeOrderTrackingRepository({
    List<OrderSnapshot>? orders,
    OrderSnapshot? order,
    OrderTrackingSnapshot? tracking,
  })  : ordersResponse = orders ?? <OrderSnapshot>[fakeOrderSnapshot()],
        orderResponse = order ?? fakeOrderSnapshot(),
        trackingResponse = tracking ?? fakeTrackingSnapshot();

  List<OrderSnapshot> ordersResponse;
  OrderSnapshot orderResponse;
  OrderTrackingSnapshot trackingResponse;

  final List<String> listTokens = <String>[];
  final List<String> orderIds = <String>[];
  final List<String> trackingIds = <String>[];
  final List<String> cancelTokens = <String>[];
  final List<String> cancelReasons = <String>[];

  Object? listError;
  Object? orderError;
  Object? trackingError;
  Object? cancelError;
  OrderSnapshot? cancelResponse;

  @override
  Future<List<OrderSnapshot>> listOrders({required String accessToken}) async {
    listTokens.add(accessToken);
    if (listError != null) throw listError!;
    return ordersResponse;
  }

  @override
  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  }) async {
    orderIds.add(orderId);
    if (orderError != null) throw orderError!;
    return orderResponse;
  }

  @override
  Future<OrderTrackingSnapshot> getTracking(
    String orderId, {
    required String accessToken,
  }) async {
    trackingIds.add(orderId);
    if (trackingError != null) throw trackingError!;
    return trackingResponse;
  }

  @override
  Future<OrderSnapshot> requestCancellation(
    String orderId, {
    required String reason,
    required String accessToken,
  }) async {
    cancelTokens.add(accessToken);
    cancelReasons.add(reason);
    if (cancelError != null) throw cancelError!;
    return cancelResponse ??
        orderResponse.copyWith(
          status: 'REJECTED',
        );
  }
}

OrderSnapshot fakeOrderSnapshot({
  String id = '00000000-0000-4000-8000-000000000201',
  FulfillmentMode modality = FulfillmentMode.local,
  String channel = 'APP',
  String status = 'REQUESTED',
  String totalAmount = '24.25',
  String? tableId = 'table-1',
  String? deliveryAddress,
  String? contactName,
  String? contactPhone,
  List<OrderLineSnapshot>? lines,
  DateTime? createdAt,
}) {
  return OrderSnapshot(
    id: id,
    modality: modality,
    channel: channel,
    status: status,
    totalAmount: totalAmount,
    tableId: tableId,
    deliveryAddress: deliveryAddress,
    contactName: contactName,
    contactPhone: contactPhone,
    lines: lines ??
        const <OrderLineSnapshot>[
          OrderLineSnapshot(
            productId: 'product-1',
            productName: 'Arroz chaufa especial',
            quantity: 1,
            unitPrice: '24.25',
          ),
        ],
    createdAt: createdAt ?? DateTime.utc(2026, 10, 24, 12),
  );
}

OrderTrackingSnapshot fakeTrackingSnapshot({
  String orderId = '00000000-0000-4000-8000-000000000201',
  FulfillmentMode modality = FulfillmentMode.local,
  String orderStatus = 'REQUESTED',
  String stage = 'SOLICITUD',
  String? kitchenStatus,
  String? fulfillmentKind,
  String totalAmount = '24.25',
  String paidAmount = '0.00',
  String balance = '24.25',
  String paymentStatus = 'UNPAID',
  DateTime? createdAt,
}) {
  return OrderTrackingSnapshot(
    orderId: orderId,
    modality: modality,
    orderStatus: orderStatus,
    stage: stage,
    kitchenStatus: kitchenStatus,
    fulfillmentKind: fulfillmentKind,
    totalAmount: totalAmount,
    paidAmount: paidAmount,
    balance: balance,
    paymentStatus: paymentStatus,
    createdAt: createdAt ?? DateTime.utc(2026, 10, 24, 12),
  );
}
