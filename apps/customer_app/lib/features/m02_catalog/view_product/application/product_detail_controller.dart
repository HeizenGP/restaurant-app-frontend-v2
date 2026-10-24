import 'package:flutter/foundation.dart';

import '../../shared/domain/catalog_models.dart';

enum ProductDetailStatus { success, notFound }

@immutable
final class ProductDetailState {
  const ProductDetailState({required this.status, this.product});

  final ProductDetailStatus status;
  final CatalogProduct? product;
}

/// Builds the detail exclusively from the product selected in the list.
///
/// M02 does not expose a product-detail endpoint. Matching both route IDs keeps
/// stale or malformed deep links from displaying a different product.
final class ProductDetailController {
  factory ProductDetailController.fromSelection({
    required String categoryId,
    required String productId,
    required CatalogProduct? selectedProduct,
  }) {
    final bool matchesRoute =
        selectedProduct?.categoryId == categoryId &&
        selectedProduct?.id == productId;
    return ProductDetailController._(
      ProductDetailState(
        status: matchesRoute
            ? ProductDetailStatus.success
            : ProductDetailStatus.notFound,
        product: matchesRoute ? selectedProduct : null,
      ),
    );
  }

  const ProductDetailController._(this.state);

  final ProductDetailState state;
}
