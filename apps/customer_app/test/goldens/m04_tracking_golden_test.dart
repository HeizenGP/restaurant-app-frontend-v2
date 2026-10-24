import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  setUpAll(_loadAppFonts);

  for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
    ('light', ThemeMode.light),
    ('dark', ThemeMode.dark),
  ]) {
    testWidgets('16 tracking matches the $suffix baseline', (
      WidgetTester tester,
    ) async {
      await _configureFigmaViewport(tester);
      final ThemeModeController themeController = ThemeModeController(
        initialMode: mode,
      );
      addTearDown(themeController.dispose);

      await tester.pumpWidget(
        _harness(
          mode: mode,
          child: _TrackingTestWrapper(
            themeModeController: themeController,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      _expectRectNear(
        tester,
        const Key('tracking-stage-card'),
        const Rect.fromLTWH(24, 190, 342, 77),
      );
      _expectNoBottomNavigation();

      await expectLater(
        find.byKey(_boundaryKey),
        matchesGoldenFile('m04_tracking_16_tracking_$suffix.png'),
      );
    });
  }
}

class _TrackingTestWrapper extends StatelessWidget {
  const _TrackingTestWrapper({required this.themeModeController});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return _TrackingFrameMock(
      child: ChifaPageScaffold(
        pageKey: const Key('page-order-tracking'),
        title: 'Detalle y seguimiento',
        subtitle: 'Estado en tiempo real de tu pedido.',
        contentGap: 24,
        themeModeController: themeModeController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChifaCard(
              key: const Key('tracking-stage-card'),
              icon: LucideIcons.clock3,
              iconColor: _figmaIconColor(context),
              title: 'Etapa: EN_COCINA',
              subtitle: 'Estado: CONFIRMED · Cocina: PREPARING',
              minimumHeight: 77,
            ),
            const SizedBox(height: 16),
            ChifaCard(
              key: const Key('tracking-modality-card'),
              icon: LucideIcons.mapPin,
              iconColor: _figmaIconColor(context),
              title: 'Entrega a domicilio',
              subtitle: 'Dirección: Av. Las Begonias 123',
              minimumHeight: 77,
            ),
            const SizedBox(height: 16),
            ChifaCard(
              key: const Key('tracking-products-card'),
              icon: LucideIcons.utensilsCrossed,
              iconColor: _figmaIconColor(context),
              title: 'Productos (1)',
              subtitle: '2x Chaufa Especial · S/ 24.25',
              minimumHeight: 90,
            ),
            const SizedBox(height: 16),
            ChifaCard(
              key: const Key('tracking-payment-card'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Estado de pago: PARTIAL',
              subtitle: 'Total: S/ 48.50 · Pagado: S/ 24.25 · Saldo: S/ 24.25',
              minimumHeight: 77,
            ),
            const SizedBox(height: 28),
            ChifaButton(
              key: const Key('tracking-advance-button'),
              label: 'Ver anticipo (50 %)',
              height: 50,
              borderRadius: 14,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            ChifaButton(
              key: const Key('tracking-payments-button'),
              label: 'Ver estado de pagos',
              height: 50,
              borderRadius: 14,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            ChifaButton(
              key: const Key('tracking-back-button'),
              label: 'Volver a mis pedidos',
              height: 54,
              borderRadius: 14,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Color _figmaIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE2BC75)
        : const Color(0xFF922832);
  }
}

class _TrackingFrameMock extends StatelessWidget {
  const _TrackingFrameMock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}

const Key _boundaryKey = Key('m04-tracking-golden');

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
