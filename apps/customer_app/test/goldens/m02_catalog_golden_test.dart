import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/presentation/catalog_pages.dart';
import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/domain/catalog_models.dart';
import 'package:customer_app/features/m02_catalog/view_product/application/product_detail_controller.dart';
import 'package:customer_app/features/m02_catalog/view_product/presentation/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(_loadAppFonts);

  for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('08 home matches the $suffix M02 operational baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final CatalogController catalogController = CatalogController(
        repository: const _CatalogGoldenRepository(),
      );
      final ThemeModeController themeModeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(catalogController.dispose);
      addTearDown(themeModeController.dispose);
      await catalogController.loadCatalog();

      await tester.pumpWidget(
        _CatalogGoldenHarness(
          mode: mode,
          selectedIndex: 0,
          child: CatalogHomePage(
            themeModeController: themeModeController,
            catalogController: catalogController,
            onOpenMenu: () {},
            onCategorySelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m02_catalog_08_home_$suffix.png'),
      );
    });

    testWidgets('09 catalog matches the $suffix M02 operational baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final CatalogController catalogController = CatalogController(
        repository: const _CatalogGoldenRepository(),
      );
      final ThemeModeController themeModeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(catalogController.dispose);
      addTearDown(themeModeController.dispose);
      await catalogController.loadCatalog();

      await tester.pumpWidget(
        _CatalogGoldenHarness(
          mode: mode,
          selectedIndex: 1,
          child: CatalogBrowsePage(
            themeModeController: themeModeController,
            catalogController: catalogController,
            onOpenProduct: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m02_catalog_09_catalog_$suffix.png'),
      );
    });

    testWidgets('10 product matches the $suffix M02 operational baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final ThemeModeController themeModeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(themeModeController.dispose);
      final ProductDetailController detailController =
          ProductDetailController.fromSelection(
            categoryId: _detailProduct.categoryId,
            productId: _detailProduct.id,
            selectedProduct: _detailProduct,
          );

      await tester.pumpWidget(
        _CatalogGoldenHarness(
          mode: mode,
          child: CatalogProductDetailPage(
            themeModeController: themeModeController,
            controller: detailController,
            onAddProduct: (_, _) => true,
            onOpenCart: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('product-visual-placeholder'),
        const Rect.fromLTWH(25, 181, 341, 190),
      );
      _expectRectNear(
        tester,
        const Key('product-detail-name'),
        const Rect.fromLTWH(25, 402, 337, 34),
      );
      _expectRectNear(
        tester,
        const Key('product-detail-price'),
        const Rect.fromLTWH(25, 447, 335, 28),
      );
      _expectRectNear(
        tester,
        const Key('product-detail-availability'),
        const Rect.fromLTWH(25, 485, 335, 26),
      );
      _expectRectNear(
        tester,
        const Key('product-quantity'),
        const Rect.fromLTWH(24, 532, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('product-add-to-cart'),
        const Rect.fromLTWH(24, 648, 342, 54),
      );

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m02_catalog_10_product_$suffix.png'),
      );
    });
  }
}

void _expectRectNear(
  WidgetTester tester,
  Key key,
  Rect expected, {
  double tolerance = 1.5,
}) {
  final Rect actual = tester.getRect(find.byKey(key));
  expect(actual.left, closeTo(expected.left, tolerance), reason: '$key left');
  expect(actual.top, closeTo(expected.top, tolerance), reason: '$key top');
  expect(actual.width, closeTo(expected.width, 8), reason: '$key width');
  expect(
    actual.height,
    closeTo(expected.height, tolerance),
    reason: '$key height',
  );
}

const Key _boundaryKey = Key('m02-catalog-golden');
const CatalogProduct _detailProduct = CatalogProduct(
  id: 'product-detail',
  categoryId: 'category-rice',
  name: 'Nombre desde catálogo',
  priceCents: 2425,
  availableForSale: true,
);

class _CatalogGoldenHarness extends StatelessWidget {
  const _CatalogGoldenHarness({
    required this.mode,
    required this.child,
    this.selectedIndex,
  });

  final ThemeMode mode;
  final int? selectedIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final int? navigationIndex = selectedIndex;
    return RepaintBoundary(
      key: _boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: navigationIndex == null
            ? child
            : Scaffold(
                body: child,
                bottomNavigationBar: Builder(
                  builder: (BuildContext context) {
                    return ColoredBox(
                      color: context.appPalette.background,
                      child: SafeArea(
                        top: false,
                        child: CustomerBottomNavigation(
                          currentIndex: navigationIndex,
                          onDestinationSelected: (_) {},
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

// Verified Figma sample content is confined to tests. Production still reads
// every category, product, price and availability value from the catalog API.
class _CatalogGoldenRepository implements CatalogRepository {
  const _CatalogGoldenRepository();

  static const List<CatalogCategory> _categories = <CatalogCategory>[
    CatalogCategory(id: 'category-rice', name: 'Arroces'),
    CatalogCategory(id: 'category-noodles', name: 'Tallarines'),
    CatalogCategory(id: 'category-specials', name: 'Especiales'),
  ];

  static const List<CatalogProduct> _products = <CatalogProduct>[
    CatalogProduct(
      id: 'product-main',
      categoryId: 'category-rice',
      name: 'Plato del catálogo',
      priceCents: 2425,
      availableForSale: true,
    ),
    CatalogProduct(
      id: 'product-second',
      categoryId: 'category-rice',
      name: 'Otra opción disponible',
      priceCents: 1850,
      availableForSale: true,
    ),
    CatalogProduct(
      id: 'product-unavailable',
      categoryId: 'category-rice',
      name: 'Producto agotado',
      priceCents: 1200,
      availableForSale: false,
    ),
    CatalogProduct(
      id: 'product-other',
      categoryId: 'category-rice',
      name: 'Otra categoría',
      priceCents: 1000,
      availableForSale: true,
    ),
  ];

  @override
  Future<List<CatalogCategory>> listCategories() async => _categories;

  @override
  Future<List<CatalogProduct>> listProducts(String categoryId) async {
    return categoryId == 'category-rice' ? _products : const <CatalogProduct>[];
  }
}

Future<void> _configureFigmaViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.padding = const FakeViewPadding(bottom: 24);
  addTearDown(tester.view.reset);
}

Future<void> _loadAppFonts() async {
  final FontLoader bodyFont = FontLoader('DM Sans')
    ..addFont(rootBundle.load('assets/fonts/DMSans-Variable.ttf'));
  final FontLoader displayFont = FontLoader('Cormorant Garamond')
    ..addFont(rootBundle.load('assets/fonts/CormorantGaramond-Variable.ttf'));
  final FontLoader lucideFont =
      FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
        rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
      );
  await Future.wait(<Future<void>>[
    bodyFont.load(),
    displayFont.load(),
    lucideFont.load(),
  ]);
}
