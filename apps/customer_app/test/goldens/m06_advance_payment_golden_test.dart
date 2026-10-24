import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/domain/payment_models.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/presentation/payment_status_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(_loadAppFonts);

  for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('14 advance matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final ThemeModeController themeModeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(themeModeController.dispose);

      await tester.pumpWidget(
        _harness(
          mode: mode,
          child: AdvanceSummaryPage(
            themeModeController: themeModeController,
            summary: _visualAdvanceSummary,
            onViewOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('advance-total'),
        const Rect.fromLTWH(24, 201, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('advance-required'),
        const Rect.fromLTWH(24, 301, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('advance-verification'),
        const Rect.fromLTWH(24, 401, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('advance-no-electronic-payment'),
        const Rect.fromLTWH(24, 512, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('advance-view-order'),
        const Rect.fromLTWH(24, 664, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m06_advance_14_advance_$suffix.png'),
      );
    });

    testWidgets('17 payment matches the $suffix Figma baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final ThemeModeController themeModeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(themeModeController.dispose);

      await tester.pumpWidget(
        _harness(
          mode: mode,
          child: PaymentSummaryPage(
            themeModeController: themeModeController,
            summary: _visualPaymentSummary,
            onBackToOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('payment-total'),
        const Rect.fromLTWH(24, 196, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('payment-paid'),
        const Rect.fromLTWH(24, 295, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('payment-balance'),
        const Rect.fromLTWH(24, 394, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('payment-status'),
        const Rect.fromLTWH(24, 493, 342, 77),
      );
      _expectRectNear(
        tester,
        const Key('payment-back-to-order'),
        const Rect.fromLTWH(24, 687, 342, 54),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m06_payment_17_status_$suffix.png'),
      );
    });
  }
}

const Key _boundaryKey = Key('m06-advance-payment-golden');

Widget _harness({required ThemeMode mode, required Widget child}) {
  return RepaintBoundary(
    key: _boundaryKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: child,
    ),
  );
}

void _expectRectNear(
  WidgetTester tester,
  Key key,
  Rect expected, {
  double tolerance = 3.0,
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

const AdvanceSummary _visualAdvanceSummary = AdvanceSummary(
  orderId: '00000000-0000-4000-8000-000000000201',
  orderStatus: 'REQUESTED',
  totalAmount: '45.00',
  requiredAmount: '22.50',
  verifiedAmount: '0.00',
  remainingAmount: '22.50',
  verifiedAt: null,
);

const PaymentSummary _visualPaymentSummary = PaymentSummary(
  orderId: '00000000-0000-4000-8000-000000000201',
  orderStatus: 'REQUESTED',
  totalAmount: '45.00',
  paidAmount: '0.00',
  balance: '45.00',
  paymentStatus: 'UNPAID',
  payments: <PaymentRecord>[],
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
