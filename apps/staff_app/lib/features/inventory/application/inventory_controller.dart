import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../products/domain/catalog_models.dart';
import '../domain/inventory_models.dart';
import '../infrastructure/inventory_repository.dart';

class InventoryController extends ChangeNotifier {
  InventoryController({required this.repository});

  final InventoryRepository repository;

  List<Product> _products = <Product>[];
  List<StockMovement> _movements = <StockMovement>[];
  bool _onlyLowStock = false;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Product> get products => _products;
  List<StockMovement> get movements => _movements;
  bool get onlyLowStock => _onlyLowStock;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<Product> get filteredProducts {
    return _products.where((Product p) {
      final bool matchesLowStock =
          !_onlyLowStock || p.isLowStock || p.isOutOfStock;
      final bool matchesSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesLowStock && matchesSearch;
    }).toList();
  }

  Future<void> loadInventory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Product> prods = await repository.getProducts();
      final List<StockMovement> movs = await repository.getMovements();
      _products = prods;
      _movements = movs;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar el inventario.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleOnlyLowStock(bool value) {
    _onlyLowStock = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> adjustStock(String productId, int newQuantity) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Product updated = await repository.adjustStock(
        productId,
        newQuantity,
      );
      final int idx = _products.indexWhere((Product p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = updated;
      }
      // Reload movements audit
      _movements = await repository.getMovements();
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
}
