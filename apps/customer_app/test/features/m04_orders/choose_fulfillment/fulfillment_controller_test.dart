import 'dart:async';

import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_contracts.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_controller.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads tables without selecting a table implicitly', () async {
    final _FakeTablesRepository repository = _FakeTablesRepository();
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: repository,
    );
    addTearDown(controller.dispose);

    await controller.loadTables();

    expect(controller.state.tablesStatus, TablesStatus.success);
    expect(controller.state.tables, _tables);
    expect(controller.state.selectedTable, isNull);
    expect(repository.calls, 1);
  });

  test('occupied tables cannot be selected or completed', () async {
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: _FakeTablesRepository(),
    );
    addTearDown(controller.dispose);
    await controller.loadTables();

    controller.selectTable('occupied');
    expect(controller.state.selectedTableId, isNull);

    controller.selectTable('available');
    expect(
      controller.completeLocal(),
      FulfillmentDraft.local(tableId: 'available'),
    );
  });

  test('exposes failure and retry replaces it with an empty success', () async {
    final _FakeTablesRepository repository = _FakeTablesRepository()
      ..handler = () async {
        throw const TablesFailure(TablesFailureKind.network, 'Sin conexión.');
      };
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: repository,
    );
    addTearDown(controller.dispose);

    await controller.loadTables();
    expect(controller.state.tablesStatus, TablesStatus.failure);
    expect(controller.state.tablesFailure?.kind, TablesFailureKind.network);

    repository.handler = () async => const <RestaurantTable>[];
    await controller.retryTables();
    expect(controller.state.tablesStatus, TablesStatus.success);
    expect(controller.state.tables, isEmpty);
  });

  test('ignores a stale tables response', () async {
    final Completer<List<RestaurantTable>> first =
        Completer<List<RestaurantTable>>();
    final _FakeTablesRepository repository = _FakeTablesRepository()
      ..handler = () => first.future;
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: repository,
    );
    addTearDown(controller.dispose);

    final Future<void> pending = controller.loadTables();
    controller.clear();
    first.complete(_tables);
    await pending;

    expect(controller.state.tablesStatus, TablesStatus.initial);
    expect(controller.state.tables, isEmpty);
  });

  test('creates only valid trimmed pickup and delivery drafts', () {
    final FulfillmentController controller = FulfillmentController(
      tablesRepository: _FakeTablesRepository(),
    );
    addTearDown(controller.dispose);

    expect(
      controller.completePickup(contactName: ' ', contactPhone: '999'),
      isNull,
    );
    expect(
      controller.completePickup(
        contactName: ' Rosa ',
        contactPhone: ' 999 000 ',
      ),
      FulfillmentDraft.pickup(contactName: 'Rosa', contactPhone: '999 000'),
    );
    expect(
      controller.completeDelivery(
        deliveryAddress: ' Av. Asia 10 ',
        contactName: ' Luis ',
        contactPhone: ' 988 ',
      ),
      FulfillmentDraft.delivery(
        deliveryAddress: 'Av. Asia 10',
        contactName: 'Luis',
        contactPhone: '988',
      ),
    );
  });
}

const List<RestaurantTable> _tables = <RestaurantTable>[
  RestaurantTable(
    id: 'occupied',
    code: 'A-01',
    areaLabel: 'Zona principal',
    isOccupied: true,
  ),
  RestaurantTable(
    id: 'available',
    code: 'B-01',
    areaLabel: null,
    isOccupied: false,
  ),
];

final class _FakeTablesRepository implements TablesRepository {
  Future<List<RestaurantTable>> Function()? handler;
  int calls = 0;

  @override
  Future<List<RestaurantTable>> listTables() async {
    calls += 1;
    return await handler?.call() ?? _tables;
  }
}
