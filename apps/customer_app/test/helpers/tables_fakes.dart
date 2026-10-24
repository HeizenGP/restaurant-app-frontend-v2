import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_contracts.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';

const RestaurantTable availableTable = RestaurantTable(
  id: 'table-1',
  code: 'A-01',
  areaLabel: 'Zona principal',
  isOccupied: false,
);

const RestaurantTable occupiedTable = RestaurantTable(
  id: 'table-2',
  code: 'A-02',
  areaLabel: 'Zona principal',
  isOccupied: true,
);

final class FakeTablesRepository implements TablesRepository {
  FakeTablesRepository({
    this.tables = const <RestaurantTable>[availableTable, occupiedTable],
  });

  final List<RestaurantTable> tables;
  int listCalls = 0;

  @override
  Future<List<RestaurantTable>> listTables() async {
    listCalls += 1;
    return tables;
  }
}
