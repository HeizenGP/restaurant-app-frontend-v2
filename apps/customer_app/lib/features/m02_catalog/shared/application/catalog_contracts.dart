import '../domain/catalog_models.dart';

abstract interface class CatalogRepository {
  Future<List<CatalogCategory>> listCategories();

  Future<List<CatalogProduct>> listProducts(String categoryId);
}

enum CatalogFailureKind {
  timeout,
  network,
  notFound,
  validation,
  server,
  malformedResponse,
}

final class CatalogFailure implements Exception {
  const CatalogFailure(this.kind, this.message);

  final CatalogFailureKind kind;
  final String message;

  @override
  String toString() => 'CatalogFailure($kind, $message)';
}
