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
    this.assignedTableId,
    this.tablesFailure,
  });

  final FulfillmentMode? mode;
  final FulfillmentDraft? draft;
  final TablesStatus tablesStatus;
  final List<RestaurantTable> tables;
  final String? selectedTableId;
  final String? assignedTableId;
  final TablesFailure? tablesFailure;

  bool get hasAssignedTable =>
      assignedTableId != null && assignedTableId!.isNotEmpty;

  RestaurantTable? get assignedTable {
    if (assignedTableId == null) return null;
    for (final RestaurantTable table in tables) {
      if (table.id == assignedTableId) return table;
    }
    return null;
  }

  RestaurantTable? get selectedTable {
    final String? effectiveId = selectedTableId ?? assignedTableId;
    for (final RestaurantTable table in tables) {
      if (table.id == effectiveId) return table;
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
            ? (_state.selectedTableId ?? _state.assignedTableId)
            : null,
        assignedTableId: _state.assignedTableId,
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
        selectedTableId: _state.selectedTableId ?? _state.assignedTableId,
        assignedTableId: _state.assignedTableId,
      ),
    );

    try {
      final List<RestaurantTable> tables = List<RestaurantTable>.unmodifiable(
        await _tablesRepository.listTables(),
      );
      if (!_isCurrent(requestVersion)) return;

      String? selectedTableId;
      final String? targetId =
          _state.assignedTableId ?? _state.selectedTableId;
      final RestaurantTable? current = _findTable(tables, targetId);
      if (current != null && (current.isAvailable || current.id == _state.assignedTableId)) {
        selectedTableId = current.id;
      }

      _emit(
        FulfillmentState(
          mode: FulfillmentMode.local,
          tablesStatus: TablesStatus.success,
          tables: tables,
          selectedTableId: selectedTableId,
          assignedTableId: _state.assignedTableId,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(requestVersion)) return;
      _emit(
        FulfillmentState(
          mode: FulfillmentMode.local,
          tablesStatus: TablesStatus.failure,
          tables: _state.tables,
          selectedTableId: _state.selectedTableId ?? _state.assignedTableId,
          assignedTableId: _state.assignedTableId,
          tablesFailure: _safeFailure(error),
        ),
      );
    }
  }

  Future<void> retryTables() => loadTables();

  void selectTable(String tableId) {
    if (_state.hasAssignedTable && _state.assignedTableId != tableId) {
      return;
    }
    final RestaurantTable? table = _findTable(_state.tables, tableId);
    if (table == null) return;
    if (!table.isAvailable && table.id != _state.assignedTableId) return;
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.local,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: table.id,
        assignedTableId: _state.assignedTableId,
      ),
    );
  }

  FulfillmentDraft? completeLocal() {
    final RestaurantTable? table = _state.selectedTable;
    if (table == null) return null;
    if (!table.isAvailable && table.id != _state.assignedTableId) return null;
    final FulfillmentDraft draft = FulfillmentDraft.local(tableId: table.id);
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.local,
        draft: draft,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: table.id,
        assignedTableId: table.id,
      ),
    );
    return draft;
  }

  void lockAssignedTable(String tableId) {
    _emit(
      FulfillmentState(
        mode: FulfillmentMode.local,
        draft: _state.draft,
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: tableId,
        assignedTableId: tableId,
      ),
    );
  }

  void releaseAssignedTable() {
    _emit(
      FulfillmentState(
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: null,
        assignedTableId: null,
      ),
    );
  }

  void clearDraft() {
    _emit(
      FulfillmentState(
        tablesStatus: _state.tablesStatus,
        tables: _state.tables,
        selectedTableId: _state.assignedTableId,
        assignedTableId: _state.assignedTableId,
      ),
    );
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
