import 'package:flutter/foundation.dart';

import 'delivery_coverage.dart';

enum LocationPermissionState { granted, denied, deniedForever, serviceDisabled }

@immutable
final class DeliveryZoneQuote {
  const DeliveryZoneQuote({
    required this.isCovered,
    required this.distanceKm,
    this.zoneCode,
    this.zoneName,
    this.deliveryFee,
    this.estimatedMinMinutes,
    this.estimatedMaxMinutes,
    this.message,
    this.restaurantName = 'KAIRO - Alta Cocina Asiática',
    this.restaurantAddress = KairoDeliveryCoverage.restaurantAddress,
    this.restaurantLatitude = KairoDeliveryCoverage.centerLatitude,
    this.restaurantLongitude = KairoDeliveryCoverage.centerLongitude,
  });

  factory DeliveryZoneQuote.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneQuote(
      isCovered: json['is_covered'] as bool? ?? false,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      zoneCode: json['zone_code'] as String?,
      zoneName: json['zone_name'] as String?,
      deliveryFee: json['delivery_fee'] as String?,
      estimatedMinMinutes: json['estimated_min_minutes'] as int?,
      estimatedMaxMinutes: json['estimated_max_minutes'] as int?,
      message: json['message'] as String?,
      restaurantName:
          json['restaurant_name'] as String? ?? 'KAIRO - Alta Cocina Asiática',
      restaurantAddress:
          json['restaurant_address'] as String? ??
          KairoDeliveryCoverage.restaurantAddress,
      restaurantLatitude:
          (json['restaurant_latitude'] as num?)?.toDouble() ??
          KairoDeliveryCoverage.centerLatitude,
      restaurantLongitude:
          (json['restaurant_longitude'] as num?)?.toDouble() ??
          KairoDeliveryCoverage.centerLongitude,
    );
  }

  final bool isCovered;
  final double distanceKm;
  final String? zoneCode;
  final String? zoneName;
  final String? deliveryFee;
  final int? estimatedMinMinutes;
  final int? estimatedMaxMinutes;
  final String? message;
  final String restaurantName;
  final String restaurantAddress;
  final double restaurantLatitude;
  final double restaurantLongitude;

  String get formattedFee {
    if (deliveryFee == null || deliveryFee!.isEmpty) return 'Consultar';
    return 'S/ $deliveryFee';
  }

  String get formattedEta {
    if (estimatedMinMinutes != null && estimatedMaxMinutes != null) {
      return '$estimatedMinMinutes - $estimatedMaxMinutes min';
    }
    return '30 - 45 min';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryZoneQuote &&
          other.isCovered == isCovered &&
          other.distanceKm == distanceKm &&
          other.zoneCode == zoneCode &&
          other.deliveryFee == deliveryFee;

  @override
  int get hashCode => Object.hash(isCovered, distanceKm, zoneCode, deliveryFee);
}

@immutable
final class GeocodedAddress {
  const GeocodedAddress({
    required this.displayName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.street,
    this.houseNumber,
    this.district,
    this.province,
    this.department,
    this.city,
  });

  factory GeocodedAddress.fromJson(Map<String, dynamic> json) {
    return GeocodedAddress(
      displayName: json['display_name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      street: json['street'] as String?,
      houseNumber:
          json['house_number'] as String? ?? json['houseNumber'] as String?,
      district: json['district'] as String?,
      province: json['province'] as String?,
      department: json['department'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String displayName;
  final String address;
  final String? street;
  final String? houseNumber;
  final String? district;
  final String? province;
  final String? department;
  final String? city;
  final double latitude;
  final double longitude;

  bool get hasStreet => street != null && street!.trim().isNotEmpty;

  String get readableStreet {
    if (!hasStreet) return '';
    final String s = street!.trim();
    if (houseNumber != null && houseNumber!.trim().isNotEmpty) {
      return '$s ${houseNumber!.trim()}';
    }
    return s;
  }

  String get readableArea {
    final List<String> parts = <String>[];
    if (district != null && district!.trim().isNotEmpty) {
      parts.add(district!.trim());
    }
    final String prov = province ?? city ?? '';
    if (prov.trim().isNotEmpty && !parts.contains(prov.trim())) {
      parts.add(prov.trim());
    }
    if (department != null &&
        department!.trim().isNotEmpty &&
        !parts.contains(department!.trim())) {
      parts.add(department!.trim());
    }
    if (parts.isEmpty) {
      return '${KairoDeliveryCoverage.city}, '
          '${KairoDeliveryCoverage.department}';
    }
    return parts.join(', ');
  }

  GeocodedAddress copyWith({
    String? displayName,
    String? address,
    String? street,
    String? houseNumber,
    String? district,
    String? province,
    String? department,
    String? city,
    double? latitude,
    double? longitude,
  }) {
    return GeocodedAddress(
      displayName: displayName ?? this.displayName,
      address: address ?? this.address,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      district: district ?? this.district,
      province: province ?? this.province,
      department: department ?? this.department,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeocodedAddress &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.address == address &&
          other.street == street &&
          other.houseNumber == houseNumber &&
          other.district == district;

  @override
  int get hashCode =>
      Object.hash(latitude, longitude, address, street, district);
}
