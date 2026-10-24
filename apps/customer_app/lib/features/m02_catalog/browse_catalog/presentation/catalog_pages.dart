import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../ui_foundation/presentation/foundation_pages.dart';
import '../../shared/domain/catalog_models.dart';
import '../application/catalog_controller.dart';

class CatalogHomePage extends StatefulWidget {
  const CatalogHomePage({
    required this.themeModeController,
    required this.catalogController,
    required this.onOpenMenu,
    required this.onCategorySelected,
    super.key,
  });

  final ThemeModeController themeModeController;
  final CatalogController catalogController;
  final VoidCallback onOpenMenu;
  final ValueChanged<String> onCategorySelected;

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
  void didUpdateWidget(CatalogHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catalogController != widget.catalogController) {
      _loadIfNeeded();
    }
  }

  void _loadIfNeeded() {
    if (widget.catalogController.state.status == CatalogStatus.initial) {
      unawaited(widget.catalogController.loadCatalog());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.catalogController,
      builder: (BuildContext context, Widget? child) {
        final CatalogState state = widget.catalogController.state;
        return FoundationHomePage(
          themeModeController: widget.themeModeController,
          content: _HomeCatalogContent(
            state: state,
            onOpenMenu: widget.onOpenMenu,
            onCategorySelected: widget.onCategorySelected,
            onRetry: () => unawaited(widget.catalogController.retry()),
          ),
        );
      },
    );
  }
}

class CatalogBrowsePage extends StatefulWidget {
  const CatalogBrowsePage({
    required this.themeModeController,
    required this.catalogController,
    required this.onOpenProduct,
    super.key,
  });

  final ThemeModeController themeModeController;
  final CatalogController catalogController;
  final ValueChanged<CatalogProduct> onOpenProduct;

  @override
  State<CatalogBrowsePage> createState() => _CatalogBrowsePageState();
}

class _CatalogBrowsePageState extends State<CatalogBrowsePage> {
  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(CatalogBrowsePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.catalogController != widget.catalogController) {
      _loadIfNeeded();
    }
  }

  void _loadIfNeeded() {
    if (widget.catalogController.state.status == CatalogStatus.initial) {
      unawaited(widget.catalogController.loadCatalog());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.catalogController,
      builder: (BuildContext context, Widget? child) {
        final CatalogState state = widget.catalogController.state;
        return FoundationCatalogPage(
          themeModeController: widget.themeModeController,
          content: _BrowseCatalogContent(
            state: state,
            onCategorySelected: (String categoryId) {
              unawaited(widget.catalogController.selectCategory(categoryId));
            },
            onOpenProduct: widget.onOpenProduct,
            onRetry: () => unawaited(widget.catalogController.retry()),
          ),
        );
      },
    );
  }
}

class _HomeCatalogContent extends StatelessWidget {
  const _HomeCatalogContent({
    required this.state,
    required this.onOpenMenu,
    required this.onCategorySelected,
    required this.onRetry,
  });

  final CatalogState state;
  final VoidCallback onOpenMenu;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoad(state)) {
      return const ChifaStateView(
        key: Key('home-catalog-loading'),
        kind: ChifaStateKind.loading,
        title: 'Cargando catálogo…',
        message: 'Consultando categorías y productos disponibles',
      );
    }
    if (_hasCategoryFailure(state)) {
      return ChifaStateView(
        key: const Key('home-catalog-error'),
        kind: ChifaStateKind.error,
        title: 'No pudimos cargar el catálogo',
        message: state.failure!.message,
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }
    if (state.hasEmptyCatalog) {
      return const ChifaStateView(
        key: Key('home-empty-catalog'),
        kind: ChifaStateKind.empty,
        title: 'Sin categorías disponibles',
        message: 'No hay datos del catálogo para mostrar por ahora',
      );
    }

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
        _CategoryStrip(
          categories: state.categories,
          selectedCategoryId: state.selectedCategoryId,
          onSelected: onCategorySelected,
        ),
        const SizedBox(height: 30),
        ChifaCard(
          key: const Key('home-open-menu'),
          icon: LucideIcons.utensilsCrossed,
          title: 'Nuestro menú',
          subtitle: 'Platos y precios desde el catálogo.',
          onTap: onOpenMenu,
        ),
        const SizedBox(height: 10),
        if (state.status == CatalogStatus.failure)
          ChifaStateView(
            key: const Key('home-products-error'),
            kind: ChifaStateKind.error,
            title: 'Disponibilidad no disponible',
            message: state.failure!.message,
            actionLabel: 'Reintentar',
            onAction: onRetry,
          )
        else if (state.status == CatalogStatus.loading)
          const ChifaStateView(
            key: Key('home-products-loading'),
            kind: ChifaStateKind.loading,
            title: 'Consultando disponibilidad…',
            message: 'Actualizando los productos de esta categoría',
          )
        else
          const ChifaCard(
            key: Key('home-availability-card'),
            icon: LucideIcons.info,
            title: 'Disponibilidad',
            subtitle: 'Productos habilitados para venta.',
          ),
      ],
    );
  }
}

class _BrowseCatalogContent extends StatelessWidget {
  const _BrowseCatalogContent({
    required this.state,
    required this.onCategorySelected,
    required this.onOpenProduct,
    required this.onRetry,
  });

  final CatalogState state;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<CatalogProduct> onOpenProduct;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoad(state)) {
      return const ChifaStateView(
        key: Key('catalog-loading-state'),
        kind: ChifaStateKind.loading,
        title: 'Cargando menú…',
        message: 'Consultando las categorías disponibles',
      );
    }
    if (_hasCategoryFailure(state)) {
      return ChifaStateView(
        key: const Key('catalog-error-state'),
        kind: ChifaStateKind.error,
        title: 'No pudimos cargar el menú',
        message: state.failure!.message,
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );
    }
    if (state.hasEmptyCatalog) {
      return const ChifaStateView(
        key: Key('catalog-empty-state'),
        kind: ChifaStateKind.empty,
        title: 'Sin productos disponibles',
        message: 'No hay datos reales del catálogo para mostrar',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _CategoryStrip(
          categories: state.categories,
          selectedCategoryId: state.selectedCategoryId,
          onSelected: onCategorySelected,
        ),
        const SizedBox(height: 23),
        if (state.status == CatalogStatus.loading)
          const ChifaStateView(
            key: Key('catalog-products-loading'),
            kind: ChifaStateKind.loading,
            title: 'Cargando productos…',
            message: 'Consultando la categoría seleccionada',
          )
        else if (state.status == CatalogStatus.failure)
          ChifaStateView(
            key: const Key('catalog-products-error'),
            kind: ChifaStateKind.error,
            title: 'No pudimos cargar los productos',
            message: state.failure!.message,
            actionLabel: 'Reintentar',
            onAction: onRetry,
          )
        else if (state.hasEmptyCategory)
          const ChifaStateView(
            key: Key('catalog-category-empty'),
            kind: ChifaStateKind.empty,
            title: 'Categoría vacía',
            message: 'No hay productos disponibles en esta categoría',
          )
        else
          _ProductList(products: state.products, onOpenProduct: onOpenProduct),
        const SizedBox(height: 29),
        Text(
          'Fotos y descripciones: API no disponible',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products, required this.onOpenProduct});

  final List<CatalogProduct> products;
  final ValueChanged<CatalogProduct> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < products.length; index++) ...<Widget>[
          _ProductCard(product: products[index], onOpenProduct: onOpenProduct),
          if (index != products.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onOpenProduct});

  final CatalogProduct product;
  final ValueChanged<CatalogProduct> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final String availability = product.availableForSale
        ? 'Disponible'
        : 'No disponible';
    final String price = formatCatalogPrice(product.priceCents);
    return ChifaCard(
      key: ValueKey<String>('catalog-product-${product.id}'),
      icon: LucideIcons.utensilsCrossed,
      title: product.name,
      subtitle: '$price · $availability',
      minimumHeight: 98,
      onTap: product.availableForSale ? () => onOpenProduct(product) : null,
      semanticLabel: '${product.name}. $price. $availability',
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<CatalogCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int visibleCount = categories.length < 3 ? categories.length : 3;
        const double gap = 11;
        final double itemWidth =
            ((constraints.maxWidth - gap * (visibleCount - 1)) / visibleCount)
                .clamp(96, 122);

        return SizedBox(
          height: 35,
          child: ListView.separated(
            key: const Key('catalog-category-strip'),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: gap);
            },
            itemBuilder: (BuildContext context, int index) {
              final CatalogCategory category = categories[index];
              return Semantics(
                selected: category.id == selectedCategoryId,
                child: ChifaChip(
                  key: ValueKey<String>('catalog-category-${category.id}'),
                  label: category.name,
                  width: itemWidth,
                  onPressed: () => onSelected(category.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

bool _isInitialLoad(CatalogState state) {
  return (state.status == CatalogStatus.initial ||
          state.status == CatalogStatus.loading) &&
      state.categories.isEmpty;
}

bool _hasCategoryFailure(CatalogState state) {
  return state.status == CatalogStatus.failure &&
      state.failureScope == CatalogFailureScope.categories;
}

String formatCatalogPrice(int priceCents) {
  final int units = priceCents ~/ 100;
  final int cents = priceCents.remainder(100);
  return 'S/ $units.${cents.toString().padLeft(2, '0')}';
}
