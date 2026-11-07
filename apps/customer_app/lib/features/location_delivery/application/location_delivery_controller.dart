import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../m01_access/profile/application/user_profile_controller.dart';
import '../../m01_access/profile/domain/profile_models.dart';
import '../domain/location_models.dart';
import '../infrastructure/address_rest_repository.dart';
import '../infrastructure/location_service.dart';

class LocationDeliveryController extends ChangeNotifier {
  LocationDeliveryController({
    required AddressRestRepository addressRepository,
    this._locationService = const LocationService(),
    this._profileController,
  }) : _addressRepo = addressRepository;

  final AddressRestRepository _addressRepo;
  final LocationService _locationService;
  final UserProfileController? _profileController;

  CustomerAddress? _selectedAddress;
  List<CustomerAddress> _savedAddresses = <CustomerAddress>[];
  DeliveryZoneQuote? _currentZoneQuote;
  bool _isLocatingGps = false;
  bool _isReverseGeocoding = false;
  bool _isSaving = false;
  String? _lastError;

  CustomerAddress? get selectedAddress => _selectedAddress;
  List<CustomerAddress> get savedAddresses =>
      List<CustomerAddress>.unmodifiable(_savedAddresses);
  DeliveryZoneQuote? get currentZoneQuote => _currentZoneQuote;
  bool get isLocatingGps => _isLocatingGps;
  bool get isReverseGeocoding => _isReverseGeocoding;
  bool get isSaving => _isSaving;
  String? get lastError => _lastError;

  // Initializer / Loader
  Future<void> initialize() async {
    await loadAddresses();
    // Solicitar permiso de ubicación al ingresar a la app
    unawaited(requestLocationPermissionOnStartup());
  }

  Future<void> requestLocationPermissionOnStartup() async {
    try {
      final LocationPermissionState perm = await _locationService
          .checkPermission();
      if (perm == LocationPermissionState.denied) {
        await _locationService.requestPermission();
      }
    } catch (_) {}
  }

  Future<void> loadAddresses() async {
    try {
      final List<CustomerAddress> remoteAddresses = await _addressRepo
          .getSavedAddresses();
      if (remoteAddresses.isNotEmpty) {
        _savedAddresses = remoteAddresses;
      } else if (_profileController != null &&
          _profileController.addresses.isNotEmpty) {
        _savedAddresses = List<CustomerAddress>.from(
          _profileController.addresses,
        );
      }

      // Pre-select default address if available, or first
      if (_savedAddresses.isNotEmpty) {
        final CustomerAddress defaultAddr = _savedAddresses.firstWhere(
          (CustomerAddress a) => a.isDefault,
          orElse: () => _savedAddresses.first,
        );
        _selectedAddress = defaultAddr;
        if (defaultAddr.hasCoordinates) {
          unawaited(checkZone(defaultAddr.latitude!, defaultAddr.longitude!));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  void selectAddress(CustomerAddress address) {
    _selectedAddress = address;
    if (address.hasCoordinates) {
      unawaited(checkZone(address.latitude!, address.longitude!));
    }
    notifyListeners();
  }

  Future<LatLng?> locateCurrentGps() async {
    _isLocatingGps = true;
    _lastError = null;
    notifyListeners();

    try {
      final LatLng? pos = await _locationService.getCurrentLocation();
      _isLocatingGps = false;
      notifyListeners();
      return pos;
    } catch (e) {
      _lastError = 'No se pudo obtener la ubicación GPS.';
      _isLocatingGps = false;
      notifyListeners();
      return null;
    }
  }

  Future<GeocodedAddress> reverseGeocode(double lat, double lon) async {
    _isReverseGeocoding = true;
    notifyListeners();

    try {
      final GeocodedAddress result = await _addressRepo.reverseGeocode(
        lat,
        lon,
      );
      _isReverseGeocoding = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isReverseGeocoding = false;
      notifyListeners();
      return GeocodedAddress(
        displayName:
            'Coordenadas: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
        address:
            'Coordenadas: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
        latitude: lat,
        longitude: lon,
      );
    }
  }

  Future<DeliveryZoneQuote> checkZone(double lat, double lon) async {
    try {
      final DeliveryZoneQuote quote = await _addressRepo.checkDeliveryZone(
        lat,
        lon,
      );
      _currentZoneQuote = quote;
      notifyListeners();
      return quote;
    } catch (e) {
      debugPrint('CheckZone error: $e');
      return const DeliveryZoneQuote(
        isCovered: true,
        distanceKm: 2.0,
        zoneName: 'Zona 1 - Tarapoto centro',
        deliveryFee: '5.00',
      );
    }
  }

  Future<List<GeocodedAddress>> searchAddresses(
    String query, {
    double? proximityLat,
    double? proximityLon,
  }) async {
    return _addressRepo.searchAddresses(
      query,
      proximityLat: proximityLat,
      proximityLon: proximityLon,
    );
  }

  Future<CustomerAddress?> saveNewAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    String? department,
    String? reference,
    String? deliveryInstructions,
    String? recipientPhone,
    bool isDefault = false,
  }) async {
    _isSaving = true;
    _lastError = null;
    notifyListeners();

    try {
      final CustomerAddress? created = await _addressRepo.createAddress(
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
        department: department,
        reference: reference,
        deliveryInstructions: deliveryInstructions,
        recipientPhone: recipientPhone,
        isDefault: isDefault,
      );

      final CustomerAddress finalAddress =
          created ??
          CustomerAddress(
            id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
            label: label,
            address: address,
            latitude: latitude,
            longitude: longitude,
            department: department,
            reference: reference,
            deliveryInstructions: deliveryInstructions,
            recipientPhone: recipientPhone,
            isDefault: isDefault,
          );

      if (isDefault) {
        _savedAddresses = _savedAddresses
            .map((CustomerAddress a) => a.copyWith(isDefault: false))
            .toList();
      }
      _savedAddresses.insert(0, finalAddress);
      _selectedAddress = finalAddress;

      // Sync with profileController if present
      _profileController?.addAddress(
        label: label,
        address: address,
        reference: reference,
        department: department,
        recipientPhone: recipientPhone,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      await checkZone(latitude, longitude);

      _isSaving = false;
      notifyListeners();
      return finalAddress;
    } catch (e) {
      _lastError = 'Error al guardar la dirección: $e';
      _isSaving = false;
      notifyListeners();
      return null;
    }
  }

  Future<CustomerAddress?> updateExistingAddress({
    required String id,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    String? department,
    String? reference,
    String? deliveryInstructions,
    String? recipientPhone,
    bool? isDefault,
  }) async {
    _isSaving = true;
    _lastError = null;
    notifyListeners();

    try {
      final CustomerAddress? updated = await _addressRepo.updateAddress(
        id: id,
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
        department: department,
        reference: reference,
        deliveryInstructions: deliveryInstructions,
        recipientPhone: recipientPhone,
        isDefault: isDefault,
      );

      final int index = _savedAddresses.indexWhere(
        (CustomerAddress a) => a.id == id,
      );
      CustomerAddress? resolved;
      if (index >= 0) {
        final CustomerAddress current = _savedAddresses[index];
        resolved =
            updated ??
            current.copyWith(
              label: label,
              address: address,
              latitude: latitude,
              longitude: longitude,
              department: department,
              reference: reference,
              deliveryInstructions: deliveryInstructions,
              recipientPhone: recipientPhone,
              isDefault: isDefault,
            );

        if (isDefault == true) {
          _savedAddresses = _savedAddresses
              .map((CustomerAddress a) => a.copyWith(isDefault: a.id == id))
              .toList();
        }
        _savedAddresses[index] = resolved;

        if (_selectedAddress?.id == id) {
          _selectedAddress = resolved;
          if (resolved.hasCoordinates) {
            unawaited(checkZone(resolved.latitude!, resolved.longitude!));
          }
        }
      }

      _isSaving = false;
      notifyListeners();
      return resolved ?? updated;
    } catch (e) {
      _lastError = 'Error al actualizar dirección: $e';
      _isSaving = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteAddress(String id) async {
    final bool ok = await _addressRepo.deleteAddress(id);
    _savedAddresses.removeWhere((CustomerAddress a) => a.id == id);
    if (_selectedAddress?.id == id) {
      _selectedAddress = _savedAddresses.isNotEmpty
          ? _savedAddresses.first
          : null;
    }
    _profileController?.removeAddress(id);
    notifyListeners();
    return ok;
  }

  Future<void> setDefaultAddress(String id) async {
    await _addressRepo.setDefaultAddress(id);
    _savedAddresses = _savedAddresses.map((CustomerAddress a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();

    final CustomerAddress? target = _savedAddresses
        .cast<CustomerAddress?>()
        .firstWhere((CustomerAddress? a) => a?.id == id, orElse: () => null);
    if (target != null) {
      _selectedAddress = target;
    }
    _profileController?.setDefaultAddress(id);
    notifyListeners();
  }
}
