import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/application/payment_status_contracts.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/application/payment_status_controller.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/domain/payment_models.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/presentation/payment_status_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/payment_fakes.dart';

void main() {
  group('AdvanceStatusPage and AdvanceSummaryPage', () {
    testWidgets('loads and renders AdvanceSummaryPage with verification pending', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository(
        advanceResponse: fakeAdvanceSummary(
          orderId: 'ord-advance-1',
          totalAmount: '45.00',
          requiredAmount: '22.50',
          verifiedAt: null,
        ),
      );
      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeModeController = ThemeModeController();
      addTearDown(() {
        controller.dispose();
        themeModeController.dispose();
      });

      var viewedOrder = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdvanceStatusPage(
            themeModeController: themeModeController,
            controller: controller,
            orderId: 'ord-advance-1',
            onViewOrder: () => viewedOrder = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-advance-summary')), findsOneWidget);
      expect(find.byKey(const Key('advance-total')), findsOneWidget);
      expect(find.byKey(const Key('advance-required')), findsOneWidget);
      expect(find.textContaining('S/ 45.00'), findsOneWidget);
      expect(find.textContaining('S/ 22.50'), findsOneWidget);
      expect(find.textContaining('Pendiente de verificación administrativa'), findsOneWidget);
      expect(find.byKey(const Key('advance-no-electronic-payment')), findsOneWidget);

      await tester.tap(find.byKey(const Key('advance-view-order')));
      expect(viewedOrder, isTrue);
    });

    testWidgets('shows verified status when verifiedAt is set', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final AdvanceSummary verifiedSummary = fakeAdvanceSummary(
        orderId: 'ord-verified',
        totalAmount: '50.00',
        requiredAmount: '25.00',
        verifiedAmount: '25.00',
        remainingAmount: '0.00',
        verifiedAt: DateTime.utc(2026, 10, 24, 18),
      );
      final ThemeModeController themeModeController = ThemeModeController();
      addTearDown(themeModeController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdvanceSummaryPage(
            themeModeController: themeModeController,
            summary: verifiedSummary,
            onViewOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('verificado por Administrador'), findsOneWidget);
    });

    testWidgets('shows error state with retry button on load failure', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository();
      repo.advanceError = const PaymentStatusFailure(
        PaymentStatusFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );
      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeModeController = ThemeModeController();
      addTearDown(() {
        controller.dispose();
        themeModeController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: AdvanceStatusPage(
            themeModeController: themeModeController,
            controller: controller,
            orderId: 'ord-fail',
            onViewOrder: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-advance-state')), findsOneWidget);
      expect(find.text('No pudimos consultar'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      repo.advanceError = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-advance-summary')), findsOneWidget);
    });
  });

  group('OrderPaymentStatusPage and PaymentSummaryPage', () {
    testWidgets('loads and renders PaymentSummaryPage with back action', (
      WidgetTester tester,
    ) async {
      await _configureSurface(tester);
      final FakePaymentStatusRepository repo = FakePaymentStatusRepository(
        paymentResponse: fakePaymentSummary(
          orderId: 'ord-pay-1',
          totalAmount: '45.00',
          paidAmount: '22.50',
          balance: '22.50',
          paymentStatus: 'PARTIAL',
        ),
      );
      final PaymentStatusController controller = PaymentStatusController(
        repository: repo,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => true,
      );
      final ThemeModeController themeModeController = ThemeModeController();
      addTearDown(() {
        controller.dispose();
        themeModeController.dispose();
      });

      var backedToOrder = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: OrderPaymentStatusPage(
            themeModeController: themeModeController,
            controller: controller,
            orderId: 'ord-pay-1',
            onBackToOrder: () => backedToOrder = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page-payment-summary')), findsOneWidget);
      expect(find.byKey(const Key('payment-total')), findsOneWidget);
      expect(find.byKey(const Key('payment-paid')), findsOneWidget);
      expect(find.byKey(const Key('payment-balance')), findsOneWidget);
      expect(find.byKey(const Key('payment-status')), findsOneWidget);
      expect(find.textContaining('Estado: PARTIAL'), findsOneWidget);
      expect(find.byKey(const Key('payment-staff-note')), findsOneWidget);

      await tester.tap(find.byKey(const Key('payment-back-to-order')));
      expect(backedToOrder, isTrue);
    });
  });
}

Future<void> _configureSurface(WidgetTester tester, [Size size = const Size(390, 844)]) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
