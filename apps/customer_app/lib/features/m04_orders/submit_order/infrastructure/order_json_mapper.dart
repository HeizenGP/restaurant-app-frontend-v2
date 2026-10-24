import '../../choose_fulfillment/domain/fulfillment_models.dart';
import '../application/order_contracts.dart';
import '../domain/order_models.dart';

abstract final class OrderJsonMapper {
  static Map<String, Object?> encodeCreate(CreateOrderCommand command) {
    final FulfillmentDraft fulfillment = command.fulfillment;
    return <String, Object?>{
      'modality': fulfillment.mode.apiValue,
      'items': command.items
          .map(
            (CreateOrderItem item) => <String, Object?>{
              'product_id': item.productId,
              'quantity': item.quantity,
            },
          )
          .toList(growable: false),
      'table_id': fulfillment.mode == FulfillmentMode.local
          ? fulfillment.tableId
          : null,
      'delivery_address': fulfillment.mode == FulfillmentMode.delivery
          ? fulfillment.deliveryAddress
          : null,
      'contact_name': fulfillment.mode == FulfillmentMode.local
          ? null
          : fulfillment.contactName,
      'contact_phone': fulfillment.mode == FulfillmentMode.local
          ? null
          : fulfillment.contactPhone,
    };
  }

  static OrderSnapshot decodeOrder(Object? payload) {
    try {
      if (payload is! Map<String, Object?>) {
        throw const FormatException('order must be an object');
      }
      final Map<String, Object?> map = payload;
      final FulfillmentMode modality = _modality(
        _requiredString(map, 'modality'),
      );
      final Object? rawLines = map['lines'];
      if (rawLines is! List<Object?>) {
        throw const FormatException('lines must be a list');
      }
      final List<OrderLineSnapshot> lines = rawLines
          .map<OrderLineSnapshot>(_decodeLine)
          .toList(growable: false);
      if (lines.isEmpty) {
        throw const FormatException('lines cannot be empty');
      }

      return OrderSnapshot(
        id: _requiredString(map, 'id'),
        modality: modality,
        channel: _requiredString(map, 'channel'),
        status: _requiredString(map, 'status'),
        tableId: _nullableString(map, 'table_id'),
        deliveryAddress: _nullableString(map, 'delivery_address'),
        contactName: _nullableString(map, 'contact_name'),
        contactPhone: _nullableString(map, 'contact_phone'),
        totalAmount: _decimalString(map, 'total_amount'),
        lines: List<OrderLineSnapshot>.unmodifiable(lines),
        createdAt: _dateTime(map, 'created_at'),
        decidedAt: _nullableDateTime(map, 'decided_at'),
        tableVerifiedAt: _nullableDateTime(map, 'table_verified_at'),
      );
    } on OrderFailure {
      rethrow;
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.malformedResponse,
        'El servidor devolvió un pedido no válido.',
      );
    }
  }

  static OrderLineSnapshot _decodeLine(Object? payload) {
    if (payload is! Map<String, Object?>) {
      throw const FormatException('line must be an object');
    }
    final int quantity = _requiredInt(payload, 'quantity');
    if (quantity < 1) throw const FormatException('invalid quantity');
    return OrderLineSnapshot(
      productId: _requiredString(payload, 'product_id'),
      productName: _requiredString(payload, 'product_name_snapshot'),
      quantity: quantity,
      unitPrice: _decimalString(payload, 'unit_price_snapshot'),
    );
  }

  static FulfillmentMode _modality(String value) {
    for (final FulfillmentMode mode in FulfillmentMode.values) {
      if (mode.apiValue == value) return mode;
    }
    throw const FormatException('invalid modality');
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

  static int _requiredInt(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is! int) throw FormatException('$key must be an integer');
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
