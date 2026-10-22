import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/domain/catalog_models.dart';
import '../../shared/presentation/catalog_widgets.dart';
import '../application/catalog_controller.dart';

class CatalogHomePage extends StatefulWidget {
  const CatalogHomePage({
    required this.catalogController,
    required this.themeModeController,
    required this.onOpenCatalog,
    required this.onCategorySelected,
    super.key,
  });

  final CatalogController catalogController;
  final ThemeModeController themeModeController;
  final VoidCallback onOpenCatalog;
  final CatalogCategoryCallback onCategorySelected;

  @override
  State<CatalogHomePage> createState() => _CatalogHomePageState();
}

class _CatalogHomePageState extends State<CatalogHomePage> {
  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CatalogHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catalogController != widget.catalogController) {
      _loadIfNeeded();
    }
  }

  void _loadIfNeeded() {
    if (widget.catalogController.state.status == CatalogStatus.initial) {
      widget.catalogController.load();
    }
  }

  void _selectCategory(CatalogCategory category) {
    widget.catalogController.selectCategory(category.id);
    widget.onCategorySelected(category);
  }

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-inicio'),
      title: 'El sabor nos reúne',
      subtitle: 'Una tradición china con alma peruana.',
      themeModeController: widget.themeModeController,
      child: AnimatedBuilder(
        animation: widget.catalogController,
        builder: (BuildContext context, Widget? child) {
          final CatalogState state = widget.catalogController.state;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _CatalogBrandHero(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Explora nuestras categorías',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              _HomeCategoryState(
                state: state,
                onSelected: _selectCategory,
                onRetry: widget.catalogController.retry,
              ),
              const SizedBox(height: AppSpacing.xl),
              ChifaCard(
                key: const Key('home-open-catalog'),
                icon: LucideIcons.utensilsCrossed,
                title: 'Nuestro menú',
                subtitle: 'Platos y precios desde el catálogo.',
                onTap: widget.onOpenCatalog,
                semanticLabel:
                    'Nuestro menú. Platos y precios desde el catálogo. Abrir.',
              ),
              const SizedBox(height: AppSpacing.md),
              const ChifaCard(
                icon: LucideIcons.info,
                title: 'Disponibilidad',
                subtitle: 'Productos habilitados para venta.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeCategoryState extends StatelessWidget {
  const _HomeCategoryState({
    required this.state,
    required this.onSelected,
    required this.onRetry,
  });

  final CatalogState state;
  final CatalogCategoryCallback onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.categories.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CatalogCategoryStrip(
            categories: state.categories,
            selectedCategoryId: state.selectedCategoryId,
            enabled: state.status != CatalogStatus.loading,
            onSelected: onSelected,
          ),
          if (state.status == CatalogStatus.loading) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(
              key: Key('home-categories-loading'),
              minHeight: 2,
            ),
          ] else if (state.status == CatalogStatus.failure) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            ChifaStateView(
              kind: ChifaStateKind.error,
              title: 'No pudimos actualizar el catálogo',
              message:
                  state.failure?.message ??
                  'Revisa tu conexión e inténtalo nuevamente.',
              actionLabel: 'Reintentar',
              onAction: onRetry,
            ),
          ],
        ],
      );
    }

    return switch (state.status) {
      CatalogStatus.initial || CatalogStatus.loading => const ChifaStateView(
        kind: ChifaStateKind.loading,
        title: 'Cargando categorías',
        message: 'Estamos consultando el menú disponible.',
      ),
      CatalogStatus.failure => ChifaStateView(
        kind: ChifaStateKind.error,
        title: 'No pudimos cargar las categorías',
        message:
            state.failure?.message ??
            'Revisa tu conexión e inténtalo nuevamente.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      ),
      CatalogStatus.success => const ChifaStateView(
        kind: ChifaStateKind.empty,
        title: 'Catálogo vacío',
        message: 'Aún no hay categorías publicadas.',
      ),
    };
  }
}

class _CatalogBrandHero extends StatelessWidget {
  const _CatalogBrandHero();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Semantics(
      container: true,
      label: 'Cocina Chifa. Un antojo, un gran momento.',
      excludeSemantics: true,
      child: Container(
        key: const Key('catalog-home-hero'),
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
