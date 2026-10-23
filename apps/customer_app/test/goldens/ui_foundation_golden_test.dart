import 'package:customer_app/app/navigation/customer_bottom_navigation.dart';
import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:customer_app/features/ui_foundation/presentation/foundation_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  // Reference fixtures reproduce Figma's sample content only inside tests.
  // Production routes keep their real empty states until data is available.
  final List<_VisualCase> cases = <_VisualCase>[
    _VisualCase(
      name: '08_home',
      selectedIndex: 0,
      pageBuilder: (ThemeModeController controller) => FoundationHomePage(
        themeModeController: controller,
        content: const _HomeReferenceContent(),
      ),
    ),
    _VisualCase(
      name: '09_catalog',
      selectedIndex: 1,
      pageBuilder: (ThemeModeController controller) => FoundationCatalogPage(
        themeModeController: controller,
        content: const _CatalogReferenceContent(),
      ),
    ),
    _VisualCase(
      name: '15_orders',
      selectedIndex: 2,
      pageBuilder: (ThemeModeController controller) => FoundationOrdersPage(
        themeModeController: controller,
        content: const _OrdersReferenceContent(),
      ),
    ),
    _VisualCase(
      name: '19_account',
      selectedIndex: 3,
      pageBuilder: (ThemeModeController controller) => FoundationAccountPage(
        themeModeController: controller,
        isGuest: false,
        displayName: 'Nombre del cliente',
        email: 'correo@ejemplo.com',
        avatarInitials: 'C',
        accountCardName: 'Nombre desde tu cuenta',
        accountCardEmail: 'Correo desde tu cuenta',
      ),
    ),
    _VisualCase(
      name: '20_states',
      selectedIndex: 0,
      pageBuilder: (ThemeModeController controller) =>
          FoundationInterfaceStatesPage(themeModeController: controller),
    ),
    _VisualCase(
      name: 'operational_08_home_empty',
      evidence: 'operational regression',
      selectedIndex: 0,
      pageBuilder: (ThemeModeController controller) =>
          FoundationHomePage(themeModeController: controller),
    ),
    _VisualCase(
      name: 'operational_09_catalog_empty',
      evidence: 'operational regression',
      selectedIndex: 1,
      pageBuilder: (ThemeModeController controller) =>
          FoundationCatalogPage(themeModeController: controller),
    ),
    _VisualCase(
      name: 'operational_15_orders_empty',
      evidence: 'operational regression',
      selectedIndex: 2,
      pageBuilder: (ThemeModeController controller) =>
          FoundationOrdersPage(themeModeController: controller),
    ),
    _VisualCase(
      name: 'operational_19_account_registered',
      evidence: 'operational regression',
      selectedIndex: 3,
      pageBuilder: (ThemeModeController controller) => FoundationAccountPage(
        themeModeController: controller,
        isGuest: false,
        displayName: 'Ana Torres',
        email: 'ana@example.com',
      ),
    ),
    _VisualCase(
      name: 'operational_19_account_guest',
      evidence: 'operational regression',
      selectedIndex: 3,
      pageBuilder: (ThemeModeController controller) => FoundationAccountPage(
        themeModeController: controller,
        isGuest: true,
        displayName: null,
        email: null,
      ),
    ),
  ];

  setUpAll(_loadAppFonts);

  for (final _VisualCase visualCase in cases) {
    for (final (String suffix, ThemeMode mode) in <(String, ThemeMode)>[
      ('light', ThemeMode.light),
      ('dark', ThemeMode.dark),
    ]) {
      testWidgets(
        '${visualCase.name} ${visualCase.evidence} matches the $suffix '
        'Flutter baseline',
        (WidgetTester tester) async {
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
        },
      );
    }
  }
}

class _VisualCase {
  const _VisualCase({
    required this.name,
    required this.selectedIndex,
    required this.pageBuilder,
    this.evidence = 'Figma reference fixture',
  });

  final String name;
  final int selectedIndex;
  final Widget Function(ThemeModeController controller) pageBuilder;
  final String evidence;
}

class _HomeReferenceContent extends StatelessWidget {
  const _HomeReferenceContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 30,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Explora nuestras categorías',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _ReferenceChipRow(
          children: <Widget>[
            ChifaChip(label: 'Arroces', width: 103),
            SizedBox(width: 11),
            ChifaChip(label: 'Tallarines', width: 103),
            SizedBox(width: 10),
            ChifaChip(label: 'Especiales', width: 115),
          ],
        ),
        const SizedBox(height: 30),
        ChifaCard(
          icon: LucideIcons.utensilsCrossed,
          title: 'Nuestro menú',
          subtitle: 'Platos y precios desde el catálogo.',
          trailing: Icon(
            LucideIcons.chevronRight,
            color: context.appPalette.cardTextSecondary,
            size: 17,
          ),
        ),
        const SizedBox(height: 10),
        const ChifaCard(
          icon: LucideIcons.info,
          title: 'Disponibilidad',
          subtitle: 'Productos habilitados para venta.',
        ),
      ],
    );
  }
}

class _CatalogReferenceContent extends StatelessWidget {
  const _CatalogReferenceContent();

  @override
  Widget build(BuildContext context) {
    final Widget chevron = Icon(
      LucideIcons.chevronRight,
      color: context.appPalette.cardTextSecondary,
      size: 17,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _ReferenceChipRow(
          children: <Widget>[
            ChifaChip(label: 'Arroces', width: 99),
            SizedBox(width: 11),
            ChifaChip(label: 'Tallarines', width: 111),
            SizedBox(width: 11),
            ChifaChip(label: 'Especiales', width: 110),
          ],
        ),
        const SizedBox(height: 23),
        ChifaCard(
          icon: LucideIcons.utensilsCrossed,
          title: 'Plato del catálogo',
          subtitle: 'Nombre · precio desde API · disponible',
          minimumHeight: 98,
          trailing: chevron,
        ),
        const SizedBox(height: 10),
        ChifaCard(
          icon: LucideIcons.info,
          title: 'Otra opción disponible',
          subtitle: 'Nombre · precio desde API · disponible',
          minimumHeight: 98,
          trailing: chevron,
        ),
        const SizedBox(height: 10),
        const ChifaCard(
          icon: LucideIcons.utensilsCrossed,
          title: 'Producto agotado',
          subtitle: 'No disponible para incorporar',
          minimumHeight: 98,
        ),
        const SizedBox(height: 10),
        ChifaCard(
          icon: LucideIcons.utensilsCrossed,
          title: 'Otra categoría',
          subtitle: 'Se actualiza al seleccionar categoría',
          minimumHeight: 98,
          trailing: chevron,
        ),
        const SizedBox(height: 29),
        Text(
          'Fotos y descripciones: API no disponible',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _OrdersReferenceContent extends StatelessWidget {
  const _OrdersReferenceContent();

  @override
  Widget build(BuildContext context) {
    final Widget chevron = Icon(
      LucideIcons.chevronRight,
      color: context.appPalette.cardTextSecondary,
      size: 17,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _ReferenceChipRow(
          children: <Widget>[
            ChifaChip(label: 'Todos', width: 98),
            SizedBox(width: 14),
            ChifaChip(label: 'Pendientes', width: 113),
            SizedBox(width: 10),
            ChifaChip(label: 'Confirmados', width: 107),
          ],
        ),
        const SizedBox(height: 24),
        ChifaCard(
          icon: LucideIcons.receiptText,
          title: 'Pedido # · reciente',
          subtitle: 'REQUESTED · pendiente de aprobación',
          minimumHeight: 119,
          trailing: chevron,
        ),
        const SizedBox(height: 10),
        ChifaCard(
          icon: LucideIcons.receiptText,
          title: 'Pedido # · confirmado',
          subtitle: 'CONFIRMED · ver detalle',
          minimumHeight: 119,
          trailing: chevron,
        ),
        const SizedBox(height: 10),
        ChifaCard(
          icon: LucideIcons.receiptText,
          title: 'Pedido # · rechazado',
          subtitle: 'REJECTED · consultar motivo/estado',
          minimumHeight: 119,
          trailing: chevron,
        ),
      ],
    );
  }
}

class _ReferenceChipRow extends StatelessWidget {
  const _ReferenceChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 35, child: Row(children: children));
  }
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
