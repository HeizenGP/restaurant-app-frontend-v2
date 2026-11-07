import 'dart:async';

import 'package:customer_app/core/design_system/theme/asia_theme.dart';
import 'package:customer_app/features/location_delivery/application/location_delivery_controller.dart';
import 'package:customer_app/features/location_delivery/domain/location_models.dart';
import 'package:customer_app/features/location_delivery/presentation/address_selector_modal.dart';
import 'package:customer_app/features/location_delivery/presentation/map_location_picker_page.dart';
import 'package:customer_app/features/location_delivery/presentation/widgets/home_delivery_bar.dart';
import 'package:customer_app/features/m01_access/profile/domain/profile_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'location_delivery_controller_test.dart';

void main() {
  group('Location Delivery Widgets', () {
    testWidgets('HomeDeliveryBar renders selected address label and address', (
      WidgetTester tester,
    ) async {
      final FakeAddressRestRepository repo = FakeAddressRestRepository(
        initialAddresses: const <CustomerAddress>[
          CustomerAddress(
            id: 'addr-home',
            label: 'Casa',
            address: 'Av. Las Begonias 123, San Isidro',
            latitude: -12.0968,
            longitude: -77.0353,
            isDefault: true,
          ),
        ],
      );

      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: repo,
        locationService: const FakeLocationService(),
      );
      await controller.initialize();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: const <ThemeExtension<dynamic>>[AsiaTheme.light],
          ),
          home: Scaffold(body: HomeDeliveryBar(controller: controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ENTREGAR EN'), findsOneWidget);
      expect(find.textContaining('Casa: Av. Las Begonias 123'), findsOneWidget);
    });

    testWidgets('AddressSelectorModal displays saved addresses list', (
      WidgetTester tester,
    ) async {
      final FakeAddressRestRepository repo = FakeAddressRestRepository(
        initialAddresses: const <CustomerAddress>[
          CustomerAddress(
            id: 'addr-home',
            label: 'Casa',
            address: 'Av. Las Begonias 123',
            isDefault: true,
          ),
          CustomerAddress(
            id: 'addr-work',
            label: 'Trabajo',
            address: 'Av. Rivera Navarrete 500',
            isDefault: false,
          ),
        ],
      );

      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: repo,
        locationService: const FakeLocationService(),
      );
      await controller.initialize();

      CustomerAddress? selected;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: const <ThemeExtension<dynamic>>[AsiaTheme.light],
          ),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    AddressSelectorModal.show(
                      context,
                      controller: controller,
                      onAddressSelected: (CustomerAddress addr) {
                        selected = addr;
                      },
                    );
                  },
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Dirección de entrega'), findsOneWidget);
      expect(find.text('Casa'), findsOneWidget);
      expect(find.text('Trabajo'), findsOneWidget);
      expect(find.text('Principal'), findsOneWidget);

      await tester.tap(find.text('Trabajo'));
      await tester.pumpAndSettle();

      expect(selected?.id, 'addr-work');
    });

    testWidgets(
      'MapLocationPickerPage renders search bar and interactive buttons',
      (WidgetTester tester) async {
        final FakeAddressRestRepository repo = FakeAddressRestRepository();
        final LocationDeliveryController controller =
            LocationDeliveryController(
              addressRepository: repo,
              locationService: const FakeLocationService(),
            );
        await controller.initialize();

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light().copyWith(
              extensions: const <ThemeExtension<dynamic>>[AsiaTheme.light],
            ),
            home: MapLocationPickerPage(controller: controller),
          ),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey<String>('map-search-field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey<String>('map-location-sheet')),
          findsOneWidget,
        );
        final Size pageSize = tester.getSize(
          find.byKey(const ValueKey<String>('map-location-picker-page')),
        );
        await tester.dragFrom(
          Offset(pageSize.width / 2, pageSize.height - 36),
          const Offset(0, -260),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey<String>('map-confirm-location')),
          findsOneWidget,
        );

        // Verify Map Layer Style toggle button is present
        expect(
          find.byKey(const ValueKey<String>('map-style-control')),
          findsOneWidget,
        );

        // Tap layers button to open Tipo de mapa selector
        await tester.tap(
          find.byKey(const ValueKey<String>('map-style-control')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tipo de mapa'), findsOneWidget);
        expect(find.text('Vectorial'), findsOneWidget);
        expect(find.text('Satélite'), findsOneWidget);

        // Tap Satélite option
        await tester.tap(find.text('Satélite'));
        await tester.pumpAndSettle();

        // Modal closed, layer button now shows satellite icon
        expect(find.text('Tipo de mapa'), findsNothing);
        expect(find.byIcon(LucideIcons.satellite), findsOneWidget);
      },
    );

    testWidgets('map picker remains usable in dark mode and compact height', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: FakeAddressRestRepository(),
        locationService: const FakeLocationService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AsiaAppTheme.dark,
          home: MapLocationPickerPage(controller: controller),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey<String>('map-control-rail')),
        findsOneWidget,
      );
      final Size pageSize = tester.getSize(
        find.byKey(const ValueKey<String>('map-location-picker-page')),
      );
      await tester.dragFrom(
        Offset(pageSize.width / 2, pageSize.height - 36),
        const Offset(0, -260),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('map-reference-field')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('map-locate-me')),
        findsOneWidget,
      );
    });

    testWidgets('ignores an obsolete autocomplete response', (
      WidgetTester tester,
    ) async {
      final _OutOfOrderSearchRepository repo = _OutOfOrderSearchRepository();
      final LocationDeliveryController controller = LocationDeliveryController(
        addressRepository: repo,
        locationService: const FakeLocationService(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AsiaAppTheme.light,
          home: MapLocationPickerPage(controller: controller),
        ),
      );
      await tester.pump();

      final Finder search = find.byKey(
        const ValueKey<String>('map-search-field'),
      );
      await tester.tap(search);
      await tester.enterText(search, 'primera');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.enterText(search, 'segunda');
      await tester.pump(const Duration(milliseconds: 400));

      repo.second.complete(const <GeocodedAddress>[
        GeocodedAddress(
          displayName: 'Segunda dirección, Lima',
          address: 'Segunda dirección',
          district: 'Lima',
          latitude: -12.09,
          longitude: -77.03,
        ),
      ]);
      await tester.pump();
      repo.first.complete(const <GeocodedAddress>[
        GeocodedAddress(
          displayName: 'Primera dirección, Lima',
          address: 'Primera dirección',
          district: 'Lima',
          latitude: -12.08,
          longitude: -77.02,
        ),
      ]);
      await tester.pump();

      expect(find.text('Segunda dirección'), findsOneWidget);
      expect(find.text('Primera dirección'), findsNothing);
    });
  });
}

class _OutOfOrderSearchRepository extends FakeAddressRestRepository {
  final Completer<List<GeocodedAddress>> first =
      Completer<List<GeocodedAddress>>();
  final Completer<List<GeocodedAddress>> second =
      Completer<List<GeocodedAddress>>();

  @override
  Future<List<GeocodedAddress>> searchAddresses(
    String query, {
    double? proximityLat,
    double? proximityLon,
  }) {
    return query == 'primera' ? first.future : second.future;
  }
}
