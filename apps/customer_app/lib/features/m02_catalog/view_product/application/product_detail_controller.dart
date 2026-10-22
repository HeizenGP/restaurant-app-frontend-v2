import 'package:flutter/foundation.dart';

import '../../shared/application/catalog_contracts.dart';
import '../../shared/domain/catalog_models.dart';

enum ProductDetailStatus { initial, loading, success, notFound, error }

@immutable
final class ProductDetailState {
  const ProductDetailState({required this.status, this.product, this.failure});

  const ProductDetailState.initial()
    : this(status: ProductDetailStatus.initial);

  final ProductDetailStatus status;
  final CatalogProduct? product;
  final CatalogFailure? failure;
}

final class ProductDetailController extends ChangeNotifier {
  factory ProductDetailController({
    required CatalogRepository repository,
    required String categoryId,
    required String productId,
  }) {
    return ProductDetailController._(repository, categoryId, productId);
  }

  ProductDetailController._(this._repository, this.categoryId, this.productId);

  final CatalogRepository _repository;
  final String categoryId;
  final String productId;
  ProductDetailState _state = const ProductDetailState.initial();
  int _requestVersion = 0;
  bool _disposed = false;

  ProductDetailState get state => _state;

  Future<void> load() async {
    final int requestVersion = ++_requestVersion;
    _emit(const ProductDetailState(status: ProductDetailStatus.loading));

    try {
      final List<CatalogProduct> products = await _repository.listProducts(
        categoryId,
      );
      if (!_isCurrent(requestVersion)) return;

      CatalogProduct? product;
      for (final CatalogProduct candidate in products) {
        if (candidate.id == productId) {
          product = candidate;
          break;
        }
      }
      if (product == null) {
        _emit(const ProductDetailState(status: ProductDetailStatus.notFound));
        return;
      }
      _emit(
        ProductDetailState(
          status: ProductDetailStatus.success,
          product: product,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(requestVersion)) return;
      final CatalogFailure failure = _safeFailure(error);
      if (failure.kind == CatalogFailureKind.notFound) {
        _emit(
          ProductDetailState(
            status: ProductDetailStatus.notFound,
            failure: failure,
          ),
        );
        return;
      }
      _emit(
        ProductDetailState(status: ProductDetailStatus.error, failure: failure),
      );
    }
  }

  Future<void> retry() => load();

  bool _isCurrent(int requestVersion) {
    return !_disposed && requestVersion == _requestVersion;
  }

  CatalogFailure _safeFailure(Object error) {
    if (error is CatalogFailure) return error;
    return const CatalogFailure(
      CatalogFailureKind.server,
      'No pudimos cargar este producto. Inténtalo nuevamente.',
    );
  }

  void _emit(ProductDetailState value) {
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
