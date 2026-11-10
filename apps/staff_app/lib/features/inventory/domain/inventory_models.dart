int _asInt(Object? value, [int defaultValue = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.kind,
    required this.quantityDelta,
    required this.recordedAt,
    this.actorUserId,
  });

  final String id;
  final String productId;
  final String productName;
  final String kind;
  final int quantityDelta;
  final DateTime recordedAt;
  final String? actorUserId;

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Producto',
      kind: json['kind'] as String? ?? 'MANUAL',
      quantityDelta: _asInt(json['quantity_delta']),
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      actorUserId: json['actor_user_id'] as String?,
    );
  }
}
