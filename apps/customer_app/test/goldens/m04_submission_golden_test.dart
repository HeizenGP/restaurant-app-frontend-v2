import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/submit_order_controller.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/presentation/order_submission_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(_loadAppFonts);

  for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('12 review matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final _VisualDependencies dependencies = _VisualDependencies(mode);
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(
        dependencies.harness(
          OrderReviewPage(
            themeModeController: dependencies.themeModeController,
            controller: dependencies.controller,
            onSubmitted: (_) {},
            onFailure: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('order-review-products'),
        const Rect.fromLTWH(24, 205, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('order-review-attention'),
        const Rect.fromLTWH(24, 308, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('order-review-amount'),
        const Rect.fromLTWH(24, 411, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('order-review-pending'),
        const Rect.fromLTWH(24, 514, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('order-submit'),
        const Rect.fromLTWH(24, 662, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_submission_12_review_$suffix.png'),
      );
    });

    testWidgets('13 requested matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final _VisualDependencies dependencies = _VisualDependencies(mode);
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(
        dependencies.harness(
          OrderSubmittedPage(
            themeModeController: dependencies.themeModeController,
            order: _requestedOrder,
            onViewOrders: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('order-submitted-badge'),
        const Rect.fromLTWH(134, 195, 122, 122),
      );
      _expectRectNear(
        tester,
        const Key('order-submitted-heading'),
        const Rect.fromLTWH(70.7, 356.2, 248.6, 28.6),
      );
      _expectRectNear(
        tester,
        const Key('order-submitted-status'),
        const Rect.fromLTWH(24, 429, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('order-submitted-reviewer'),
        const Rect.fromLTWH(24, 535, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('order-view-orders'),
        const Rect.fromLTWH(24, 661, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_submission_13_requested_$suffix.png'),
      );
    });

    testWidgets('18 exceptions matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final _VisualDependencies dependencies = _VisualDependencies(mode);
      addTearDown(dependencies.dispose);

      await tester.pumpWidget(
        dependencies.harness(
          OrderExceptionPage(
            themeModeController: dependencies.themeModeController,
            failure: const OrderFailure(
              OrderFailureKind.network,
              'Reintentar sin duplicar el pedido',
            ),
            onBackToHome: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('order-exception-rejected'),
        const Rect.fromLTWH(24, 183, 342, 116),
      );
      _expectRectNear(
        tester,
        const Key('order-exception-product'),
        const Rect.fromLTWH(24, 309, 342, 116),
      );
      _expectRectNear(
        tester,
        const Key('order-exception-session'),
        const Rect.fromLTWH(24, 435, 342, 116),
      );
      _expectRectNear(
        tester,
        const Key('order-exception-connection'),
        const Rect.fromLTWH(24, 561, 342, 116),
      );
      _expectRectNear(
        tester,
        const Key('order-exception-home'),
        const Rect.fromLTWH(24, 705, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_submission_18_exceptions_$suffix.png'),
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

void _expectNoBottomNavigation() {
  expect(find.byType(CustomerBottomNavigation), findsNothing);
  expect(find.byType(NavigationBar), findsNothing);
}

const Key _boundaryKey = Key('m04-submission-golden');

class _VisualDependencies {
  _VisualDependencies(ThemeMode mode)
    : themeModeController = ThemeModeController(initialMode: mode),
      controller = SubmitOrderController(
        repository: const _OrdersVisualRepository(),
        accessTokenProvider: () => 'visual-access-token',
        refreshAccessToken: () async => false,
        idempotencyKeyGenerator: () => 'visual-idempotency-key',
        initialCommand: _reviewCommand,
      ),
      _mode = mode;

  final ThemeModeController themeModeController;
  final SubmitOrderController controller;
  final ThemeMode _mode;

  Widget harness(Widget child) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _mode,
        home: child,
      ),
    );
  }

  void dispose() {
    controller.dispose();
    themeModeController.dispose();
  }
}

class _OrdersVisualRepository implements OrdersRepository {
  const _OrdersVisualRepository();

  @override
  Future<OrderSnapshot> createOrder(
    CreateOrderCommand command, {
    required String accessToken,
    required String idempotencyKey,
  }) async => _requestedOrder;

  @override
  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  }) async => _requestedOrder;
}

final CreateOrderCommand _reviewCommand = CreateOrderCommand(
  items: const <CreateOrderItem>[
    CreateOrderItem(productId: 'product-one', quantity: 2),
  ],
  fulfillment: FulfillmentDraft.pickup(
    contactName: 'Cliente',
    contactPhone: '999999999',
  ),
);

final OrderSnapshot _requestedOrder = OrderSnapshot(
  id: 'order-one',
  modality: FulfillmentMode.pickup,
  channel: 'APP',
  status: 'REQUESTED',
  contactName: 'Cliente',
  contactPhone: '999999999',
  totalAmount: '48.00',
  lines: const <OrderLineSnapshot>[
    OrderLineSnapshot(
      productId: 'product-one',
      productName: 'Producto seleccionado',
      quantity: 2,
      unitPrice: '24.00',
    ),
  ],
  createdAt: DateTime.utc(2026, 10, 24, 12),
);

Future<void> _configureFigmaViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.padding = const FakeViewPadding();
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
