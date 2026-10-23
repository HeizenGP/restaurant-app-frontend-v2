import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/ui_foundation/presentation/foundation_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<_VisualCase> cases = <_VisualCase>[
    _VisualCase(
      name: '08_home',
      selectedIndex: 0,
      pageBuilder: (ThemeModeController controller) =>
          FoundationHomePage(themeModeController: controller),
    ),
    _VisualCase(
      name: '09_catalog',
      selectedIndex: 1,
      pageBuilder: (ThemeModeController controller) =>
          FoundationCatalogPage(themeModeController: controller),
    ),
    _VisualCase(
      name: '15_orders',
      selectedIndex: 2,
      pageBuilder: (ThemeModeController controller) =>
          FoundationOrdersPage(themeModeController: controller),
    ),
    _VisualCase(
      name: '19_account',
      selectedIndex: 3,
      pageBuilder: (ThemeModeController controller) =>
          FoundationAccountPage(themeModeController: controller),
    ),
    _VisualCase(
      name: '20_states',
      selectedIndex: 0,
      pageBuilder: (ThemeModeController controller) =>
          FoundationInterfaceStatesPage(themeModeController: controller),
    ),
  ];

  setUpAll(_loadAppFonts);

  for (final _VisualCase visualCase in cases) {
    for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
      ('light', ThemeMode.light),
      ('dark', ThemeMode.dark),
    ]) {
      testWidgets('${visualCase.name} matches the $suffix Flutter baseline', (
        WidgetTester tester,
      ) async {
        await _configureFigmaViewport(tester);
        final ThemeModeController controller = ThemeModeController(
          initialMode: mode,
        );
        addTearDown(controller.dispose);
        const Key boundaryKey = Key('ui-foundation-golden');

        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              home: Builder(
                builder: (BuildContext context) {
                  return Scaffold(
                    body: visualCase.pageBuilder(controller),
                    bottomNavigationBar: ColoredBox(
                      color: context.appPalette.background,
                      child: SafeArea(
                        top: false,
                        child: CustomerBottomNavigation(
                          currentIndex: visualCase.selectedIndex,
                          onDestinationSelected: (_) {},
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await expectLater(
          find.byKey(boundaryKey),
          matchesGoldenFile('ui_foundation_${visualCase.name}_$suffix.png'),
        );
      });
    }
  }
}

class _VisualCase {
  const _VisualCase({
    required this.name,
    required this.selectedIndex,
    required this.pageBuilder,
  });

  final String name;
  final int selectedIndex;
  final Widget Function(ThemeModeController controller) pageBuilder;
}

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
