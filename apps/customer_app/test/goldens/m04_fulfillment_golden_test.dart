import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_contracts.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_controller.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/presentation/fulfillment_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(_loadAppFonts);

  for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('04 mode matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final _VisualDependencies dependencies = _VisualDependencies(mode);
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(
        dependencies.harness(
          FulfillmentModePage(
            themeModeController: dependencies.themeModeController,
            controller: dependencies.fulfillmentController,
            onModeSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('fulfillment-mode-local'),
        const Rect.fromLTWH(24, 203, 342, 116),
      );
      _expectRectNear(
        tester,
        const Key('fulfillment-mode-pickup'),
        const Rect.fromLTWH(24, 329, 342, 116),
      );
      _expectRectNear(
        tester,
        const Key('fulfillment-mode-delivery'),
        const Rect.fromLTWH(24, 455, 342, 116),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_fulfillment_04_mode_$suffix.png'),
      );
    });

    testWidgets('05 tables matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final _VisualDependencies dependencies = _VisualDependencies(mode);
      addTearDown(dependencies.dispose);
      await dependencies.fulfillmentController.loadTables();
      dependencies.fulfillmentController.selectTable('table-a-01');

      await tester.pumpWidget(
        dependencies.harness(
          TableSelectionPage(
            themeModeController: dependencies.themeModeController,
            controller: dependencies.fulfillmentController,
            onFinished: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const ValueKey<String>('table-table-a-01'),
        const Rect.fromLTWH(24, 210, 342, 95),
      );
      _expectRectNear(
        tester,
        const ValueKey<String>('table-table-a-02'),
        const Rect.fromLTWH(24, 315, 342, 95),
      );
      _expectRectNear(
        tester,
        const ValueKey<String>('table-table-b-01'),
        const Rect.fromLTWH(24, 420, 342, 95),
      );
      _expectRectNear(
        tester,
        const Key('table-verification-card'),
        const Rect.fromLTWH(24, 557, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('table-finish'),
        const Rect.fromLTWH(24, 659, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_fulfillment_05_tables_$suffix.png'),
      );
    });

    testWidgets('06 pickup matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final _VisualDependencies dependencies = _VisualDependencies(mode);
      addTearDown(dependencies.dispose);
      dependencies.fulfillmentController.chooseMode(FulfillmentMode.pickup);

      await tester.pumpWidget(
        dependencies.harness(
          PickupDetailsPage(
            themeModeController: dependencies.themeModeController,
            controller: dependencies.fulfillmentController,
            onFinished: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('pickup-contact-name'),
        const Rect.fromLTWH(24, 220, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('pickup-contact-phone'),
        const Rect.fromLTWH(24, 323, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('pickup-deposit-card'),
        const Rect.fromLTWH(24, 445, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('pickup-restaurant-card'),
        const Rect.fromLTWH(24, 538, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('pickup-finish'),
        const Rect.fromLTWH(24, 655, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_fulfillment_06_pickup_$suffix.png'),
      );
    });

    testWidgets('07 delivery matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final _VisualDependencies dependencies = _VisualDependencies(mode);
      addTearDown(dependencies.dispose);
      dependencies.fulfillmentController.chooseMode(FulfillmentMode.delivery);

      await tester.pumpWidget(
        dependencies.harness(
          DeliveryDetailsPage(
            themeModeController: dependencies.themeModeController,
            controller: dependencies.fulfillmentController,
            onFinished: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('delivery-address'),
        const Rect.fromLTWH(24, 205, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('delivery-contact-name'),
        const Rect.fromLTWH(24, 313, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('delivery-contact-phone'),
        const Rect.fromLTWH(24, 421, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('delivery-deposit-card'),
        const Rect.fromLTWH(24, 544, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('delivery-finish'),
        const Rect.fromLTWH(24, 655, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_fulfillment_07_delivery_$suffix.png'),
      );
    });
  }
}

void _expectRectNear(
  WidgetTester tester,
  Key key,
  Rect expected, {
  double tolerance = 1.5,
}) {
  final Rect actual = tester.getRect(find.byKey(key));
  expect(actual.left, closeTo(expected.left, tolerance), reason: '$key left');
  expect(actual.top, closeTo(expected.top, tolerance), reason: '$key top');
  expect(
    actual.width,
    closeTo(expected.width, tolerance),
    reason: '$key width',
  );
  expect(
    actual.height,
    closeTo(expected.height, tolerance),
    reason: '$key height',
  );
}

void _expectNoBottomNavigation() {
  expect(find.byType(CustomerBottomNavigation), findsNothing);
  expect(find.byType(NavigationBar), findsNothing);
}

const Key _boundaryKey = Key('m04-fulfillment-golden');

class _VisualDependencies {
  _VisualDependencies(ThemeMode mode)
    : themeModeController = ThemeModeController(initialMode: mode),
      fulfillmentController = FulfillmentController(
        tablesRepository: const _TablesVisualRepository(),
      ),
      _mode = mode;

  final ThemeModeController themeModeController;
  final FulfillmentController fulfillmentController;
  final ThemeMode _mode;

  Widget harness(Widget child) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _mode,
        home: child,
      ),
    );
  }

  void dispose() {
    fulfillmentController.dispose();
    themeModeController.dispose();
  }
}

// Verified Figma sample content is confined to this visual fixture. Production
// still reads identifiers, codes, labels and occupancy from GET /tables.
class _TablesVisualRepository implements TablesRepository {
  const _TablesVisualRepository();

  @override
  Future<List<RestaurantTable>> listTables() async {
    return const <RestaurantTable>[
      RestaurantTable(
        id: 'table-a-01',
        code: 'A-01',
        areaLabel: 'Zona principal',
        isOccupied: false,
      ),
      RestaurantTable(
        id: 'table-a-02',
        code: 'A-02',
        areaLabel: 'Zona principal',
        isOccupied: true,
      ),
      RestaurantTable(
        id: 'table-b-01',
        code: 'B-01',
        areaLabel: 'Zona secundaria',
        isOccupied: false,
      ),
    ];
  }
}

Future<void> _configureFigmaViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.padding = const FakeViewPadding();
  addTearDown(tester.view.reset);
}

Future<void> _loadAppFonts() async {
  final FontLoader bodyFont = FontLoader('DM Sans')
    ..addFont(rootBundle.load('assets/fonts/DMSans-Variable.ttf'));
  final FontLoader displayFont = FontLoader('Cormorant Garamond')
    ..addFont(rootBundle.load('assets/fonts/CormorantGaramond-Variable.ttf'));
  final FontLoader lucideFont =
      FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      );
  await Future.wait(<Future<void>>[
    bodyFont.load(),
    displayFont.load(),
    lucideFont.load(),
  ]);
}
