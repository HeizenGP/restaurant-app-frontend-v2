import 'dart:async';

import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/domain/catalog_models.dart';
import 'package:customer_app/features/m02_catalog/view_product/application/product_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/catalog_fakes.dart';

void main() {
  test('requeries the category and locates the requested product', () async {
    final FakeCatalogRepository repository = FakeCatalogRepository();
    final ProductDetailController controller = ProductDetailController(
      repository: repository,
      categoryId: categoryOneId,
      productId: productOneId,
    );

    expect(controller.state.status, ProductDetailStatus.initial);
    await controller.load();

    expect(controller.state.status, ProductDetailStatus.success);
    expect(controller.state.product, productOne);
    expect(repository.productCalls, <String>[categoryOneId]);
    controller.dispose();
  });

  test('uses notFound when the product is absent from its category', () async {
    final FakeCatalogRepository repository = FakeCatalogRepository()
      ..products[categoryOneId] = const <CatalogProduct>[];
    final ProductDetailController controller = ProductDetailController(
      repository: repository,
      categoryId: categoryOneId,
      productId: productOneId,
    );

    await controller.load();

    expect(controller.state.status, ProductDetailStatus.notFound);
    expect(controller.state.product, isNull);
    controller.dispose();
  });

  test(
    'maps a missing category to notFound and other failures to error',
    () async {
      final FakeCatalogRepository repository = FakeCatalogRepository();
      var failure = const CatalogFailure(
        CatalogFailureKind.notFound,
        'Categoría no encontrada.',
      );
      repository.productsHandler = (_) async => throw failure;
      final ProductDetailController controller = ProductDetailController(
        repository: repository,
        categoryId: categoryOneId,
        productId: productOneId,
      );

      await controller.load();
      expect(controller.state.status, ProductDetailStatus.notFound);

      failure = const CatalogFailure(
        CatalogFailureKind.network,
        'Sin conexión.',
      );
      await controller.retry();
      expect(controller.state.status, ProductDetailStatus.error);
      expect(controller.state.failure?.kind, CatalogFailureKind.network);
      controller.dispose();
    },
  );

  test('only the latest detail request may update state', () async {
    final Completer<List<CatalogProduct>> firstRequest =
        Completer<List<CatalogProduct>>();
    final Completer<List<CatalogProduct>> secondRequest =
        Completer<List<CatalogProduct>>();
    var call = 0;
    final FakeCatalogRepository repository = FakeCatalogRepository()
      ..productsHandler = (_) {
        call += 1;
        return call == 1 ? firstRequest.future : secondRequest.future;
      };
    final ProductDetailController controller = ProductDetailController(
      repository: repository,
      categoryId: categoryOneId,
      productId: productOneId,
    );

    final Future<void> firstLoad = controller.load();
    final Future<void> secondLoad = controller.load();
    secondRequest.complete(<CatalogProduct>[productOne]);
    await secondLoad;
    expect(controller.state.status, ProductDetailStatus.success);

    firstRequest.complete(const <CatalogProduct>[]);
    await firstLoad;
    expect(controller.state.status, ProductDetailStatus.success);
    expect(controller.state.product, productOne);
    controller.dispose();
  });
}
