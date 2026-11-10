import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../domain/table_models.dart';
import '../infrastructure/table_repository.dart';

class TableController extends ChangeNotifier {
  TableController({required this.repository});

  final TableRepository repository;

  List<RestaurantTable> _tables = <RestaurantTable>[];
  String? _selectedArea;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<RestaurantTable> get tables => _tables;
  String? get selectedArea => _selectedArea;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<String> get availableAreas {
    final Set<String> areas = _tables
        .map((RestaurantTable t) => t.area)
        .toSet();
    return areas.toList()..sort();
  }

  List<RestaurantTable> get filteredTables {
    if (_selectedArea == null || _selectedArea!.isEmpty) {
      return _tables;
    }
    return _tables
        .where((RestaurantTable t) => t.area == _selectedArea)
        .toList();
  }

  int get occupiedCount =>
      _tables.where((RestaurantTable t) => t.isOccupied).length;
  int get availableCount => _tables.length - occupiedCount;

  Future<void> loadTables({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _tables = await repository.getTables();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar las mesas del restaurante.';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void selectArea(String? area) {
    _selectedArea = area;
    notifyListeners();
  }

  Future<bool> createTable({required String code, String? areaLabel}) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final RestaurantTable created = await repository.createTable(
        code: code,
        areaLabel: areaLabel,
      );
      _tables = <RestaurantTable>[..._tables, created];
      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleOccupancy(String tableId, bool newOccupancy) async {
    _errorMessage = null;
    try {
      final RestaurantTable updated = await repository.setOccupancy(
        tableId,
        newOccupancy,
      );
      final int idx = _tables.indexWhere(
        (RestaurantTable t) => t.id == tableId,
      );
      if (idx != -1) {
        _tables[idx] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo cambiar el estado de la mesa.';
      notifyListeners();
      return false;
    }
  }
}
