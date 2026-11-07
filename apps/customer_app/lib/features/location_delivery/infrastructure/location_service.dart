import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../domain/delivery_coverage.dart';
import '../domain/location_models.dart';

class LocationService {
  const LocationService();

  // Sede KAIRO y centro inicial de la experiencia de delivery en Tarapoto.
  static const LatLng defaultTarapotoLocation = LatLng(
    KairoDeliveryCoverage.centerLatitude,
    KairoDeliveryCoverage.centerLongitude,
  );

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<LocationPermissionState> checkPermission() async {
    try {
      final LocationPermission permission = await Geolocator.checkPermission();
      return _mapPermission(permission);
    } catch (_) {
      return LocationPermissionState.denied;
    }
  }

  Future<LocationPermissionState> requestPermission() async {
    try {
      final LocationPermission permission =
          await Geolocator.requestPermission();
      return _mapPermission(permission);
    } catch (_) {
      return LocationPermissionState.denied;
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('LocationService error: $e');
      return null;
    }
  }

  LocationPermissionState _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionState.granted;
      case LocationPermission.deniedForever:
        return LocationPermissionState.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationPermissionState.denied;
    }
  }
}
