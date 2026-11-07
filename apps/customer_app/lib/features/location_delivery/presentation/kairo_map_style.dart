import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/design_system/design_system.dart';

enum KairoMapLayer { standard, satellite }

/// Configuración segura de Mapbox Standard.
///
/// No modifica IDs de capas internas: usa exclusivamente propiedades públicas
/// del import `basemap`, por lo que no depende de nombres de capas que puedan
/// cambiar entre versiones del estilo.
@immutable
class KairoMapStyle {
  const KairoMapStyle._({
    required this.layer,
    required this.isDark,
    required this.styleUri,
    required this.importConfig,
  });

  final KairoMapLayer layer;
  final bool isDark;
  final String styleUri;
  final Map<String, Object> importConfig;

  static const Set<String> supportedStandardProperties = <String>{
    'lightPreset',
    'theme',
    'showPedestrianRoads',
    'showPlaceLabels',
    'showPointOfInterestLabels',
    'showRoadLabels',
    'colorCommercial',
    'colorEducation',
    'colorMedical',
    'colorIndustrial',
    'colorGreenspace',
    'colorWater',
    'colorLand',
    'colorPlaceLabels',
    'colorBuildings',
    'colorRoadLabels',
    'colorPointOfInterestLabels',
    'colorMotorways',
    'colorTrunks',
    'colorRoads',
  };

  static const Set<String> supportedSatelliteProperties = <String>{
    'lightPreset',
    'showRoadsAndTransit',
    'showPedestrianRoads',
    'showPlaceLabels',
    'showPointOfInterestLabels',
    'showRoadLabels',
    'showTransitLabels',
    'showAdminBoundaries',
    'backgroundPointOfInterestLabels',
    'densityPointOfInterestLabels',
  };

  /// Solo un fallo del estilo completo impide usar el mapa. Los errores
  /// aislados de teselas, glifos, sprites o fuentes son recuperables y Mapbox
  /// puede seguir mostrando el resto de la cartografía.
  static bool isBlockingLoadError(MapLoadErrorType type) {
    return type == MapLoadErrorType.STYLE;
  }

  static bool isSatelliteRateLimitError(MapLoadErrorType type, String message) {
    return type == MapLoadErrorType.TILE &&
        (message.contains('429') ||
            message.toLowerCase().contains('too many requests'));
  }

  factory KairoMapStyle.resolve({
    required KairoMapLayer layer,
    required bool isDark,
  }) {
    if (layer == KairoMapLayer.satellite) {
      return KairoMapStyle._(
        layer: layer,
        isDark: isDark,
        styleUri: MapboxStyles.STANDARD_SATELLITE,
        importConfig: <String, Object>{
          'lightPreset': isDark ? 'night' : 'day',
          'showRoadsAndTransit': true,
          'showPedestrianRoads': true,
          'showPlaceLabels': true,
          'showPointOfInterestLabels': true,
          'showRoadLabels': true,
          'showTransitLabels': true,
          'showAdminBoundaries': true,
          'backgroundPointOfInterestLabels': 'circle',
          'densityPointOfInterestLabels': 3,
        },
      );
    }

    final _KairoMapPalette palette = isDark
        ? const _KairoMapPalette.dark()
        : const _KairoMapPalette.light();

    return KairoMapStyle._(
      layer: layer,
      isDark: isDark,
      styleUri: MapboxStyles.STANDARD,
      importConfig: <String, Object>{
        'lightPreset': isDark ? 'night' : 'day',
        'theme': 'custom',
        'showPedestrianRoads': true,
        'showPlaceLabels': true,
        'showPointOfInterestLabels': true,
        'showRoadLabels': true,
        'colorLand': _hex(palette.land),
        'colorRoads': _hex(palette.road),
        'colorMotorways': _hex(palette.roadMajor),
        'colorTrunks': _hex(palette.roadMajor),
        'colorBuildings': _hex(palette.building),
        'colorGreenspace': _hex(palette.green),
        'colorWater': _hex(palette.water),
        'colorPlaceLabels': _hex(palette.label),
        'colorRoadLabels': _hex(palette.label),
        'colorPointOfInterestLabels': _hex(palette.poi),
        'colorCommercial': _hex(palette.commercial),
        'colorEducation': _hex(palette.institutional),
        'colorMedical': _hex(palette.institutional),
        'colorIndustrial': _hex(palette.commercial),
      },
    );
  }

  static String _hex(Color color) {
    final String argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }
}

@immutable
class _KairoMapPalette {
  const _KairoMapPalette.light()
    : land = AsiaColors.mapLightLand,
      road = AsiaColors.mapLightRoad,
      roadMajor = AsiaColors.mapLightRoadMajor,
      building = AsiaColors.mapLightBuilding,
      green = AsiaColors.mapLightGreen,
      water = AsiaColors.mapLightWater,
      label = AsiaColors.mapLightLabel,
      poi = AsiaColors.mapLightPoi,
      commercial = AsiaColors.mapLightCommercial,
      institutional = AsiaColors.mapLightInstitutional;

  const _KairoMapPalette.dark()
    : land = AsiaColors.mapDarkLand,
      road = AsiaColors.mapDarkRoad,
      roadMajor = AsiaColors.mapDarkRoadMajor,
      building = AsiaColors.mapDarkBuilding,
      green = AsiaColors.mapDarkGreen,
      water = AsiaColors.mapDarkWater,
      label = AsiaColors.mapDarkLabel,
      poi = AsiaColors.mapDarkPoi,
      commercial = AsiaColors.mapDarkCommercial,
      institutional = AsiaColors.mapDarkInstitutional;

  final Color land;
  final Color road;
  final Color roadMajor;
  final Color building;
  final Color green;
  final Color water;
  final Color label;
  final Color poi;
  final Color commercial;
  final Color institutional;
}
