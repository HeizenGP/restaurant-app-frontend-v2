import 'package:customer_app/features/m02_catalog/view_product/application/product_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/catalog_fakes.dart';

void main() {
  test('reuses the selected product without querying the repository', () {
    final ProductDetailController controller =
        ProductDetailController.fromSelection(
          categoryId: categoryOneId,
          productId: productOneId,
          selectedProduct: productOne,
        );

    expect(controller.state.status, ProductDetailStatus.success);
    expect(controller.state.product, productOne);
  });

  test('rejects a selected product that does not match the route IDs', () {
    final ProductDetailController controller =
        ProductDetailController.fromSelection(
          categoryId: categoryOneId,
          productId: productTwoId,
          selectedProduct: productOne,
        );

    expect(controller.state.status, ProductDetailStatus.notFound);
    expect(controller.state.product, isNull);
  });

  test('represents a deep link without a selected product as not found', () {
    final ProductDetailController controller =
        ProductDetailController.fromSelection(
          categoryId: categoryOneId,
          productId: productOneId,
          selectedProduct: null,
        );

    expect(controller.state.status, ProductDetailStatus.notFound);
    expect(controller.state.product, isNull);
  });
}
