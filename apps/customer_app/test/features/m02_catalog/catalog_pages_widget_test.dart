import 'dart:async';

import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/presentation/catalog_pages.dart';
import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/domain/catalog_models.dart';
import 'package:customer_app/features/m02_catalog/view_product/application/product_detail_controller.dart';
import 'package:customer_app/features/m02_catalog/view_product/presentation/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/catalog_fakes.dart';

void main() {
  testWidgets('home renders real categories after loading both GET resources', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final FakeCatalogRepository repository = FakeCatalogRepository();
    final CatalogController controller = CatalogController(
      repository: repository,
    );
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        CatalogHomePage(
          themeModeController: themeController,
          catalogController: controller,
          onOpenMenu: () {},
          onCategorySelected: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(categoryOne.name), findsOneWidget);
    expect(find.text(categoryTwo.name), findsOneWidget);
    expect(find.byKey(const Key('home-availability-card')), findsOneWidget);
    expect(repository.categoryCalls, 1);
    expect(repository.productCalls, <String>[categoryOneId]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('catalog switches category and disables unavailable products', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final FakeCatalogRepository repository = FakeCatalogRepository();
    final CatalogController controller = CatalogController(
      repository: repository,
    );
    final ThemeModeController themeController = ThemeModeController();
    CatalogProduct? openedProduct;
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        CatalogBrowsePage(
          themeModeController: themeController,
          catalogController: controller,
          onOpenProduct: (CatalogProduct product) => openedProduct = product,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Finder availableCard = find.byKey(
      const ValueKey<String>('catalog-product-$productOneId'),
    );
    expect(availableCard, findsOneWidget);
    await tester.tap(availableCard);
    expect(openedProduct, productOne);

    await tester.tap(
      find.byKey(const ValueKey<String>('catalog-category-$categoryTwoId')),
    );
    await tester.pumpAndSettle();

    final Finder unavailableCard = find.byKey(
      const ValueKey<String>('catalog-product-$productTwoId'),
    );
    expect(unavailableCard, findsOneWidget);
    expect(find.text('S/ 2.00 · No disponible'), findsOneWidget);
    expect(
      find.descendant(of: unavailableCard, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(repository.productCalls, <String>[categoryOneId, categoryTwoId]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'catalog exposes loading, category error, retry and empty states',
    (WidgetTester tester) async {
      await _configurePhoneSurface(tester, const Size(390, 844));
      final Completer<List<CatalogCategory>> firstRequest =
          Completer<List<CatalogCategory>>();
      final FakeCatalogRepository repository = FakeCatalogRepository()
        ..categoriesHandler = () => firstRequest.future;
      final CatalogController controller = CatalogController(
        repository: repository,
      );
      final ThemeModeController themeController = ThemeModeController();
      addTearDown(controller.dispose);
      addTearDown(themeController.dispose);

      await tester.pumpWidget(
        _testApp(
          CatalogBrowsePage(
            themeModeController: themeController,
            catalogController: controller,
            onOpenProduct: (_) {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('catalog-loading-state')), findsOneWidget);

      firstRequest.completeError(
        const CatalogFailure(CatalogFailureKind.network, 'Sin conexión.'),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('catalog-error-state')), findsOneWidget);

      repository.categoriesHandler = () async => const <CatalogCategory>[];
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('catalog-empty-state')), findsOneWidget);
      expect(repository.categoryCalls, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('detail reuses and renders the selected product responsively', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(themeController.dispose);
    final ProductDetailController controller =
        ProductDetailController.fromSelection(
          categoryId: categoryOneId,
          productId: productOneId,
          selectedProduct: productOne,
        );

    await tester.pumpWidget(
      _testApp(
        CatalogProductDetailPage(
          themeModeController: themeController,
          controller: controller,
          onAddProduct: (_, _) => true,
          onOpenCart: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('product-add-to-cart')));
    await tester.pumpAndSettle();

    expect(find.text(productOne.name), findsOneWidget);
    expect(find.text('Precio · S/ 24.25'), findsOneWidget);
    expect(find.text('Disponible para venta'), findsOneWidget);
    expect(find.byKey(const Key('product-quantity')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail selects a quantity and adds the real product', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(themeController.dispose);
    final ProductDetailController controller =
        ProductDetailController.fromSelection(
          categoryId: categoryOneId,
          productId: productOneId,
          selectedProduct: productOne,
        );
    CatalogProduct? addedProduct;
    var addedQuantity = 0;
    var openedCart = false;

    await tester.pumpWidget(
      _testApp(
        CatalogProductDetailPage(
          themeModeController: themeController,
          controller: controller,
          onAddProduct: (CatalogProduct product, int quantity) {
            addedProduct = product;
            addedQuantity = quantity;
            return true;
          },
          onOpenCart: () => openedCart = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-quantity-increase')));
    await tester.tap(find.byKey(const Key('product-quantity-increase')));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byKey(const Key('product-add-to-cart')));
    expect(addedProduct, productOne);
    expect(addedQuantity, 3);
    expect(openedCart, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail blocks unavailable products from the local cart', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(themeController.dispose);
    final ProductDetailController controller =
        ProductDetailController.fromSelection(
          categoryId: categoryTwoId,
          productId: productTwoId,
          selectedProduct: productTwo,
        );
    var addCalled = false;

    await tester.pumpWidget(
      _testApp(
        CatalogProductDetailPage(
          themeModeController: themeController,
          controller: controller,
          onAddProduct: (_, _) {
            addCalled = true;
            return true;
          },
          onOpenCart: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('product-add-to-cart')),
      warnIfMissed: false,
    );

    expect(addCalled, isFalse);
    expect(find.text('No disponible para venta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: Scaffold(body: child),
  );
}

Future<void> _configurePhoneSurface(
  WidgetTester tester,
  Size logicalSize,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = logicalSize;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);
}
