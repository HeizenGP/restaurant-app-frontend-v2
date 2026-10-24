import '../../choose_fulfillment/domain/fulfillment_models.dart';
import '../../submit_order/application/order_contracts.dart';
import '../../submit_order/domain/order_models.dart';
import '../../submit_order/infrastructure/order_json_mapper.dart';
import '../domain/order_tracking_models.dart';

abstract final class OrderTrackingJsonMapper {
  static List<OrderSnapshot> decodeOrdersList(Object? payload) {
    try {
      if (payload is! List<Object?>) {
        throw const FormatException('orders list must be an array');
      }
      return payload
          .map<OrderSnapshot>((Object? item) => OrderJsonMapper.decodeOrder(item))
          .toList(growable: false);
    } on OrderFailure {
      rethrow;
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.malformedResponse,
        'El servidor devolvió una lista de pedidos no válida.',
      );
    }
  }

  static OrderTrackingSnapshot decodeTracking(Object? payload) {
    try {
      if (payload is! Map<String, Object?>) {
        throw const FormatException('tracking must be an object');
      }
      final Map<String, Object?> map = payload;
      final FulfillmentMode modality = _modality(_requiredString(map, 'modality'));

      return OrderTrackingSnapshot(
        orderId: _requiredString(map, 'order_id'),
        modality: modality,
        orderStatus: _requiredString(map, 'order_status'),
        stage: _requiredString(map, 'stage'),
        kitchenStatus: _nullableString(map, 'kitchen_status'),
        fulfillmentKind: _nullableString(map, 'fulfillment_kind'),
        totalAmount: _decimalString(map, 'total_amount'),
        paidAmount: _decimalString(map, 'paid_amount'),
        balance: _decimalString(map, 'balance'),
        paymentStatus: _requiredString(map, 'payment_status'),
        createdAt: _dateTime(map, 'created_at'),
        kitchenStartedAt: _nullableDateTime(map, 'kitchen_started_at'),
        kitchenReadyAt: _nullableDateTime(map, 'kitchen_ready_at'),
        fulfilledAt: _nullableDateTime(map, 'fulfilled_at'),
        closedAt: _nullableDateTime(map, 'closed_at'),
      );
    } on OrderFailure {
      rethrow;
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.malformedResponse,
        'El servidor devolvió un seguimiento no válido.',
      );
    }
  }

  static FulfillmentMode _modality(String value) {
    return switch (value) {
      'LOCAL' => FulfillmentMode.local,
      'PICKUP' => FulfillmentMode.pickup,
      'DELIVERY' => FulfillmentMode.delivery,
      _ => throw FormatException('unknown modality $value'),
    };
  }

  static String _requiredString(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string');
    }
    return value;
  }

  static String? _nullableString(Map<String, Object?> map, String key) {
    if (!map.containsKey(key)) throw FormatException('$key is missing');
    final Object? value = map[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be null or a non-empty string');
    }
    return value;
  }

  static String _decimalString(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is! String ||
        !RegExp(r'^(?:0|[1-9]\d*)(?:\.\d+)?$').hasMatch(value)) {
      throw FormatException('$key must be a decimal string');
    }
    return value;
  }

  static DateTime _dateTime(Map<String, Object?> map, String key) {
    final String value = _requiredString(map, key);
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('$key must be ISO-8601');
    return parsed;
  }

  static DateTime? _nullableDateTime(Map<String, Object?> map, String key) {
    if (!map.containsKey(key)) throw FormatException('$key is missing');
    final Object? value = map[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('$key must be ISO-8601');
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('$key must be ISO-8601');
    return parsed;
  }
}
