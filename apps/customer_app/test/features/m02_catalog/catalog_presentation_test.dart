import 'dart:async';

import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/theme/app_theme.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/presentation/catalog_home_page.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/presentation/catalog_page.dart';
import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/domain/catalog_models.dart';
import 'package:customer_app/features/m02_catalog/view_product/presentation/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/catalog_fakes.dart';

void main() {
  testWidgets('home shows API categories and exposes both catalog entries', (
    WidgetTester tester,
  ) async {
    final FakeCatalogRepository repository = FakeCatalogRepository();
    final CatalogController controller = CatalogController(
      repository: repository,
    );
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);
    var openedCatalog = false;
    CatalogCategory? selectedCategory;

    await tester.pumpWidget(
      _testApp(
        CatalogHomePage(
          catalogController: controller,
          themeModeController: themeController,
          onOpenCatalog: () => openedCatalog = true,
          onCategorySelected: (CatalogCategory category) {
            selectedCategory = category;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('El sabor nos reúne'), findsOneWidget);
    expect(find.text('Arroces'), findsOneWidget);
    expect(find.text('Bebidas'), findsOneWidget);
    expect(find.byKey(const Key('catalog-home-hero')), findsOneWidget);
    final Finder firstCategoryTarget = find.descendant(
      of: find.byKey(Key('catalog-category-$categoryOneId')),
      matching: find.byType(InkWell),
    );
    expect(
      tester.getSize(firstCategoryTarget).height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.byKey(const Key('home-open-catalog')));
    expect(openedCatalog, isTrue);

    await tester.tap(find.byKey(Key('catalog-category-$categoryTwoId')));
    await tester.pumpAndSettle();
    expect(selectedCategory, categoryTwo);
    expect(repository.productCalls.last, categoryTwoId);
  });

  testWidgets(
    'catalog selects available products and disables unavailable ones',
    (WidgetTester tester) async {
      final FakeCatalogRepository repository = FakeCatalogRepository();
      final CatalogController controller = CatalogController(
        repository: repository,
      );
      final ThemeModeController themeController = ThemeModeController();
      addTearDown(controller.dispose);
      addTearDown(themeController.dispose);
      final List<CatalogProduct> selectedProducts = <CatalogProduct>[];

      await tester.pumpWidget(
        _testApp(
          CatalogPage(
            catalogController: controller,
            themeModeController: themeController,
            onProductSelected:
                (CatalogCategory category, CatalogProduct product) {
                  selectedProducts.add(product);
                },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('S/ 24.25 · Disponible'), findsOneWidget);
      await tester.tap(find.byKey(Key('catalog-product-$productOneId')));
      expect(selectedProducts, <CatalogProduct>[productOne]);

      await tester.tap(find.byKey(Key('catalog-category-$categoryTwoId')));
      await tester.pumpAndSettle();
      expect(
        find.text('S/ 2.00 · No disponible para la venta'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(Key('catalog-product-$productTwoId')),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(selectedProducts, <CatalogProduct>[productOne]);
    },
  );

  testWidgets(
    'catalog renders loading, empty and recoverable connection errors',
    (WidgetTester tester) async {
      final Completer<List<CatalogCategory>> pendingCategories =
          Completer<List<CatalogCategory>>();
      final FakeCatalogRepository loadingRepository = FakeCatalogRepository()
        ..categoriesHandler = () => pendingCategories.future;
      final CatalogController loadingController = CatalogController(
        repository: loadingRepository,
      );
      final ThemeModeController themeController = ThemeModeController();
      addTearDown(loadingController.dispose);
      addTearDown(themeController.dispose);

      await tester.pumpWidget(
        _testApp(
          CatalogPage(
            catalogController: loadingController,
            themeModeController: themeController,
            onProductSelected: (
              CatalogCategory category,
              CatalogProduct product,
            ) {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Cargando platos'), findsOneWidget);

      pendingCategories.complete(const <CatalogCategory>[]);
      await tester.pumpAndSettle();
      expect(find.text('Catálogo vacío'), findsOneWidget);

      final FakeCatalogRepository emptyCategoryRepository =
          FakeCatalogRepository()
            ..products[categoryOneId] = const <CatalogProduct>[];
      final CatalogController emptyCategoryController = CatalogController(
        repository: emptyCategoryRepository,
      );
      addTearDown(emptyCategoryController.dispose);
      await tester.pumpWidget(
        _testApp(
          CatalogPage(
            catalogController: emptyCategoryController,
            themeModeController: themeController,
            onProductSelected: (
              CatalogCategory category,
              CatalogProduct product,
            ) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Categoría sin productos'), findsOneWidget);

      var shouldFail = true;
      final FakeCatalogRepository retryRepository = FakeCatalogRepository()
        ..categoriesHandler = () async {
          if (shouldFail) {
            shouldFail = false;
            throw const CatalogFailure(
              CatalogFailureKind.network,
              'Sin conexión al catálogo.',
            );
          }
          return <CatalogCategory>[categoryOne];
        };
      final CatalogController retryController = CatalogController(
        repository: retryRepository,
      );
      addTearDown(retryController.dispose);

      await tester.pumpWidget(
        _testApp(
          CatalogPage(
            catalogController: retryController,
            themeModeController: themeController,
            onProductSelected: (
              CatalogCategory category,
              CatalogProduct product,
            ) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sin conexión al catálogo.'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Chaufa especial'), findsOneWidget);
    },
  );

  testWidgets('detail uses real product fields without cart or invented copy', (
    WidgetTester tester,
  ) async {
    final FakeCatalogRepository repository = FakeCatalogRepository();
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        ProductDetailPage(
          repository: repository,
          categoryId: categoryOneId,
          productId: productOneId,
          themeModeController: themeController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chaufa especial'), findsOneWidget);
    expect(find.text('S/ 24.25'), findsOneWidget);
    expect(find.text('Disponible para la venta'), findsOneWidget);
    expect(
      find.text('No hay una descripción disponible para este producto.'),
      findsOneWidget,
    );
    expect(find.text('Agregar al carrito'), findsNothing);
    expect(find.text('Cantidad'), findsNothing);
  });

  testWidgets('detail distinguishes unavailable, missing and error states', (
    WidgetTester tester,
  ) async {
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(themeController.dispose);
    final FakeCatalogRepository repository = FakeCatalogRepository();

    await tester.pumpWidget(
      _testApp(
        ProductDetailPage(
          repository: repository,
          categoryId: categoryTwoId,
          productId: productTwoId,
          themeModeController: themeController,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No disponible para la venta'), findsOneWidget);

    await tester.pumpWidget(
      _testApp(
        ProductDetailPage(
          repository: repository,
          categoryId: categoryOneId,
          productId: 'missing-product',
          themeModeController: themeController,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Producto no encontrado'), findsOneWidget);

    final FakeCatalogRepository failingRepository = FakeCatalogRepository()
      ..productsHandler = (String categoryId) async {
        throw const CatalogFailure(
          CatalogFailureKind.server,
          'Servicio temporalmente no disponible.',
        );
      };
    await tester.pumpWidget(
      _testApp(
        ProductDetailPage(
          repository: failingRepository,
          categoryId: categoryOneId,
          productId: productOneId,
          themeModeController: themeController,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Servicio temporalmente no disponible.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('M02 pages adapt to a narrow screen and enlarged text', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final FakeCatalogRepository repository = FakeCatalogRepository();
    final CatalogController controller = CatalogController(
      repository: repository,
    );
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        CatalogPage(
          catalogController: controller,
          themeModeController: themeController,
          onProductSelected: (
            CatalogCategory category,
            CatalogProduct product,
          ) {},
        ),
        textScaler: const TextScaler.linear(1.6),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-menu')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _testApp(
        CatalogHomePage(
          catalogController: controller,
          themeModeController: themeController,
          onOpenCatalog: () {},
          onCategorySelected: (CatalogCategory category) {},
        ),
        textScaler: const TextScaler.linear(1.6),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-inicio')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _testApp(
        ProductDetailPage(
          repository: repository,
          categoryId: categoryOneId,
          productId: productOneId,
          themeModeController: themeController,
        ),
        textScaler: const TextScaler.linear(1.6),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-product-detail')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget child, {TextScaler textScaler = TextScaler.noScaling}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: child,
      ),
    ),
  );
}
