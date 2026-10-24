import 'package:flutter/foundation.dart';

import '../domain/fulfillment_models.dart';
import 'fulfillment_contracts.dart';

enum TablesStatus { initial, loading, success, failure }

@immutable
final class FulfillmentState {
  const FulfillmentState({
    this.mode,
    this.draft,
    this.tablesStatus = TablesStatus.initial,
    this.tables = const <RestaurantTable>[],
    this.selectedTableId,
    this.tablesFailure,
  });

  final FulfillmentMode? mode;
  final FulfillmentDraft? draft;
  final TablesStatus tablesStatus;
  final List<RestaurantTable> tables;
  final String? selectedTableId;
  final TablesFailure? tablesFailure;

  RestaurantTable? get selectedTable {
    for (final RestaurantTable table in tables) {
      if (table.id == selectedTableId) return table;
    }
    return null;
  }
}

final class FulfillmentController extends ChangeNotifier {
  FulfillmentController({required TablesRepository tablesRepository})
    : this._(tablesRepository);

  FulfillmentController._(this._tablesRepository);

  final TablesRepository _tablesRepository;
  FulfillmentState _state = const FulfillmentState();
  int _requestVersion = 0;
  bool _disposed = false;

  FulfillmentState get state => _state;

  void chooseMode(FulfillmentMode mode) {
    _emit(
      FulfillmentState(
        mode: mode,
        draft: _state.draft?.mode == mode ? _state.draft : null,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: mode == FulfillmentMode.local
            ? _state.selectedTableId
            : null,
      ),
    );
  }

  Future<void> loadTables() async {
    final int requestVersion = ++_requestVersion;
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.local,
        tablesStatus: TablesStatus.loading,
        tables: _state.tables,
        selectedTableId: _state.selectedTableId,
      ),
    );

    try {
      final List<RestaurantTable> tables = List<RestaurantTable>.unmodifiable(
        await _tablesRepository.listTables(),
      );
      if (!_isCurrent(requestVersion)) return;

      String? selectedTableId;
      final RestaurantTable? current = _findTable(
        tables,
        _state.selectedTableId,
      );
      if (current != null && current.isAvailable) {
        selectedTableId = current.id;
      }

      _emit(
        FulfillmentState(
          mode: FulfillmentMode.local,
          tablesStatus: TablesStatus.success,
          tables: tables,
          selectedTableId: selectedTableId,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(requestVersion)) return;
      _emit(
        FulfillmentState(
          mode: FulfillmentMode.local,
          tablesStatus: TablesStatus.failure,
          tables: _state.tables,
          selectedTableId: _state.selectedTableId,
          tablesFailure: _safeFailure(error),
        ),
      );
    }
  }

  Future<void> retryTables() => loadTables();

  void selectTable(String tableId) {
    final RestaurantTable? table = _findTable(_state.tables, tableId);
    if (table == null || !table.isAvailable) return;
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.local,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: table.id,
      ),
    );
  }

  FulfillmentDraft? completeLocal() {
    final RestaurantTable? table = _state.selectedTable;
    if (table == null || !table.isAvailable) return null;
    final FulfillmentDraft draft = FulfillmentDraft.local(tableId: table.id);
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.local,
        draft: draft,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: table.id,
      ),
    );
    return draft;
  }

  FulfillmentDraft? completePickup({
    required String contactName,
    required String contactPhone,
  }) {
    if (FulfillmentValidators.contactName(contactName) != null ||
        FulfillmentValidators.contactPhone(contactPhone) != null) {
      return null;
    }
    final FulfillmentDraft draft = FulfillmentDraft.pickup(
      contactName: contactName,
      contactPhone: contactPhone,
    );
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.pickup,
        draft: draft,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
      ),
    );
    return draft;
  }

  FulfillmentDraft? completeDelivery({
    required String deliveryAddress,
    required String contactName,
    required String contactPhone,
  }) {
    if (FulfillmentValidators.deliveryAddress(deliveryAddress) != null ||
        FulfillmentValidators.contactName(contactName) != null ||
        FulfillmentValidators.contactPhone(contactPhone) != null) {
      return null;
    }
    final FulfillmentDraft draft = FulfillmentDraft.delivery(
      deliveryAddress: deliveryAddress,
      contactName: contactName,
      contactPhone: contactPhone,
    );
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.delivery,
        draft: draft,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
      ),
    );
    return draft;
  }

  void clear() {
    _requestVersion += 1;
    _emit(const FulfillmentState());
  }

  RestaurantTable? _findTable(List<RestaurantTable> tables, String? tableId) {
    if (tableId == null) return null;
    for (final RestaurantTable table in tables) {
      if (table.id == tableId) return table;
    }
    return null;
  }

  TablesFailure _safeFailure(Object error) {
    if (error is TablesFailure) return error;
    return const TablesFailure(
      TablesFailureKind.server,
      'No pudimos cargar las mesas. Inténtalo nuevamente.',
    );
  }

  bool _isCurrent(int requestVersion) {
    return !_disposed && requestVersion == _requestVersion;
  }

  void _emit(FulfillmentState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion += 1;
    super.dispose();
  }
}
