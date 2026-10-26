import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/auth_fakes.dart';
import '../../../helpers/catalog_fakes.dart';
import '../../../helpers/order_tracking_fakes.dart';
import '../../../helpers/payment_fakes.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment(
    baseUrl: 'https://api.example.test/api/v1',
  );

  testWidgets('cart is automatically cleared when session changes or logs out', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final MemoryAuthSessionStore sessionStore = MemoryAuthSessionStore(
      session: registeredSession(),
    );
    final FakeAuthRepository authRepository = FakeAuthRepository(
      refreshResult: registeredSession(),
    );

    await tester.pumpWidget(
      CustomerApp(
        environment: environment,
        authRepository: authRepository,
        sessionStore: sessionStore,
        catalogRepository: FakeCatalogRepository(),
        orderTrackingRepository: FakeOrderTrackingRepository(
          orders: const <OrderSnapshot>[],
        ),
        paymentStatusRepository: FakePaymentStatusRepository(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Ir a menú y agregar un producto al carrito
    await tester.tap(find.byKey(const Key('nav-menu')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('catalog-product-$productOneId')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-add-to-cart')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-menu')), findsOneWidget);
    await tester.tap(find.byKey(const Key('header-cart-button')));
    await tester.pumpAndSettle();

    // Verificamos que el carrito tiene el producto
    expect(find.byKey(const Key('page-cart')), findsOneWidget);
    expect(find.byKey(ValueKey<String>('cart-product-$productOneId')), findsOneWidget);

    // 2. Ir a cuenta y cerrar sesión
    await tester.tap(find.byKey(const Key('nav-cuenta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('account-actions')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('logout-confirm')));
    await tester.pumpAndSettle();

    // Ahora la app está en la pantalla de acceso/login
    expect(find.byKey(const Key('page-acceso')), findsOneWidget);

    // 3. Continuar como invitado
    await tester.ensureVisible(find.byKey(const Key('go-guest')));
    await tester.tap(find.byKey(const Key('go-guest')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('guest-submit')));
    await tester.tap(find.byKey(const Key('guest-submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-inicio')), findsOneWidget);

    // 4. Navegar a /menu/carrito y verificar que el carrito está completamente vacío
    final BuildContext context = tester.element(find.byKey(const Key('page-inicio')));
    GoRouter.of(context).go('/menu/carrito');
    await tester.pumpAndSettle();

    // El carrito debe estar completamente vacío para la nueva sesión
    expect(find.byKey(const Key('page-cart')), findsOneWidget);
    expect(find.byKey(const Key('cart-empty-state')), findsOneWidget);
    expect(find.byKey(ValueKey<String>('cart-product-$productOneId')), findsNothing);
  });
}
