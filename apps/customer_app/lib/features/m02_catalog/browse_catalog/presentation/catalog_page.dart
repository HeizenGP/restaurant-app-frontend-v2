import 'package:flutter/material.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/domain/catalog_models.dart';
import '../../shared/presentation/catalog_widgets.dart';
import '../application/catalog_controller.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    required this.catalogController,
    required this.themeModeController,
    required this.onProductSelected,
    super.key,
  });

  final CatalogController catalogController;
  final ThemeModeController themeModeController;
  final CatalogProductCallback onProductSelected;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CatalogPage oldWidget) {
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
  }

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-menu'),
      title: 'Nuestro menú',
      subtitle: 'Elige una categoría y descubre los platos.',
      themeModeController: widget.themeModeController,
      child: AnimatedBuilder(
        animation: widget.catalogController,
        builder: (BuildContext context, Widget? child) {
          final CatalogState state = widget.catalogController.state;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.categories.isNotEmpty) ...<Widget>[
                CatalogCategoryStrip(
                  categories: state.categories,
                  selectedCategoryId: state.selectedCategoryId,
                  enabled: state.status != CatalogStatus.loading,
                  onSelected: _selectCategory,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _CatalogBody(
                state: state,
                onRetry: widget.catalogController.retry,
                onProductSelected: widget.onProductSelected,
              ),
              if (state.status == CatalogStatus.success &&
                  state.categories.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Fotos y descripciones: la API del catálogo no las ofrece.',
                  key: const Key('catalog-api-field-notice'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
    required this.state,
    required this.onRetry,
    required this.onProductSelected,
  });

  final CatalogState state;
  final VoidCallback onRetry;
  final CatalogProductCallback onProductSelected;

  @override
  Widget build(BuildContext context) {
    if (state.status == CatalogStatus.initial ||
        state.status == CatalogStatus.loading) {
      return const ChifaStateView(
        kind: ChifaStateKind.loading,
        title: 'Cargando platos',
        message: 'Estamos consultando precios y disponibilidad.',
      );
    }

    if (state.status == CatalogStatus.failure) {
      final String title = state.failureScope == CatalogFailureScope.categories
          ? 'No pudimos cargar el catálogo'
          : 'No pudimos cargar esta categoría';
      return ChifaStateView(
        kind: ChifaStateKind.error,
        title: title,
        message:
            state.failure?.message ??
            'Revisa tu conexión e inténtalo nuevamente.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }

    if (state.hasEmptyCatalog) {
      return const ChifaStateView(
        kind: ChifaStateKind.empty,
        title: 'Catálogo vacío',
        message: 'Aún no hay categorías publicadas.',
      );
    }

    if (state.hasEmptyCategory) {
      return const ChifaStateView(
        kind: ChifaStateKind.empty,
        title: 'Categoría sin productos',
        message: 'No hay platos publicados en esta categoría.',
      );
    }

    final CatalogCategory? category = state.selectedCategory;
    if (category == null) {
      return ChifaStateView(
        kind: ChifaStateKind.error,
        title: 'Catálogo no disponible',
        message: 'No pudimos relacionar los platos con su categoría.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }

    return Column(
      key: const Key('catalog-product-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < state.products.length; index++) ...<Widget>[
          CatalogProductCard(
            product: state.products[index],
            category: category,
            onSelected: onProductSelected,
          ),
          if (index != state.products.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
