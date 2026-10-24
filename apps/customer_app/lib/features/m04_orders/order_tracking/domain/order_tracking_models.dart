import '../../choose_fulfillment/domain/fulfillment_models.dart';

enum OrderHistoryFilter {
  all,
  pending,
  confirmed,
}

final class OrderTrackingSnapshot {
  const OrderTrackingSnapshot({
    required this.orderId,
    required this.modality,
    required this.orderStatus,
    required this.stage,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.paymentStatus,
    required this.createdAt,
    this.kitchenStatus,
    this.fulfillmentKind,
    this.kitchenStartedAt,
    this.kitchenReadyAt,
    this.fulfilledAt,
    this.closedAt,
  });

  final String orderId;
  final FulfillmentMode modality;
  final String orderStatus;
  final String stage;
  final String? kitchenStatus;
  final String? fulfillmentKind;
  final String totalAmount;
  final String paidAmount;
  final String balance;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? kitchenStartedAt;
  final DateTime? kitchenReadyAt;
  final DateTime? fulfilledAt;
  final DateTime? closedAt;

  bool get isPaid => paymentStatus == 'PAID';
  bool get hasBalance => balance != '0.00' && balance != '0';
  bool get isLocal => modality == FulfillmentMode.local;
  bool get isPickup => modality == FulfillmentMode.pickup;
  bool get isDelivery => modality == FulfillmentMode.delivery;
}
