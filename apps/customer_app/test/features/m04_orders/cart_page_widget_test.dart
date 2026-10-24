import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/manage_cart/application/cart_controller.dart';
import 'package:customer_app/features/m04_orders/manage_cart/domain/cart_models.dart';
import 'package:customer_app/features/m04_orders/manage_cart/presentation/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders real cart lines and edits quantity locally', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final CartController cartController = CartController()
      ..addProduct(productOne, quantity: 2)
      ..addProduct(productTwo);
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(cartController.dispose);
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        CartPage(
          themeModeController: themeController,
          cartController: cartController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 unidades · S/ 24.00'), findsOneWidget);
    expect(find.text('Subtotal local · S/ 29.50'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('cart-product-product-one')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('cart-increase-product-one')),
    );
    await tester.pumpAndSettle();

    expect(cartController.state.itemFor(productOne.id)?.quantity, 3);
    expect(find.text('Subtotal local · S/ 36.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('removes products and exposes the honest empty state', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(390, 844));
    final CartController cartController = CartController()
      ..addProduct(productOne);
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(cartController.dispose);
    addTearDown(themeController.dispose);
    await tester.pumpWidget(
      _testApp(
        CartPage(
          themeModeController: themeController,
          cartController: cartController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('cart-product-product-one')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('cart-remove-product-one')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart-empty-state')), findsOneWidget);
    expect(find.text('Tu carrito está vacío'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolls without overflow on a narrow Android viewport', (
    WidgetTester tester,
  ) async {
    await _configurePhoneSurface(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final CartController cartController = CartController()
      ..addProduct(productOne)
      ..addProduct(productTwo)
      ..addProduct(productThree);
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(cartController.dispose);
    addTearDown(themeController.dispose);
    await tester.pumpWidget(
      _testApp(
        CartPage(
          themeModeController: themeController,
          cartController: cartController,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('cart-continue-disabled')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('cart-continue-disabled')), findsOneWidget);
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
  tester.view.padding = const FakeViewPadding(bottom: 24);
  addTearDown(tester.view.reset);
}

const CartProductSnapshot productOne = CartProductSnapshot(
  id: 'product-one',
  categoryId: 'category-one',
  name: 'Chaufa especial',
  unitPriceCents: 1200,
);

const CartProductSnapshot productTwo = CartProductSnapshot(
  id: 'product-two',
  categoryId: 'category-one',
  name: 'Té jazmín',
  unitPriceCents: 550,
);

const CartProductSnapshot productThree = CartProductSnapshot(
  id: 'product-three',
  categoryId: 'category-two',
  name: 'Tallarín saltado con vegetales',
  unitPriceCents: 1850,
);
