double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _asInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class TopProduct {
  const TopProduct({required this.name, required this.totalQuantity});

  final String name;
  final int totalQuantity;

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      name: json['name'] as String? ?? '',
      totalQuantity: _asInt(json['total_quantity']),
    );
  }
}

class DashboardOrder {
  const DashboardOrder({
    required this.id,
    required this.modality,
    required this.channel,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.contactName,
    this.tableId,
  });

  final String id;
  final String modality;
  final String channel;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final String? contactName;
  final String? tableId;

  factory DashboardOrder.fromJson(Map<String, dynamic> json) {
    return DashboardOrder(
      id: json['id'] as String? ?? '',
      modality: json['modality'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalAmount: _asDouble(json['total_amount']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      contactName: json['contact_name'] as String?,
      tableId: json['table_id'] as String?,
    );
  }
}

class DashboardStats {
  const DashboardStats({
    required this.todaySales,
    required this.todayOrdersCount,
    required this.activeOrdersCount,
    required this.occupiedTablesCount,
    required this.totalTablesCount,
    required this.totalProductsCount,
    required this.lowStockCount,
    required this.ordersByModality,
    required this.ordersByStatus,
    required this.topProducts,
    required this.recentOrders,
  });

  final double todaySales;
  final int todayOrdersCount;
  final int activeOrdersCount;
  final int occupiedTablesCount;
  final int totalTablesCount;
  final int totalProductsCount;
  final int lowStockCount;
  final Map<String, int> ordersByModality;
  final Map<String, int> ordersByStatus;
  final List<TopProduct> topProducts;
  final List<DashboardOrder> recentOrders;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawModality =
        json['orders_by_modality'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final Map<String, int> modality = rawModality.map(
      (String k, dynamic v) => MapEntry<String, int>(k, _asInt(v)),
    );

    final Map<String, dynamic> rawStatus =
        json['orders_by_status'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final Map<String, int> status = rawStatus.map(
      (String k, dynamic v) => MapEntry<String, int>(k, _asInt(v)),
    );

    final List<dynamic> rawTop =
        json['top_products'] as List<dynamic>? ?? <dynamic>[];
    final List<TopProduct> top = rawTop
        .map(
          (dynamic item) => TopProduct.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    final List<dynamic> rawRecent =
        json['recent_orders'] as List<dynamic>? ?? <dynamic>[];
    final List<DashboardOrder> recent = rawRecent
        .map(
          (dynamic item) =>
              DashboardOrder.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return DashboardStats(
      todaySales: _asDouble(json['today_sales']),
      todayOrdersCount: _asInt(json['today_orders_count']),
      activeOrdersCount: _asInt(json['active_orders_count']),
      occupiedTablesCount: _asInt(json['occupied_tables_count']),
      totalTablesCount: _asInt(json['total_tables_count']),
      totalProductsCount: _asInt(json['total_products_count']),
      lowStockCount: _asInt(json['low_stock_count']),
      ordersByModality: modality,
      ordersByStatus: status,
      topProducts: top,
      recentOrders: recent,
    );
  }
}
