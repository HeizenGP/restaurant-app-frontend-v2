import 'dart:async';

import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_contracts.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_controller.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/presentation/fulfillment_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('mode screen stores the selected mode and exposes navigation', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester, const Size(390, 844));
    final _FakeTablesRepository repository = _FakeTablesRepository();
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: repository,
    );
    final ThemeModeController themeController = ThemeModeController();
    FulfillmentMode? selected;
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        FulfillmentModePage(
          themeModeController: themeController,
          controller: controller,
          onModeSelected: (FulfillmentMode value) => selected = value,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('fulfillment-mode-delivery')));

    expect(selected, FulfillmentMode.delivery);
    expect(controller.state.mode, FulfillmentMode.delivery);
    expect(find.text('¿Cómo disfrutarás?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tables render real fields and occupied rows stay disabled', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester, const Size(390, 844));
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: _FakeTablesRepository(),
    );
    final ThemeModeController themeController = ThemeModeController();
    FulfillmentDraft? finished;
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        TableSelectionPage(
          themeModeController: themeController,
          controller: controller,
          onFinished: (FulfillmentDraft value) => finished = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mesa A-01'), findsOneWidget);
    expect(find.text('Zona principal · ocupada'), findsOneWidget);
    final Finder occupied = find.byKey(const ValueKey<String>('table-t1'));
    expect(
      find.descendant(of: occupied, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(controller.state.selectedTableId, isNull);

    await tester.tap(find.byKey(const ValueKey<String>('table-t2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('table-finish')));
    expect(finished, FulfillmentDraft.local(tableId: 't2'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tables in grid mode render 2 square columns with Lucide icons', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester, const Size(390, 844));
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: _FakeTablesRepository(),
    );
    final ThemeModeController themeController = ThemeModeController();
    FulfillmentDraft? finished;
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        TableSelectionPage(
          themeModeController: themeController,
          controller: controller,
          useGrid: true,
          onFinished: (FulfillmentDraft value) => finished = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mesa A-01'), findsOneWidget);
    expect(find.text('OCUPADA'), findsOneWidget);
    expect(find.text('DISPONIBLE'), findsOneWidget);
    expect(find.byIcon(LucideIcons.ban), findsOneWidget);
    expect(find.byIcon(LucideIcons.armchair), findsOneWidget);

    // Occupied table t1 cannot be tapped
    await tester.tap(find.byKey(const ValueKey<String>('table-t1')));
    await tester.pump();
    expect(controller.state.selectedTableId, isNull);

    // Available table t2 can be selected and finished
    await tester.tap(find.byKey(const ValueKey<String>('table-t2')));
    await tester.pump();
    expect(controller.state.selectedTableId, 't2');
    expect(find.text('SELECCIONADA'), findsOneWidget);

    await tester.tap(find.byKey(const Key('table-finish')));
    expect(finished, FulfillmentDraft.local(tableId: 't2'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tables expose loading, retry and empty states', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester, const Size(390, 844));
    final Completer<List<RestaurantTable>> pending =
        Completer<List<RestaurantTable>>();
    final _FakeTablesRepository repository = _FakeTablesRepository()
      ..handler = () => pending.future;
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: repository,
    );
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        TableSelectionPage(
          themeModeController: themeController,
          controller: controller,
          onFinished: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('tables-loading-state')), findsOneWidget);

    pending.completeError(
      const TablesFailure(TablesFailureKind.network, 'Sin conexión.'),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tables-error-state')), findsOneWidget);

    repository.handler = () async => const <RestaurantTable>[];
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tables-empty-state')), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('pickup validates and returns trimmed real fields', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester, const Size(390, 844));
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: _FakeTablesRepository(),
    );
    final ThemeModeController themeController = ThemeModeController();
    FulfillmentDraft? finished;
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        PickupDetailsPage(
          themeModeController: themeController,
          controller: controller,
          onFinished: (FulfillmentDraft value) => finished = value,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('pickup-finish')));
    await tester.pump();
    expect(find.text('Ingresa el nombre de contacto.'), findsOneWidget);
    expect(finished, isNull);

    await tester.enterText(
      find.byKey(const Key('pickup-contact-name')),
      ' Rosa ',
    );
    await tester.enterText(
      find.byKey(const Key('pickup-contact-phone')),
      ' 999 000 ',
    );
    await tester.ensureVisible(find.byKey(const Key('pickup-finish')));
    await tester.tap(find.byKey(const Key('pickup-finish')));
    await tester.pump();

    expect(
      finished,
      FulfillmentDraft.pickup(contactName: 'Rosa', contactPhone: '999 000'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('delivery stays scrollable on a compact Android viewport', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: _FakeTablesRepository(),
    );
    final ThemeModeController themeController = ThemeModeController();
    FulfillmentDraft? finished;
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        DeliveryDetailsPage(
          themeModeController: themeController,
          controller: controller,
          onFinished: (FulfillmentDraft value) => finished = value,
        ),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('delivery-address')),
      'Av. Asia 10',
    );
    await tester.enterText(
      find.byKey(const Key('delivery-contact-name')),
      'Luis',
    );
    await tester.enterText(
      find.byKey(const Key('delivery-contact-phone')),
      '988',
    );
    await tester.ensureVisible(find.byKey(const Key('delivery-finish')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delivery-finish')));
    await tester.pump();

    expect(
      finished,
      FulfillmentDraft.delivery(
        deliveryAddress: 'Av. Asia 10',
        contactName: 'Luis',
        contactPhone: '988',
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: child,
  );
}

Future<void> _configureSurface(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);
}

const List<RestaurantTable> _tables = <RestaurantTable>[
  RestaurantTable(
    id: 't1',
    code: 'A-01',
    areaLabel: 'Zona principal',
    isOccupied: true,
  ),
  RestaurantTable(id: 't2', code: 'B-01', areaLabel: null, isOccupied: false),
];

final class _FakeTablesRepository implements TablesRepository {
  Future<List<RestaurantTable>> Function()? handler;
  int calls = 0;

  @override
  Future<List<RestaurantTable>> listTables() {
    calls += 1;
    return handler?.call() ?? Future<List<RestaurantTable>>.value(_tables);
  }
}
