import 'dart:convert';

import 'package:customer_app/features/location_delivery/domain/delivery_coverage.dart';
import 'package:customer_app/features/location_delivery/infrastructure/address_rest_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('KairoDeliveryCoverage', () {
    test('uses Tarapoto as its center', () {
      expect(
        KairoDeliveryCoverage.distanceFromCenterKm(
          KairoDeliveryCoverage.centerLatitude,
          KairoDeliveryCoverage.centerLongitude,
        ),
        closeTo(0, 0.001),
      );
      expect(
        KairoDeliveryCoverage.isTarapotoCenter(
          KairoDeliveryCoverage.centerLatitude,
          KairoDeliveryCoverage.centerLongitude,
        ),
        isTrue,
      );
    });

    test('places the former Lima center far outside Tarapoto coverage', () {
      final double distance = KairoDeliveryCoverage.distanceFromCenterKm(
        -12.0968,
        -77.0353,
      );

      expect(distance, greaterThan(600));
      expect(distance, lessThan(700));
    });
  });

  group('AddressRestRepository coverage compatibility', () {
    test('replaces a legacy Lima quote with Tarapoto coverage', () async {
      final AddressRestRepository repository = AddressRestRepository(
        baseUri: Uri.parse('https://example.test'),
        httpClient: MockClient((http.Request request) async {
          expect(request.url.path, '/api/v1/delivery/check-zone');
          return http.Response(
            jsonEncode(<String, Object>{
              'is_covered': false,
              'distance_km': 628.0,
              'message': 'Fuera de cobertura desde San Isidro.',
              'restaurant_latitude': -12.0968,
              'restaurant_longitude': -77.0353,
            }),
            200,
          );
        }),
      );

      final quote = await repository.checkDeliveryZone(
        KairoDeliveryCoverage.centerLatitude,
        KairoDeliveryCoverage.centerLongitude,
      );

      expect(quote.isCovered, isTrue);
      expect(quote.distanceKm, closeTo(0, 0.001));
      expect(quote.zoneName, contains('Tarapoto'));
      expect(quote.restaurantAddress, contains('Tarapoto'));
    });

    test('keeps a backend quote once its center is Tarapoto', () async {
      final AddressRestRepository repository = AddressRestRepository(
        baseUri: Uri.parse('https://example.test'),
        httpClient: MockClient((http.Request request) async {
          return http.Response(
            jsonEncode(<String, Object>{
              'is_covered': true,
              'distance_km': 1.4,
              'zone_name': 'Tarapoto backend zone',
              'delivery_fee': '7.00',
              'restaurant_latitude': KairoDeliveryCoverage.centerLatitude,
              'restaurant_longitude': KairoDeliveryCoverage.centerLongitude,
            }),
            200,
          );
        }),
      );

      final quote = await repository.checkDeliveryZone(-6.49, -76.37);

      expect(quote.zoneName, 'Tarapoto backend zone');
      expect(quote.deliveryFee, '7.00');
    });
  });
}
