import 'dart:async';

import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/submit_order_controller.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/presentation/order_submission_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'screen 12 renders the review and blocks a duplicate submit in flight',
    (WidgetTester tester) async {
      await _configureSurface(tester);
      final Completer<OrderSnapshot> pending = Completer<OrderSnapshot>();
      final _FakeOrdersRepository repository = _FakeOrdersRepository()
        ..createHandler = (_, _, _) => pending.future;
      final SubmitOrderController controller = _controller(repository)
        ..prepareReview(_command());
      final ThemeModeController themeController = ThemeModeController();
      OrderSnapshot? submitted;
      OrderFailure? failure;
      addTearDown(controller.dispose);
      addTearDown(themeController.dispose);

      await tester.pumpWidget(
        _testApp(
          OrderReviewPage(
            themeModeController: themeController,
            controller: controller,
            onSubmitted: (OrderSnapshot value) => submitted = value,
            onFailure: (OrderFailure value) => failure = value,
          ),
        ),
      );

      expect(find.byKey(const Key('page-order-review')), findsOneWidget);
      expect(find.text('Revisa tu solicitud'), findsOneWidget);
      expect(find.text('Resumen de productos'), findsOneWidget);
      expect(find.text('Datos de atención'), findsOneWidget);
      expect(find.text('Importe estimado'), findsOneWidget);
      expect(find.text('Pendiente de aprobación'), findsOneWidget);

      await tester.tap(find.byKey(const Key('order-submit')));
      await tester.tap(find.byKey(const Key('order-submit')));
      await tester.pump();

      expect(repository.createCalls, 1);
      expect(controller.state.phase, OrderSubmissionPhase.submitting);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(submitted, isNull);
      expect(failure, isNull);

      pending.complete(_order());
      await tester.pumpAndSettle();

      expect(repository.createCalls, 1);
      expect(submitted, _order());
      expect(failure, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('screen 13 presents the real REQUESTED response', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester);
    final ThemeModeController themeController = ThemeModeController();
    bool viewedOrders = false;
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        OrderSubmittedPage(
          themeModeController: themeController,
          order: _order(),
          onViewOrders: () => viewedOrders = true,
        ),
      ),
    );

    expect(find.byKey(const Key('page-order-submitted')), findsOneWidget);
    expect(find.text('Solicitud enviada'), findsOneWidget);
    expect(find.text('En espera de aprobación'), findsOneWidget);
    expect(find.text('Estado: REQUESTED'), findsOneWidget);
    expect(find.text('Todavía no se ha generado comanda.'), findsOneWidget);
    expect(find.text('Revisión por personal'), findsOneWidget);

    await tester.tap(find.byKey(const Key('order-view-orders')));
    expect(viewedOrders, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('screen 18 exposes the failure and retries only safe failures', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester);
    final ThemeModeController themeController = ThemeModeController();
    int retries = 0;
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      _testApp(
        OrderExceptionPage(
          themeModeController: themeController,
          failure: const OrderFailure(
            OrderFailureKind.network,
            'No pudimos conectar con Chifa ASIA.',
          ),
          onRetry: () => retries += 1,
          onBackToHome: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('page-order-exception')), findsOneWidget);
    expect(find.text('Estados y excepciones'), findsOneWidget);
    expect(find.text('No pudimos conectar con Chifa ASIA.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('order-exception-connection')),
        matching: find.byType(InkWell),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('order-exception-connection')));
    expect(retries, 1);

    await tester.pumpWidget(
      _testApp(
        OrderExceptionPage(
          themeModeController: themeController,
          failure: const OrderFailure(
            OrderFailureKind.productUnavailable,
            'El producto seleccionado ya no está disponible.',
          ),
          onRetry: () => retries += 1,
          onBackToHome: () {},
        ),
      ),
    );

    expect(
      find.text('El producto seleccionado ya no está disponible.'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('order-exception-connection')),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(const Key('order-exception-connection')));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed result GET retries GET without repeating POST', (
    WidgetTester tester,
  ) async {
    await _configureSurface(tester);
    int detailAttempt = 0;
    final _FakeOrdersRepository repository = _FakeOrdersRepository()
      ..getHandler = (_, _) async {
        detailAttempt += 1;
        if (detailAttempt == 1) {
          throw const OrderFailure(
            OrderFailureKind.network,
            'No pudimos actualizar el pedido.',
          );
        }
        return _order();
      };
    final SubmitOrderController controller = _controller(repository)
      ..prepareReview(_command());
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(controller.dispose);
    addTearDown(themeController.dispose);
    expect(await controller.submit(), isTrue);
    expect(repository.createCalls, 1);

    await tester.pumpWidget(
      _testApp(
        OrderResultPage(
          themeModeController: themeController,
          controller: controller,
          orderId: _order().id,
          onViewOrders: () {},
          onBackToHome: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page-order-exception')), findsOneWidget);
    expect(find.text('No pudimos actualizar el pedido.'), findsOneWidget);
    expect(repository.createCalls, 1);
    expect(repository.getCalls, 1);

    await tester.tap(find.byKey(const Key('order-exception-connection')));
    await tester.pumpAndSettle();

    expect(repository.createCalls, 1);
    expect(repository.getCalls, 2);
    expect(find.byKey(const Key('page-order-submitted')), findsOneWidget);
    expect(find.text('Estado: REQUESTED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: child,
  );
}

Future<void> _configureSurface(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(tester.view.reset);
}

SubmitOrderController _controller(_FakeOrdersRepository repository) {
  return SubmitOrderController(
    repository: repository,
    accessTokenProvider: () => 'access-token',
    refreshAccessToken: () async => false,
    idempotencyKeyGenerator: () => 'widget-test-key',
  );
}

CreateOrderCommand _command() {
  return CreateOrderCommand(
    items: const <CreateOrderItem>[
      CreateOrderItem(productId: 'product-1', quantity: 1),
    ],
    fulfillment: FulfillmentDraft.local(tableId: 'table-1'),
  );
}

OrderSnapshot _order() {
  return OrderSnapshot(
    id: 'order-1',
    modality: FulfillmentMode.local,
    channel: 'APP',
    status: 'REQUESTED',
    tableId: 'table-1',
    totalAmount: '24.25',
    lines: const <OrderLineSnapshot>[
      OrderLineSnapshot(
        productId: 'product-1',
        productName: 'Arroz chaufa especial',
        quantity: 1,
        unitPrice: '24.25',
      ),
    ],
    createdAt: DateTime.utc(2026, 10, 24, 12),
  );
}

typedef _CreateHandler = Future<OrderSnapshot> Function(
  CreateOrderCommand command,
  String token,
  String key,
);
typedef _GetHandler = Future<OrderSnapshot> Function(
  String orderId,
  String token,
);

final class _FakeOrdersRepository implements OrdersRepository {
  _CreateHandler? createHandler;
  _GetHandler? getHandler;
  int createCalls = 0;
  int getCalls = 0;

  @override
  Future<OrderSnapshot> createOrder(
    CreateOrderCommand command, {
    required String accessToken,
    required String idempotencyKey,
  }) async {
    createCalls += 1;
    return await createHandler?.call(command, accessToken, idempotencyKey) ??
        _order();
  }

  @override
  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  }) async {
    getCalls += 1;
    return await getHandler?.call(orderId, accessToken) ?? _order();
  }
}
