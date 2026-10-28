import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    this.onBackPressed,
    this.onOpenCart,
    this.cartItemCount = 0,
    this.tableLabel,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onNotificationPressed,
    super.key,
  });

  final ThemeModeController themeModeController;
  final CatalogController catalogController;
  final VoidCallback onOpenMenu;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onBackPressed;
  final VoidCallback? onOpenCart;
  final int cartItemCount;
  final String? tableLabel;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onNotificationPressed;

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
          onBackPressed: widget.onBackPressed,
          onCartPressed: widget.onOpenCart,
          cartItemCount: widget.cartItemCount,
          tableLabel: widget.tableLabel,
          initials: widget.initials,
          avatarPath: widget.avatarPath,
          onAvatarPressed: widget.onAvatarPressed,
          onNotificationPressed: widget.onNotificationPressed,
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
    this.onBackPressed,
    this.onOpenCart,
    this.onAddProduct,
    this.useGrid = false,
    this.cartItemCount = 0,
    this.cartTotalCents = 0,
    this.tableLabel,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onNotificationPressed,
    this.showBackButton,
    super.key,
  });

  final ThemeModeController themeModeController;
  final CatalogController catalogController;
  final ValueChanged<CatalogProduct> onOpenProduct;
  final VoidCallback? onBackPressed;
  final VoidCallback? onOpenCart;
  final ValueChanged<CatalogProduct>? onAddProduct;
  final bool useGrid;
  final int cartItemCount;
  final int cartTotalCents;
  final String? tableLabel;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onNotificationPressed;
  final bool? showBackButton;

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
        final Widget page = FoundationCatalogPage(
          themeModeController: widget.themeModeController,
          onBackPressed: widget.onBackPressed,
          showBackButton: widget.showBackButton,
          onCartPressed: widget.onOpenCart,
          cartItemCount: widget.cartItemCount,
          tableLabel: widget.tableLabel,
          initials: widget.initials,
          avatarPath: widget.avatarPath,
          onAvatarPressed: widget.onAvatarPressed,
          onNotificationPressed: widget.onNotificationPressed,
          content: _BrowseCatalogContent(
            state: state,
            useGrid: widget.useGrid,
            onCategorySelected: (String categoryId) {
              unawaited(widget.catalogController.selectCategory(categoryId));
            },
            onOpenProduct: widget.onOpenProduct,
            onAddProduct: widget.onAddProduct,
            onRetry: () => unawaited(widget.catalogController.retry()),
          ),
        );

        if (widget.cartItemCount > 0 && widget.onOpenCart != null) {
          return Stack(
            children: <Widget>[
              page,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FloatingCartBar(
                  itemCount: widget.cartItemCount,
                  totalCents: widget.cartTotalCents,
                  onOpenCart: widget.onOpenCart!,
                ),
              ),
            ],
          );
        }
        return page;
      },
    );
  }
}

class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({
    required this.itemCount,
    required this.totalCents,
    required this.onOpenCart,
    super.key,
  });

  final int itemCount;
  final int totalCents;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final String items = itemCount == 1 ? '1 plato' : '$itemCount platos';
    final String price = 'S/ ${(totalCents / 100).toStringAsFixed(2)}';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          color: palette.brandRed,
          borderRadius: BorderRadius.circular(16),
          elevation: 6,
          child: InkWell(
            key: const Key('catalog-floating-cart-bar'),
            onTap: onOpenCart,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: <Widget>[
                  const Icon(
                    LucideIcons.shoppingBag,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$items · $price',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Text(
                    'Ver Carrito',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.arrowRight,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    this.useGrid = false,
    this.onAddProduct,
  });

  final CatalogState state;
  final ValueChanged<String> onCategorySelected;
  final ValueChanged<CatalogProduct> onOpenProduct;
  final VoidCallback onRetry;
  final bool useGrid;
  final ValueChanged<CatalogProduct>? onAddProduct;

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
          _ProductList(
            products: state.products,
            onOpenProduct: onOpenProduct,
            useGrid: useGrid,
            onAddProduct: onAddProduct,
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

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.onOpenProduct,
    this.useGrid = false,
    this.onAddProduct,
  });

  final List<CatalogProduct> products;
  final ValueChanged<CatalogProduct> onOpenProduct;
  final bool useGrid;
  final ValueChanged<CatalogProduct>? onAddProduct;

  @override
  Widget build(BuildContext context) {
    if (useGrid) {
      final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
      final double childAspectRatio = textScale > 1.25
          ? 0.48
          : (textScale > 1.1 ? 0.54 : 0.62);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (BuildContext context, int index) {
          final CatalogProduct product = products[index];
          return _GridProductCard(
            product: product,
            onOpenProduct: onOpenProduct,
            onAddProduct: onAddProduct,
          );
        },
      );
    }

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

class _GridProductCard extends StatelessWidget {
  const _GridProductCard({
    required this.product,
    required this.onOpenProduct,
    this.onAddProduct,
  });

  final CatalogProduct product;
  final ValueChanged<CatalogProduct> onOpenProduct;
  final ValueChanged<CatalogProduct>? onAddProduct;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool available = product.availableForSale;
    final String price = formatCatalogPrice(product.priceCents);
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double imageHeight = textScale > 1.25 ? 86.0 : 112.0;

    return Semantics(
      button: true,
      enabled: available,
      label:
          '${product.name}. $price. ${available ? "Disponible" : "No disponible"}',
      child: Material(
        key: ValueKey<String>('catalog-product-${product.id}'),
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: palette.border,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: available ? () => onOpenProduct(product) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Visual header container
              Container(
                height: imageHeight,
                color: isDark
                    ? palette.surfaceTint.withValues(alpha: 0.5)
                    : palette.surfaceTint,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/m02/food_glyph.svg',
                        width: textScale > 1.25 ? 40 : 52,
                        height: textScale > 1.25 ? 40 : 52,
                        colorFilter: ColorFilter.mode(
                          palette.accentGold,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: available
                              ? (isDark
                                  ? const Color(0xFF1C4532)
                                  : const Color(0xFFC6F6D5))
                              : (isDark
                                  ? const Color(0xFF4A151E)
                                  : const Color(0xFFFED7D7)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          available ? 'DISPONIBLE' : 'AGOTADO',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: available
                                ? (isDark
                                    ? const Color(0xFF68D391)
                                    : const Color(0xFF22543D))
                                : (isDark
                                    ? const Color(0xFFFC8181)
                                    : const Color(0xFF742A2A)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: available
                              ? palette.textPrimary
                              : palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: palette.brandRed,
                        ),
                      ),
                      const Spacer(),
                      // Platanitos-style AGREGAR button
                      SizedBox(
                        height: 32,
                        child: Material(
                          color: available
                              ? const Color(0xFF1E7E34) // Platanitos green
                              : (isDark ? Colors.grey[800] : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            key: ValueKey<String>(
                              'catalog-product-add-${product.id}',
                            ),
                            borderRadius: BorderRadius.circular(8),
                            onTap: available && onAddProduct != null
                                ? () => onAddProduct!(product)
                                : null,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        LucideIcons.shoppingBag,
                                        size: 13,
                                        color: available
                                            ? Colors.white
                                            : palette.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        available ? 'AGREGAR' : 'AGOTADO',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.bodyFontFamily,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          color: available
                                              ? Colors.white
                                              : palette.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
