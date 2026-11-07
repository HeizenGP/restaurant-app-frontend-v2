import 'package:customer_app/features/location_delivery/presentation/kairo_map_style.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  group('KairoMapStyle', () {
    test('standard light style uses only supported basemap properties', () {
      final KairoMapStyle style = KairoMapStyle.resolve(
        layer: KairoMapLayer.standard,
        isDark: false,
      );

      expect(style.styleUri, MapboxStyles.STANDARD);
      expect(style.importConfig['lightPreset'], 'day');
      expect(style.importConfig['theme'], 'custom');
      expect(
        style.importConfig.keys.toSet().difference(
          KairoMapStyle.supportedStandardProperties,
        ),
        isEmpty,
      );
      expect(style.importConfig['colorLand'], '#ece8e1');
      expect(style.importConfig['colorBuildings'], '#d8d2c9');
      expect(style.importConfig['showRoadLabels'], isTrue);
    });

    test('standard dark style remains detailed instead of pure black', () {
      final KairoMapStyle style = KairoMapStyle.resolve(
        layer: KairoMapLayer.standard,
        isDark: true,
      );

      expect(style.styleUri, MapboxStyles.STANDARD);
      expect(style.importConfig['lightPreset'], 'night');
      expect(style.importConfig['colorLand'], '#25282c');
      expect(style.importConfig['colorRoads'], '#454a50');
      expect(style.importConfig['colorBuildings'], '#363b40');
      expect(style.importConfig['colorRoadLabels'], '#f1eae0');
    });

    test('satellite style excludes unsupported color and theme overrides', () {
      final KairoMapStyle style = KairoMapStyle.resolve(
        layer: KairoMapLayer.satellite,
        isDark: true,
      );

      expect(style.styleUri, MapboxStyles.STANDARD_SATELLITE);
      expect(style.importConfig.containsKey('theme'), isFalse);
      expect(
        style.importConfig.keys.any((String key) => key.startsWith('color')),
        isFalse,
      );
      expect(
        style.importConfig.keys.toSet().difference(
          KairoMapStyle.supportedSatelliteProperties,
        ),
        isEmpty,
      );
      expect(style.importConfig['showRoadsAndTransit'], isTrue);
      expect(style.importConfig['showAdminBoundaries'], isTrue);
      expect(style.importConfig['showTransitLabels'], isTrue);
      expect(style.importConfig['backgroundPointOfInterestLabels'], 'circle');
    });

    test('only a complete style failure is blocking', () {
      expect(KairoMapStyle.isBlockingLoadError(MapLoadErrorType.STYLE), isTrue);
      expect(KairoMapStyle.isBlockingLoadError(MapLoadErrorType.TILE), isFalse);
      expect(
        KairoMapStyle.isBlockingLoadError(MapLoadErrorType.GLYPHS),
        isFalse,
      );
      expect(
        KairoMapStyle.isBlockingLoadError(MapLoadErrorType.SOURCE),
        isFalse,
      );
      expect(
        KairoMapStyle.isBlockingLoadError(MapLoadErrorType.SPRITE),
        isFalse,
      );
    });

    test('detects a satellite tile quota limit without blocking the map', () {
      expect(
        KairoMapStyle.isSatelliteRateLimitError(
          MapLoadErrorType.TILE,
          'Failed to load tile: HTTP status code 429. Too Many Requests',
        ),
        isTrue,
      );
      expect(
        KairoMapStyle.isSatelliteRateLimitError(
          MapLoadErrorType.TILE,
          'Failed to load tile: network unavailable',
        ),
        isFalse,
      );
      expect(
        KairoMapStyle.isSatelliteRateLimitError(
          MapLoadErrorType.STYLE,
          'HTTP status code 429',
        ),
        isFalse,
      );
    });
  });
}
