import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/manage_cart/application/cart_controller.dart';
import 'package:customer_app/features/m04_orders/manage_cart/domain/cart_models.dart';
import 'package:customer_app/features/m04_orders/manage_cart/presentation/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(_loadAppFonts);

  for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('11 cart matches the $suffix operational baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final CartController cartController = CartController()
        ..addProduct(_firstProduct, quantity: 2)
        ..addProduct(_secondProduct);
      final ThemeModeController themeModeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(cartController.dispose);
      addTearDown(themeModeController.dispose);

      await tester.pumpWidget(
        _CartGoldenHarness(
          mode: mode,
          child: CartPage(
            themeModeController: themeModeController,
            cartController: cartController,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const ValueKey<String>('cart-product-product-one'),
        const Rect.fromLTWH(24, 202, 342, 102),
      );
      _expectRectNear(
        tester,
        const ValueKey<String>('cart-product-product-two'),
        const Rect.fromLTWH(24, 314, 342, 102),
      );
      _expectRectNear(
        tester,
        const Key('cart-summary-card'),
        const Rect.fromLTWH(24, 452, 342, 103),
      );
      _expectRectNear(
        tester,
        const Key('cart-server-note'),
        const Rect.fromLTWH(29, 589, 337, 35),
      );
      _expectRectNear(
        tester,
        const Key('cart-continue-disabled'),
        const Rect.fromLTWH(24, 655, 342, 54),
      );

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_cart_11_cart_$suffix.png'),
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
  expect(
    actual.width,
    closeTo(expected.width, tolerance),
    reason: '$key width',
  );
  expect(
    actual.height,
    closeTo(expected.height, tolerance),
    reason: '$key height',
  );
}

const Key _boundaryKey = Key('m04-cart-golden');

class _CartGoldenHarness extends StatelessWidget {
  const _CartGoldenHarness({required this.mode, required this.child});

  final ThemeMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: mode,
        home: Scaffold(
          body: child,
          bottomNavigationBar: Builder(
            builder: (BuildContext context) {
              return ColoredBox(
                color: context.appPalette.background,
                child: SafeArea(
                  top: false,
                  child: CustomerBottomNavigation(
                    currentIndex: 1,
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

const CartProductSnapshot _firstProduct = CartProductSnapshot(
  id: 'product-one',
  categoryId: 'category-one',
  name: 'Producto seleccionado',
  unitPriceCents: 1200,
);

const CartProductSnapshot _secondProduct = CartProductSnapshot(
  id: 'product-two',
  categoryId: 'category-one',
  name: 'Segundo producto',
  unitPriceCents: 550,
);

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
