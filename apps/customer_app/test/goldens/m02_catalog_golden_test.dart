import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/theme/app_theme.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/presentation/catalog_home_page.dart';
import 'package:customer_app/features/m02_catalog/browse_catalog/presentation/catalog_page.dart';
import 'package:customer_app/features/m02_catalog/shared/domain/catalog_models.dart';
import 'package:customer_app/features/m02_catalog/view_product/presentation/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/catalog_fakes.dart';

void main() {
  for (final (String name, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('home matches the $name M02 reference', (
      WidgetTester tester,
    ) async {
      await _configureGolden(tester);
      final FakeCatalogRepository repository = FakeCatalogRepository();
      final CatalogController controller = CatalogController(
        repository: repository,
      );
      final ThemeModeController themeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(controller.dispose);
      addTearDown(themeController.dispose);
      const Key boundary = Key('m02-home-golden');

      await tester.pumpWidget(
        _goldenApp(
          mode: mode,
          boundary: boundary,
          bottomIndex: 0,
          child: CatalogHomePage(
            catalogController: controller,
            themeModeController: themeController,
            onOpenCatalog: () {},
            onCategorySelected: (CatalogCategory category) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('m02_home_$name.png'),
      );
    });

    testWidgets('catalog matches the $name M02 reference', (
      WidgetTester tester,
    ) async {
      await _configureGolden(tester);
      final FakeCatalogRepository repository = FakeCatalogRepository();
      final CatalogController controller = CatalogController(
        repository: repository,
      );
      final ThemeModeController themeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(controller.dispose);
      addTearDown(themeController.dispose);
      const Key boundary = Key('m02-catalog-golden');

      await tester.pumpWidget(
        _goldenApp(
          mode: mode,
          boundary: boundary,
          bottomIndex: 1,
          child: CatalogPage(
            catalogController: controller,
            themeModeController: themeController,
            onProductSelected: (
              CatalogCategory category,
              CatalogProduct product,
            ) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('m02_catalog_$name.png'),
      );
    });

    testWidgets('product detail matches the $name M02 reference', (
      WidgetTester tester,
    ) async {
      await _configureGolden(tester);
      final FakeCatalogRepository repository = FakeCatalogRepository();
      final ThemeModeController themeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(themeController.dispose);
      const Key boundary = Key('m02-product-detail-golden');

      await tester.pumpWidget(
        _goldenApp(
          mode: mode,
          boundary: boundary,
          child: ProductDetailPage(
            repository: repository,
            categoryId: categoryOneId,
            productId: productOneId,
            themeModeController: themeController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile('m02_product_detail_$name.png'),
      );
    });
  }
}

Widget _goldenApp({
  required ThemeMode mode,
  required Key boundary,
  required Widget child,
  int? bottomIndex,
}) {
  return RepaintBoundary(
    key: boundary,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: Scaffold(
        body: child,
        bottomNavigationBar: bottomIndex == null
            ? null
            : SafeArea(
                top: false,
                child: CustomerBottomNavigation(
                  currentIndex: bottomIndex,
                  onDestinationSelected: (int index) {},
                ),
              ),
      ),
    ),
  );
}

Future<void> _configureGolden(WidgetTester tester) async {
  await _loadAppFonts();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
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
