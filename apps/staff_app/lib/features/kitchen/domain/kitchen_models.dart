enum KitchenTicketStatus {
  received('RECEIVED'),
  preparing('PREPARING'),
  ready('READY');

  const KitchenTicketStatus(this.value);
  final String value;

  static KitchenTicketStatus fromString(String raw) {
    return switch (raw.trim().toUpperCase()) {
      'RECEIVED' => KitchenTicketStatus.received,
      'PREPARING' => KitchenTicketStatus.preparing,
      'READY' => KitchenTicketStatus.ready,
      _ => KitchenTicketStatus.received,
    };
  }

  String get displayName => switch (this) {
    KitchenTicketStatus.received => 'En espera',
    KitchenTicketStatus.preparing => 'En preparación',
    KitchenTicketStatus.ready => 'Listo',
  };
}

class KitchenTicketLine {
  const KitchenTicketLine({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final int quantity;

  factory KitchenTicketLine.fromJson(Map<String, dynamic> json) {
    return KitchenTicketLine(
      productId: json['product_id'] as String? ?? '',
      productName:
          json['product_name_snapshot'] as String? ??
          json['product_name'] as String? ??
          'Producto',
      quantity: _asInt(json['quantity'], 1),
    );
  }
}

class KitchenTicket {
  const KitchenTicket({
    required this.id,
    required this.orderId,
    required this.modality,
    required this.status,
    required this.lines,
    required this.createdAt,
    this.tableId,
    this.tableCode,
    this.startedAt,
    this.readyAt,
  });

  final String id;
  final String orderId;
  final String modality;
  final KitchenTicketStatus status;
  final List<KitchenTicketLine> lines;
  final DateTime createdAt;
  final String? tableId;
  final String? tableCode;
  final DateTime? startedAt;
  final DateTime? readyAt;

  bool get isReceived => status == KitchenTicketStatus.received;
  bool get isPreparing => status == KitchenTicketStatus.preparing;
  bool get isReady => status == KitchenTicketStatus.ready;

  String get modalityLabel => switch (modality.toUpperCase()) {
    'LOCAL' => 'Mesa / Salón',
    'PICKUP' => 'Para Llevar',
    'DELIVERY' => 'Delivery',
    _ => modality,
  };

  factory KitchenTicket.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawLines = json['lines'] as List<dynamic>? ?? <dynamic>[];
    return KitchenTicket(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      modality: json['modality'] as String? ?? 'LOCAL',
      status: KitchenTicketStatus.fromString(
        json['status'] as String? ?? 'RECEIVED',
      ),
      tableId: json['table_id'] as String?,
      tableCode: json['table_code'] as String?,
      lines: rawLines
          .map(
            (dynamic item) =>
                KitchenTicketLine.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : null,
      readyAt: json['ready_at'] != null
          ? DateTime.tryParse(json['ready_at'] as String)
          : null,
    );
  }
}

int _asInt(Object? value, [int defaultValue = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}
