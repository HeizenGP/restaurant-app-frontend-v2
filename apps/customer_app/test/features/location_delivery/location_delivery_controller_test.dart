import 'package:customer_app/features/location_delivery/application/location_delivery_controller.dart';
import 'package:customer_app/features/location_delivery/domain/location_models.dart';
import 'package:customer_app/features/location_delivery/infrastructure/address_rest_repository.dart';
import 'package:customer_app/features/location_delivery/infrastructure/location_service.dart';
import 'package:customer_app/features/m01_access/profile/application/user_profile_controller.dart';
import 'package:customer_app/features/m01_access/profile/domain/profile_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class FakeLocationService extends LocationService {
  const FakeLocationService({this.position});

  final LatLng? position;

  @override
  Future<LatLng?> getCurrentLocation() async => position;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermissionState> checkPermission() async =>
      LocationPermissionState.granted;
}

class FakeAddressRestRepository extends AddressRestRepository {
  FakeAddressRestRepository({this.initialAddresses = const <CustomerAddress>[]})
    : super(baseUri: Uri.parse('http://localhost:8000/api/v1'));

  final List<CustomerAddress> initialAddresses;
  final List<CustomerAddress> storedAddresses = <CustomerAddress>[];

  @override
  Future<List<CustomerAddress>> getSavedAddresses() async {
    return storedAddresses.isNotEmpty ? storedAddresses : initialAddresses;
  }

  @override
  Future<CustomerAddress?> createAddress({
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
    final CustomerAddress created = CustomerAddress(
      id: 'addr-fake-${storedAddresses.length + 1}',
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
    storedAddresses.add(created);
    return created;
  }

  @override
  Future<DeliveryZoneQuote> checkDeliveryZone(
    double latitude,
    double longitude,
  ) async {
    // San Isidro simulation
    if (latitude == -12.0968 && longitude == -77.0353) {
      return const DeliveryZoneQuote(
        isCovered: true,
        distanceKm: 0.0,
        zoneCode: 'ZONE_1',
        zoneName: 'Zona 1 - San Isidro',
        deliveryFee: '5.00',
        estimatedMinMinutes: 20,
        estimatedMaxMinutes: 35,
      );
    }
    return const DeliveryZoneQuote(
      isCovered: false,
      distanceKm: 25.0,
      message: 'Fuera de zona',
    );
  }

  @override
  Future<GeocodedAddress> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    return GeocodedAddress(
      displayName: 'Av. Las Begonias 123, San Isidro',
      address: 'Av. Las Begonias 123',
      street: 'Av. Las Begonias',
      houseNumber: '123',
      district: 'San Isidro',
      city: 'Lima',
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<List<GeocodedAddress>> searchAddresses(
    String query, {
    double? proximityLat,
    double? proximityLon,
  }) async {
    if (query.toLowerCase().contains('begonias')) {
      return const <GeocodedAddress>[
        GeocodedAddress(
          displayName: 'Av. Las Begonias 123, San Isidro',
          address: 'Av. Las Begonias 123',
          district: 'San Isidro',
          city: 'Lima',
          latitude: -12.0968,
          longitude: -77.0353,
        ),
      ];
    }
    return <GeocodedAddress>[];
  }

  @override
  Future<bool> deleteAddress(String id) async {
    storedAddresses.removeWhere((CustomerAddress a) => a.id == id);
    return true;
  }

  @override
  Future<CustomerAddress?> updateAddress({
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
    final int idx = storedAddresses.indexWhere(
      (CustomerAddress a) => a.id == id,
    );
    if (idx != -1) {
      final CustomerAddress updated = storedAddresses[idx].copyWith(
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
      storedAddresses[idx] = updated;
      return updated;
    }
    return null;
  }

  @override
  Future<CustomerAddress?> setDefaultAddress(String id) async {
    final int idx = storedAddresses.indexWhere(
      (CustomerAddress a) => a.id == id,
    );
    if (idx != -1) {
      final CustomerAddress updated = storedAddresses[idx].copyWith(
        isDefault: true,
      );
      storedAddresses[idx] = updated;
      return updated;
    }
    return null;
  }
}

void main() {
  group('LocationDeliveryController Tests', () {
    test('initializes and selects default address', () async {
      final FakeAddressRestRepository repo = FakeAddressRestRepository(
        initialAddresses: const <CustomerAddress>[
          CustomerAddress(
            id: 'addr-1',
            label: 'Casa',
            address: 'Av. Las Begonias 123',
            latitude: -12.0968,
            longitude: -77.0353,
            isDefault: true,
          ),
          CustomerAddress(
            id: 'addr-2',
            label: 'Trabajo',
            address: 'Av. Javier Prado 2450',
            latitude: -12.0864,
            longitude: -77.0032,
            isDefault: false,
          ),
        ],
      );

      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: repo,
        locationService: const FakeLocationService(),
      );

      await controller.initialize();

      expect(controller.savedAddresses.length, 2);
      expect(controller.selectedAddress?.id, 'addr-1');
      expect(controller.selectedAddress?.label, 'Casa');
      expect(controller.selectedAddress?.isDefault, isTrue);
    });

    test('locates current GPS position successfully', () async {
      const LatLng fakeGps = LatLng(-12.0968, -77.0353);
      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: FakeAddressRestRepository(),
        locationService: const FakeLocationService(position: fakeGps),
      );

      final LatLng? pos = await controller.locateCurrentGps();

      expect(pos, isNotNull);
      expect(pos?.latitude, -12.0968);
      expect(pos?.longitude, -77.0353);
      expect(controller.isLocatingGps, isFalse);
    });

    test('reverse geocodes coordinates to readable address', () async {
      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: FakeAddressRestRepository(),
        locationService: const FakeLocationService(),
      );

      final GeocodedAddress addr = await controller.reverseGeocode(
        -12.0968,
        -77.0353,
      );

      expect(addr.address, 'Av. Las Begonias 123');
      expect(addr.district, 'San Isidro');
      expect(addr.latitude, -12.0968);
    });

    test('checks delivery zone and fee', () async {
      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: FakeAddressRestRepository(),
        locationService: const FakeLocationService(),
      );

      final DeliveryZoneQuote quote = await controller.checkZone(
        -12.0968,
        -77.0353,
      );

      expect(quote.isCovered, isTrue);
      expect(quote.zoneCode, 'ZONE_1');
      expect(quote.deliveryFee, '5.00');
    });

    test(
      'saves new address and updates selectedAddress and syncs with profile',
      () async {
        final UserProfileController profileCtrl = UserProfileController(
          initialAddresses: <CustomerAddress>[],
        );
        final FakeAddressRestRepository repo = FakeAddressRestRepository();

        final LocationDeliveryController controller =
            LocationDeliveryController(
              addressRepository: repo,
              locationService: const FakeLocationService(),
              profileController: profileCtrl,
            );

        final CustomerAddress? saved = await controller.saveNewAddress(
          label: 'Casa',
          address: 'Av. Las Begonias 123',
          latitude: -12.0968,
          longitude: -77.0353,
          department: '401',
          reference: 'Frente al parque',
          recipientPhone: '987654321',
          isDefault: true,
        );

        expect(saved, isNotNull);
        expect(saved?.label, 'Casa');
        expect(controller.selectedAddress?.id, saved?.id);
        expect(controller.savedAddresses.length, 1);
        expect(profileCtrl.addresses.length, 1);
        expect(profileCtrl.addresses.first.label, 'Casa');
      },
    );

    test('deletes address and sets fallback selected address', () async {
      final FakeAddressRestRepository repo = FakeAddressRestRepository();
      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: repo,
        locationService: const FakeLocationService(),
      );

      final CustomerAddress? a1 = await controller.saveNewAddress(
        label: 'Casa',
        address: 'Av. Las Begonias 123',
        latitude: -12.0968,
        longitude: -77.0353,
      );
      final CustomerAddress? a2 = await controller.saveNewAddress(
        label: 'Trabajo',
        address: 'Av. Javier Prado 2450',
        latitude: -12.0864,
        longitude: -77.0032,
      );

      expect(controller.savedAddresses.length, 2);

      await controller.deleteAddress(a2!.id);

      expect(controller.savedAddresses.length, 1);
      expect(controller.selectedAddress?.id, a1!.id);
    });

    test('updates existing address successfully', () async {
      final FakeAddressRestRepository repo = FakeAddressRestRepository();
      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: repo,
        locationService: const FakeLocationService(),
      );

      final CustomerAddress? created = await controller.saveNewAddress(
        label: 'Casa',
        address: 'Av. Las Begonias 123',
        latitude: -12.0968,
        longitude: -77.0353,
      );

      expect(created, isNotNull);

      final CustomerAddress? updated = await controller.updateExistingAddress(
        id: created!.id,
        label: 'Casa Familiar',
        address: 'Av. Las Begonias 125, Dpto 402',
        department: '402',
        reference: 'Frente al parque',
      );

      expect(updated, isNotNull);
      expect(updated?.label, 'Casa Familiar');
      expect(updated?.address, 'Av. Las Begonias 125, Dpto 402');
      expect(updated?.department, '402');
      expect(controller.selectedAddress?.label, 'Casa Familiar');
    });
  });
}
