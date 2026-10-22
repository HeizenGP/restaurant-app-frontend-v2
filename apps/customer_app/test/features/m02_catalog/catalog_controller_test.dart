import 'dart:async';

import 'package:customer_app/features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/domain/catalog_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/catalog_fakes.dart';

void main() {
  test('loads categories and the first category products', () async {
    final FakeCatalogRepository repository = FakeCatalogRepository();
    final CatalogController controller = CatalogController(
      repository: repository,
    );

    expect(controller.state.status, CatalogStatus.initial);
    await controller.loadCatalog();

    expect(controller.state.status, CatalogStatus.success);
    expect(controller.state.categories, <CatalogCategory>[
      categoryOne,
      categoryTwo,
    ]);
    expect(controller.state.selectedCategory, categoryOne);
    expect(controller.state.products, <CatalogProduct>[productOne]);
    expect(repository.categoryCalls, 1);
    expect(repository.productCalls, <String>[categoryOneId]);
    controller.dispose();
  });

  test('represents an empty catalog as successful empty data', () async {
    final FakeCatalogRepository repository = FakeCatalogRepository()
      ..categories = const <CatalogCategory>[];
    final CatalogController controller = CatalogController(
      repository: repository,
    );

    await controller.load();

    expect(controller.state.status, CatalogStatus.success);
    expect(controller.state.hasEmptyCatalog, isTrue);
    expect(controller.state.selectedCategoryId, isNull);
    expect(repository.productCalls, isEmpty);
    controller.dispose();
  });

  test('exposes category failure and retry recovers', () async {
    final FakeCatalogRepository repository = FakeCatalogRepository();
    var shouldFail = true;
    repository.categoriesHandler = () async {
      if (shouldFail) {
        throw const CatalogFailure(CatalogFailureKind.network, 'Sin conexión.');
      }
      return <CatalogCategory>[categoryOne];
    };
    final CatalogController controller = CatalogController(
      repository: repository,
    );

    await controller.loadCatalog();
    expect(controller.state.status, CatalogStatus.failure);
    expect(controller.state.failureScope, CatalogFailureScope.categories);
    expect(controller.state.failure?.kind, CatalogFailureKind.network);

    shouldFail = false;
    await controller.retry();

    expect(controller.state.status, CatalogStatus.success);
    expect(controller.state.products, <CatalogProduct>[productOne]);
    expect(repository.categoryCalls, 2);
    controller.dispose();
  });

  test('retries a selected category without reloading categories', () async {
    final FakeCatalogRepository repository = FakeCatalogRepository();
    var shouldFail = true;
    repository.productsHandler = (String categoryId) async {
      if (shouldFail) {
        throw const CatalogFailure(
          CatalogFailureKind.server,
          'Servicio no disponible.',
        );
      }
      return repository.products[categoryId] ?? const <CatalogProduct>[];
    };
    final CatalogController controller = CatalogController(
      repository: repository,
    );

    await controller.loadCatalog();
    expect(controller.state.status, CatalogStatus.failure);
    expect(controller.state.failureScope, CatalogFailureScope.products);

    shouldFail = false;
    await controller.retry();

    expect(controller.state.status, CatalogStatus.success);
    expect(controller.state.products, <CatalogProduct>[productOne]);
    expect(repository.categoryCalls, 1);
    expect(repository.productCalls, <String>[categoryOneId, categoryOneId]);
    controller.dispose();
  });

  test('ignores a stale product response after category selection', () async {
    final Completer<List<CatalogProduct>> firstRequest =
        Completer<List<CatalogProduct>>();
    final Completer<List<CatalogProduct>> secondRequest =
        Completer<List<CatalogProduct>>();
    final FakeCatalogRepository repository = FakeCatalogRepository()
      ..productsHandler = (String categoryId) {
        return categoryId == categoryOneId
            ? firstRequest.future
            : secondRequest.future;
      };
    final CatalogController controller = CatalogController(
      repository: repository,
    );

    final Future<void> initialLoad = controller.loadCatalog();
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.selectedCategoryId, categoryOneId);

    final Future<void> selection = controller.selectCategory(categoryTwoId);
    secondRequest.complete(<CatalogProduct>[productTwo]);
    await selection;
    expect(controller.state.selectedCategoryId, categoryTwoId);
    expect(controller.state.products, <CatalogProduct>[productTwo]);

    firstRequest.complete(<CatalogProduct>[productOne]);
    await initialLoad;
    expect(controller.state.selectedCategoryId, categoryTwoId);
    expect(controller.state.products, <CatalogProduct>[productTwo]);
    controller.dispose();
  });
}
