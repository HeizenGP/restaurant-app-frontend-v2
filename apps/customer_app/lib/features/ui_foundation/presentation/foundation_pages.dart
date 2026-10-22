import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/design_system/design_system.dart';

class FoundationHomePage extends StatelessWidget {
  const FoundationHomePage({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-inicio'),
      title: 'El sabor nos reúne',
      subtitle: 'Una tradición china con alma peruana.',
      themeModeController: themeModeController,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _BrandHero(),
          SizedBox(height: AppSpacing.xxl),
          ChifaCard(
            icon: LucideIcons.layers3,
            title: 'Una experiencia consistente',
            subtitle: 'Tema, componentes y navegación listos para crecer.',
          ),
          SizedBox(height: AppSpacing.md),
          ChifaCard(
            icon: LucideIcons.accessibility,
            title: 'Diseñada para todos',
            subtitle: 'Controles accesibles y contenido adaptable.',
          ),
        ],
      ),
    );
  }
}

class FoundationMenuPage extends StatelessWidget {
  const FoundationMenuPage({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-menu'),
      title: 'Nuestro menú',
      subtitle: 'Explora los platos disponibles de Chifa ASIA.',
      themeModeController: themeModeController,
      child: const ChifaStateView(
        kind: ChifaStateKind.empty,
        title: 'Sin resultados',
        message: 'El catálogo aparecerá aquí cuando esté disponible.',
      ),
    );
  }
}

class FoundationOrdersPage extends StatelessWidget {
  const FoundationOrdersPage({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-pedidos'),
      title: 'Mis pedidos',
      subtitle: 'Solicitudes e historial de esta cuenta.',
      themeModeController: themeModeController,
      child: const ChifaStateView(
        kind: ChifaStateKind.empty,
        title: 'Sin pedidos todavía',
        message: 'Tus solicitudes aparecerán aquí cuando las realices.',
      ),
    );
  }
}

class FoundationAccountPage extends StatelessWidget {
  const FoundationAccountPage({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-cuenta'),
      title: 'Tu cuenta',
      subtitle: 'Datos y preferencias de tu experiencia.',
      themeModeController: themeModeController,
      child: const ChifaStateView(
        kind: ChifaStateKind.empty,
        title: 'Cuenta sin configurar',
        message: 'El acceso de cliente se incorporará en el siguiente bloque.',
      ),
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Semantics(
      container: true,
      label: 'Cocina Chifa. Un antojo, un gran momento.',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 167),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: palette.brandSurface,
          borderRadius: BorderRadius.circular(AppRadii.hero),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'COCINA CHIFA',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: palette.onBrand, fontSize: 13),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Un antojo,\nun gran momento',
              style: Theme.of(context).textTheme.displayLarge
                  ?.copyWith(color: palette.onBrand),
            ),
          ],
        ),
      ),
    );
  }
}
