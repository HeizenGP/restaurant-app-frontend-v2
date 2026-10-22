import 'package:flutter/foundation.dart';

import '../../shared/application/catalog_contracts.dart';
import '../../shared/domain/catalog_models.dart';

enum CatalogStatus { initial, loading, success, failure }

enum CatalogFailureScope { categories, products }

@immutable
final class CatalogState {
  const CatalogState({
    required this.status,
    this.categories = const <CatalogCategory>[],
    this.selectedCategoryId,
    this.products = const <CatalogProduct>[],
    this.failure,
    this.failureScope,
  });

  const CatalogState.initial() : this(status: CatalogStatus.initial);

  final CatalogStatus status;
  final List<CatalogCategory> categories;
  final String? selectedCategoryId;
  final List<CatalogProduct> products;
  final CatalogFailure? failure;
  final CatalogFailureScope? failureScope;

  bool get hasEmptyCatalog {
    return status == CatalogStatus.success && categories.isEmpty;
  }

  bool get hasEmptyCategory {
    return status == CatalogStatus.success &&
        selectedCategoryId != null &&
        products.isEmpty;
  }

  CatalogCategory? get selectedCategory {
    for (final CatalogCategory category in categories) {
      if (category.id == selectedCategoryId) return category;
    }
    return null;
  }
}

final class CatalogController extends ChangeNotifier {
  factory CatalogController({required CatalogRepository repository}) {
    return CatalogController._(repository);
  }

  CatalogController._(this._repository);

  final CatalogRepository _repository;
  CatalogState _state = const CatalogState.initial();
  int _requestVersion = 0;
  bool _disposed = false;

  CatalogState get state => _state;

  Future<void> load() => loadCatalog();

  Future<void> loadCatalog() async {
    final int requestVersion = ++_requestVersion;
    final String? preferredCategoryId = _state.selectedCategoryId;
    _emit(
      CatalogState(
        status: CatalogStatus.loading,
        categories: _state.categories,
        selectedCategoryId: preferredCategoryId,
        products: _state.products,
      ),
    );

    final List<CatalogCategory> categories;
    try {
      categories = List<CatalogCategory>.unmodifiable(
        await _repository.listCategories(),
      );
    } on Object catch (error) {
      if (!_isCurrent(requestVersion)) return;
      _emit(
        CatalogState(
          status: CatalogStatus.failure,
          categories: _state.categories,
          selectedCategoryId: _state.selectedCategoryId,
          products: _state.products,
          failure: _safeFailure(error),
          failureScope: CatalogFailureScope.categories,
        ),
      );
      return;
    }
    if (!_isCurrent(requestVersion)) return;

    if (categories.isEmpty) {
      _emit(
        const CatalogState(
          status: CatalogStatus.success,
          categories: <CatalogCategory>[],
          products: <CatalogProduct>[],
        ),
      );
      return;
    }

    final String selectedCategoryId =
        categories.any(
          (CatalogCategory category) => category.id == preferredCategoryId,
        )
        ? preferredCategoryId!
        : categories.first.id;
    await _loadProducts(
      categoryId: selectedCategoryId,
      categories: categories,
      requestVersion: requestVersion,
    );
  }

  Future<void> selectCategory(String categoryId) async {
    if (!_state.categories.any(
      (CatalogCategory category) => category.id == categoryId,
    )) {
      return;
    }
    if (_state.selectedCategoryId == categoryId &&
        (_state.status == CatalogStatus.success ||
            _state.status == CatalogStatus.loading)) {
      return;
    }

    final int requestVersion = ++_requestVersion;
    await _loadProducts(
      categoryId: categoryId,
      categories: _state.categories,
      requestVersion: requestVersion,
    );
  }

  Future<void> retry() async {
    if (_state.status != CatalogStatus.failure) return;
    final String? categoryId = _state.selectedCategoryId;
    if (_state.failureScope == CatalogFailureScope.products &&
        categoryId != null) {
      await selectCategory(categoryId);
      return;
    }
    await loadCatalog();
  }

  Future<void> _loadProducts({
    required String categoryId,
    required List<CatalogCategory> categories,
    required int requestVersion,
  }) async {
    _emit(
      CatalogState(
        status: CatalogStatus.loading,
        categories: List<CatalogCategory>.unmodifiable(categories),
        selectedCategoryId: categoryId,
      ),
    );

    try {
      final List<CatalogProduct> products = List<CatalogProduct>.unmodifiable(
        await _repository.listProducts(categoryId),
      );
      if (!_isCurrent(requestVersion)) return;
      _emit(
        CatalogState(
          status: CatalogStatus.success,
          categories: List<CatalogCategory>.unmodifiable(categories),
          selectedCategoryId: categoryId,
          products: products,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(requestVersion)) return;
      _emit(
        CatalogState(
          status: CatalogStatus.failure,
          categories: List<CatalogCategory>.unmodifiable(categories),
          selectedCategoryId: categoryId,
          failure: _safeFailure(error),
          failureScope: CatalogFailureScope.products,
        ),
      );
    }
  }

  bool _isCurrent(int requestVersion) {
    return !_disposed && requestVersion == _requestVersion;
  }

  CatalogFailure _safeFailure(Object error) {
    if (error is CatalogFailure) return error;
    return const CatalogFailure(
      CatalogFailureKind.server,
      'No pudimos cargar el catálogo. Inténtalo nuevamente.',
    );
  }

  void _emit(CatalogState value) {
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
