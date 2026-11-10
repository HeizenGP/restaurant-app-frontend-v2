enum OrderStatus {
  requested('REQUESTED'),
  approved('APPROVED'),
  rejected('REJECTED'),
  confirmed('CONFIRMED'),
  cancelled('CANCELLED'),
  closed('CLOSED');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromString(String raw) {
    final String clean = raw.trim().toUpperCase();
    return switch (clean) {
      'REQUESTED' => OrderStatus.requested,
      'APPROVED' => OrderStatus.approved,
      'REJECTED' => OrderStatus.rejected,
      'CONFIRMED' => OrderStatus.confirmed,
      'CANCELLED' => OrderStatus.cancelled,
      'CLOSED' => OrderStatus.closed,
      _ => OrderStatus.requested,
    };
  }

  String get displayName => switch (this) {
    OrderStatus.requested => 'Solicitado',
    OrderStatus.approved => 'Aprobado',
    OrderStatus.rejected => 'Rechazado',
    OrderStatus.confirmed => 'Confirmado',
    OrderStatus.cancelled => 'Cancelado',
    OrderStatus.closed => 'Cerrado',
  };
}

enum OrderModality {
  local('LOCAL'),
  pickup('PICKUP'),
  delivery('DELIVERY');

  const OrderModality(this.value);
  final String value;

  static OrderModality fromString(String raw) {
    final String clean = raw.trim().toUpperCase();
    return switch (clean) {
      'LOCAL' => OrderModality.local,
      'PICKUP' => OrderModality.pickup,
      'DELIVERY' => OrderModality.delivery,
      _ => OrderModality.local,
    };
  }

  String get displayName => switch (this) {
    OrderModality.local => 'Mesa / Salón',
    OrderModality.pickup => 'Para Llevar (Pickup)',
    OrderModality.delivery => 'Delivery',
  };
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  double get subtotal => quantity * unitPrice;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName:
          json['product_name_snapshot'] as String? ??
          json['product_name'] as String? ??
          'Producto',
      quantity: _asInt(json['quantity'], 1),
      unitPrice: _asDouble(json['unit_price_snapshot'] ?? json['unit_price']),
    );
  }
}

class StaffOrder {
  const StaffOrder({
    required this.id,
    required this.modality,
    required this.channel,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
    this.tableId,
    this.deliveryAddress,
    this.contactName,
    this.contactPhone,
  });

  final String id;
  final OrderModality modality;
  final String channel;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final List<OrderItem> items;
  final String? tableId;
  final String? deliveryAddress;
  final String? contactName;
  final String? contactPhone;

  bool get isRequested => status == OrderStatus.requested;
  bool get isApproved => status == OrderStatus.approved;
  bool get isConfirmed => status == OrderStatus.confirmed;
  bool get isClosed => status == OrderStatus.closed;

  factory StaffOrder.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        (json['lines'] ?? json['items']) as List<dynamic>? ?? <dynamic>[];
    final List<OrderItem> items = rawItems
        .map((dynamic item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return StaffOrder(
      id: json['id'] as String? ?? '',
      modality: OrderModality.fromString(
        json['modality'] as String? ?? 'LOCAL',
      ),
      channel: json['channel'] as String? ?? 'APP',
      status: OrderStatus.fromString(json['status'] as String? ?? 'REQUESTED'),
      totalAmount: _asDouble(json['total_amount']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: items,
      tableId: json['table_id'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
    );
  }
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _asInt(Object? value, [int defaultValue = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}
