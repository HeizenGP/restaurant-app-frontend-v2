import 'dart:ui' show SemanticsActionEvent, Tristate;

import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('card, field and button are reusable and interactive', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);
    var presses = 0;
    var cardPresses = 0;
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: <Widget>[
                ChifaCard(
                  icon: LucideIcons.userRoundPlus,
                  title: 'Sin registro',
                  subtitle: 'Puedes crear una cuenta más adelante.',
                  semanticLabel: 'Crear cuenta más adelante',
                  onTap: () => cardPresses += 1,
                ),
                const SizedBox(height: AppSpacing.lg),
                ChifaTextField(
                  label: 'Correo electrónico',
                  hintText: 'correo@ejemplo.com',
                  controller: controller,
                  leadingIcon: LucideIcons.mail,
                ),
                const SizedBox(height: AppSpacing.lg),
                ChifaButton(label: 'Continuar', onPressed: () => presses += 1),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sin registro'), findsOneWidget);
    expect(find.byIcon(LucideIcons.userRoundPlus), findsOneWidget);
    expect(find.bySemanticsLabel('Continuar'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Continuar'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(find.bySemanticsLabel('Crear cuenta más adelante'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Crear cuenta más adelante'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    final Finder fieldSemantics = find.bySemanticsLabel(
      RegExp('Correo electrónico'),
    );
    expect(fieldSemantics, findsOneWidget);
    expect(
      tester
          .getSemantics(fieldSemantics)
          .getSemanticsData()
          .flagsCollection
          .isTextField,
      isTrue,
    );

    await tester.enterText(find.byType(TextFormField), 'cliente@asia.test');
    final SemanticsNode buttonNode = tester.getSemantics(
      find.bySemanticsLabel('Continuar'),
    );
    tester.binding.platformDispatcher.onSemanticsActionEvent!(
      SemanticsActionEvent(
        type: SemanticsAction.tap,
        viewId: tester.view.viewId,
        nodeId: buttonNode.id,
      ),
    );
    await tester.tap(find.bySemanticsLabel('Crear cuenta más adelante'));
    await tester.pump();

    expect(controller.text, 'cliente@asia.test');
    expect(presses, 1);
    expect(cardPresses, 1);
    semantics.dispose();
  });

  testWidgets('disabled card keeps its button role without a tap action', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var presses = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ChifaCard(
            title: 'Acción bloqueada',
            subtitle: 'Todavía no está disponible.',
            semanticLabel: 'Acción no disponible',
            enabled: false,
            onTap: () => presses += 1,
          ),
        ),
      ),
    );

    final SemanticsData data = tester
        .getSemantics(find.bySemanticsLabel('Acción no disponible'))
        .getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.isEnabled, Tristate.isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    expect(presses, 0);
    semantics.dispose();
  });

  testWidgets('loading, empty and error states expose clear semantics', (
    WidgetTester tester,
  ) async {
    var retryPresses = 0;
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: <Widget>[
                const ChifaStateView(
                  kind: ChifaStateKind.loading,
                  title: 'Cargando…',
                  message: 'Indicador de espera y contenido reservado.',
                ),
                const SizedBox(height: AppSpacing.md),
                const ChifaStateView(
                  kind: ChifaStateKind.empty,
                  title: 'Sin resultados',
                  message: 'No hay elementos disponibles.',
                ),
                const SizedBox(height: AppSpacing.md),
                ChifaStateView(
                  kind: ChifaStateKind.error,
                  title: 'No disponible',
                  message: 'Ocurrió un error al cargar.',
                  actionLabel: 'Reintentar',
                  onAction: () => retryPresses += 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(RegExp('Cargando')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Sin resultados')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('No disponible')), findsOneWidget);
    expect(find.byIcon(LucideIcons.clock3), findsOneWidget);
    expect(find.byIcon(LucideIcons.circleAlert), findsOneWidget);
    expect(find.bySemanticsLabel('Reintentar'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Reintentar'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );

    await tester.tap(find.bySemanticsLabel('Reintentar'));
    expect(retryPresses, 1);
    semantics.dispose();
  });

  testWidgets('page scaffold uses only its Figma gutter on a wide phone', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(432, 900);
    addTearDown(tester.view.reset);
    final ThemeModeController themeController = ThemeModeController();
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ChifaPageScaffold(
            title: 'Pantalla adaptable',
            subtitle: 'Sin margen lateral añadido',
            themeModeController: themeController,
            child: const SizedBox(
              key: Key('wide-page-content'),
              height: 40,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Rect content = tester.getRect(
      find.byKey(const Key('wide-page-content')),
    );
    expect(content.left, 24);
    expect(content.right, 408);
    expect(tester.takeException(), isNull);
  });
}
