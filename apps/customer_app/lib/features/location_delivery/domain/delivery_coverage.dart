import 'dart:math' as math;

/// Configuración de cobertura de la sede KAIRO en Tarapoto.
///
/// Se mantiene en el dominio para que GPS, geocodificación y validación de zona
/// compartan una única referencia y no vuelvan a divergir entre ciudades.
abstract final class KairoDeliveryCoverage {
  static const double centerLatitude = -6.4825;
  static const double centerLongitude = -76.3727;
  static const double maximumRadiusKm = 12.0;
  static const String city = 'Tarapoto';
  static const String department = 'San Martín';
  static const String restaurantAddress = 'Tarapoto, San Martín, Perú';

  /// Área de prioridad para el buscador Photon: Tarapoto, Morales y
  /// La Banda de Shilcayo, con margen para la zona extendida.
  static const String photonBoundingBox = '-76.55,-6.65,-76.20,-6.30';

  static bool isTarapotoCenter(double latitude, double longitude) {
    return distanceKm(centerLatitude, centerLongitude, latitude, longitude) <=
        2.0;
  }

  static double distanceFromCenterKm(double latitude, double longitude) {
    return distanceKm(centerLatitude, centerLongitude, latitude, longitude);
  }

  static double distanceKm(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const double earthRadiusKm = 6371.0;
    final double latARadians = _toRadians(latitudeA);
    final double latBRadians = _toRadians(latitudeB);
    final double deltaLat = _toRadians(latitudeB - latitudeA);
    final double deltaLon = _toRadians(longitudeB - longitudeA);
    final double sinLat = math.sin(deltaLat / 2);
    final double sinLon = math.sin(deltaLon / 2);
    final double haversine =
        sinLat * sinLat +
        math.cos(latARadians) * math.cos(latBRadians) * sinLon * sinLon;
    final double angularDistance =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
    return earthRadiusKm * angularDistance;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
