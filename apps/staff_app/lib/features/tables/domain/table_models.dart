class RestaurantTable {
  const RestaurantTable({
    required this.id,
    required this.code,
    required this.isOccupied,
    required this.updatedAt,
    this.areaLabel,
    this.occupancyStartedAt,
  });

  final String id;
  final String code;
  final bool isOccupied;
  final DateTime updatedAt;
  final String? areaLabel;
  final DateTime? occupancyStartedAt;

  String get area => areaLabel ?? 'Salón Principal';

  Duration? get occupancyDuration {
    if (!isOccupied || occupancyStartedAt == null) return null;
    return DateTime.now().difference(occupancyStartedAt!);
  }

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      isOccupied: json['is_occupied'] as bool? ?? false,
      areaLabel: json['area_label'] as String?,
      occupancyStartedAt: json['occupancy_started_at'] != null
          ? DateTime.tryParse(json['occupancy_started_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
