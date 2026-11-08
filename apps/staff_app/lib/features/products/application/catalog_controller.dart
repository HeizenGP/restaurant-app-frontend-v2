import 'package:flutter/foundation.dart' hide Category;
import '../../../core/network/api_client.dart';
import '../domain/catalog_models.dart';
import '../infrastructure/catalog_repository.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({required this.repository});

  final CatalogRepository repository;

  List<Category> _categories = <Category>[];
  List<Product> _products = <Product>[];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Category> get categories => _categories;
  List<Product> get products => _products;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<Product> get filteredProducts {
    return _products.where((Product p) {
      final bool matchesCategory = _selectedCategoryId == null ||
          _selectedCategoryId!.isEmpty ||
          p.categoryId == _selectedCategoryId;
      final bool matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Category> cats = await repository.getCategories();
      final List<Product> prods = await repository.getProducts();
      _categories = cats;
      _products = prods;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar el catálogo de productos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> createCategory(String name) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Category category = await repository.createCategory(name);
      _categories = <Category>[..._categories, category];
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

  Future<bool> renameCategory(String categoryId, String name) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Category category = await repository.renameCategory(categoryId, name);
      final int idx = _categories.indexWhere((Category c) => c.id == categoryId);
      if (idx != -1) {
        _categories[idx] = category;
      }
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

  Future<bool> saveProduct({
    String? productId,
    required String categoryId,
    required String name,
    required double price,
    int? initialStock,
    String? imageUrl,
    String? description,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (productId == null) {
        final Product created = await repository.createProduct(
          categoryId: categoryId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          description: description,
        );
        if (initialStock != null && initialStock > 0) {
          final Product updated =
              await repository.setProductStock(created.id, initialStock);
          _products = <Product>[..._products, updated];
        } else {
          _products = <Product>[..._products, created];
        }
      } else {
        final Product updated = await repository.updateProduct(
          productId,
          categoryId: categoryId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          description: description,
        );
        final int idx = _products.indexWhere((Product p) => p.id == productId);
        if (idx != -1) {
          _products[idx] = updated;
        }
      }
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

  Future<bool> updateStock(String productId, int newQuantity) async {
    try {
      final Product updated = await repository.setProductStock(productId, newQuantity);
      final int idx = _products.indexWhere((Product p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleAvailability(String productId, bool isAvailable) async {
    try {
      final Product updated =
          await repository.setProductAvailability(productId, isAvailable);
      final int idx = _products.indexWhere((Product p) => p.id == productId);
      if (idx != -1) {
        _products[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
