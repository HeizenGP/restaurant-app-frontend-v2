import 'package:customer_app/app/customer_app.dart';
import 'package:customer_app/core/api_environment.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_fakes.dart';
import 'helpers/catalog_fakes.dart';
import 'helpers/order_tracking_fakes.dart';
import 'helpers/orders_fakes.dart';
import 'helpers/payment_fakes.dart';
import 'helpers/tables_fakes.dart';

void main() {
  testWidgets('CustomerApp boots up and renders Home Page without errors', (WidgetTester tester) async {
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

    // Verify app brand title is rendered on home screen
    expect(find.text('Chifa ASIA'), findsOneWidget);
    expect(find.text('Auténtica fusión cantonesa y nikkei'), findsOneWidget);

    // Verify bottom navigation bar destinations
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Menú'), findsOneWidget);
    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Cuenta'), findsOneWidget);
  });
}
