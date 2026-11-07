import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/app/navigation/customer_router.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/ui_foundation/presentation/kairo_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_fakes.dart';
import 'helpers/catalog_fakes.dart';
import 'helpers/order_tracking_fakes.dart';
import 'helpers/orders_fakes.dart';
import 'helpers/payment_fakes.dart';
import 'helpers/tables_fakes.dart';

void main() {
  testWidgets('KairoSplashScreen renders emblem, branding and executes onFinished callback', (WidgetTester tester) async {
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AsiaAppTheme.dark,
        home: KairoSplashScreen(
          duration: const Duration(milliseconds: 500),
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    // Initial frame of splash
    await tester.pump();
    expect(find.byType(KairoEmblem), findsOneWidget);
    expect(find.text('K A I R O'), findsOneWidget);
    expect(find.text('ALTA COCINA ASIÁTICA'), findsOneWidget);

    // Advance animation past finish
    await tester.pump(const Duration(milliseconds: 600));
    expect(finished, isTrue);
  });

  testWidgets('CustomerApp boots up and renders Home Page with KAIRO branding', (WidgetTester tester) async {
    final FakeAuthRepository fakeAuth = FakeAuthRepository();
    final MemoryAuthSessionStore fakeSessionStore = MemoryAuthSessionStore();
    final FakeCatalogRepository fakeCatalog = FakeCatalogRepository();
    final FakeTablesRepository fakeTables = FakeTablesRepository();
    final FakeOrdersRepository fakeOrders = FakeOrdersRepository();
    final FakeOrderTrackingRepository fakeTracking = FakeOrderTrackingRepository();
    final FakePaymentStatusRepository fakePayment = FakePaymentStatusRepository();

    await tester.pumpWidget(
      CustomerApp(
        environment: ApiEnvironment(baseUrl: ApiEnvironment.renderUrl),
        initialLocation: CustomerRoutes.home,
        authRepository: fakeAuth,
        sessionStore: fakeSessionStore,
        catalogRepository: fakeCatalog,
        tablesRepository: fakeTables,
        ordersRepository: fakeOrders,
        orderTrackingRepository: fakeTracking,
        paymentStatusRepository: fakePayment,
      ),
    );

    // Initial frame rendered
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify KAIRO app brand title is rendered on home screen
    expect(find.text('KAIRO'), findsOneWidget);
    expect(find.text('Alta Cocina Asiática Contemporánea'), findsOneWidget);

    // Verify bottom navigation bar destinations
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Menú'), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Cuenta'), findsOneWidget);
  });
}
