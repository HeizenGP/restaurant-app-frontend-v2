import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../../m04_orders/manage_cart/application/cart_controller.dart';
import '../../m04_orders/manage_cart/domain/cart_models.dart';
import '../browse_catalog/application/catalog_controller.dart';
import '../shared/domain/catalog_models.dart';
import '../view_product/application/product_detail_controller.dart';

// Helper de formato de precio en Soles
String formatPrice(int priceCents) {
  final double soles = priceCents / 100.0;
  return 'S/ ${soles.toStringAsFixed(2)}';
}

// Icono según categoría gastronómica de KAIRO
IconData getCategoryIcon(String categoryName) {
  final String lower = categoryName.toLowerCase();
  if (lower.contains('arroz') || lower.contains('chaufa')) return LucideIcons.cookingPot;
  if (lower.contains('tallar') || lower.contains('fideo')) return LucideIcons.utensils;
  if (lower.contains('sopa') || lower.contains('want')) return LucideIcons.soup;
  if (lower.contains('bebida') || lower.contains('chicha')) return LucideIcons.glassWater;
  if (lower.contains('especial') || lower.contains('piqueo')) return LucideIcons.sparkles;
  return LucideIcons.utensilsCrossed;
}

// ==============================================================================
// 1. HOME / INICIO
// ==============================================================================

class HomePage extends StatefulWidget {
  const HomePage({
    required this.catalogController,
    required this.cartController,
    required this.onNavigateToMenu,
    required this.onNavigateToCart,
    required this.onProductSelected,
    required this.onToggleTheme,
    required this.isDark,
    super.key,
  });

  final CatalogController catalogController;
  final CartController cartController;
  final VoidCallback onNavigateToMenu;
  final VoidCallback onNavigateToCart;
  final void Function(CatalogCategory category, CatalogProduct product) onProductSelected;
  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (widget.catalogController.state.status == CatalogStatus.initial) {
      widget.catalogController.loadCatalog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[widget.catalogController, widget.cartController]),
      builder: (BuildContext context, _) {
        final CatalogState state = widget.catalogController.state;
        final int cartCount = widget.cartController.state.totalQuantity;

        return AsiaScaffold(
          title: 'KAIRO',
          subtitle: 'Alta Cocina Asiática Contemporánea',
          onToggleTheme: widget.onToggleTheme,
          isDark: widget.isDark,
          onCartTap: widget.onNavigateToCart,
          cartCount: cartCount,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 12),
              // Banner Hero Destacado
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      theme.brandCrimson,
                      theme.brandCrimson.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AsiaRadii.brCard,
                  boxShadow: !theme.isDark
                      ? <BoxShadow>[
                          BoxShadow(
                            color: theme.brandCrimson.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AsiaRadii.brPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(LucideIcons.flame, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Wok Hei & Alta Gastronomía',
                            style: AsiaTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Experiencia culinaria\nasiática en tu mesa',
                      style: AsiaTypography.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fusión cantonesa, nikkei y especialidades al wok preparadas al momento.',
                      style: AsiaTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AsiaPressable(
                      onPressed: widget.onNavigateToMenu,
                      borderRadius: AsiaRadii.brPill,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AsiaRadii.brPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Explorar Carta Completa',
                              style: AsiaTypography.labelMedium.copyWith(
                                color: theme.brandCrimson,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(LucideIcons.arrowRight, size: 16, color: theme.brandCrimson),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categorías Rápidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Categorías populares',
                    style: AsiaTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  AsiaPressable(
                    onPressed: widget.onNavigateToMenu,
                    child: Text(
                      'Ver todas',
                      style: AsiaTypography.labelMedium.copyWith(
                        color: theme.brandCrimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: state.categories.map((CatalogCategory cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: AsiaPressable(
                          onPressed: () {
                            widget.catalogController.selectCategory(cat.id);
                            widget.onNavigateToMenu();
                          },
                          borderRadius: AsiaRadii.brCard,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: AsiaRadii.brCard,
                              border: Border.all(color: theme.border, width: 0.8),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: theme.surfaceSubtle,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    getCategoryIcon(cat.name),
                                    size: 17,
                                    color: theme.brandCrimson,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  cat.name,
                                  style: AsiaTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 26),

              // Platos Destacados
              Text(
                'Nuestras recomendaciones',
                style: AsiaTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (state.status == CatalogStatus.loading)
                const AsiaStateView(
                  kind: AsiaStateKind.loading,
                  title: 'Preparando la carta',
                  message: 'Cargando deliciosos platos...',
                )
              else if (state.products.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.products.take(6).length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final CatalogProduct prod = state.products[index];
                    final CatalogCategory? currentCat = state.categories.cast<CatalogCategory?>().firstWhere(
                          (CatalogCategory? c) => c?.id == prod.categoryId,
                          orElse: () => null,
                        );

                    return _ProductCard(
                      product: prod,
                      categoryName: currentCat?.name ?? 'KAIRO',
                      onTap: () {
                        if (currentCat != null) {
                          widget.onProductSelected(currentCat, prod);
                        }
                      },
                      onAddToCart: () {
                        widget.cartController.addProduct(
                          CartProductSnapshot(
                            id: prod.id,
                            categoryId: prod.categoryId,
                            name: prod.name,
                            unitPriceCents: prod.priceCents,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${prod.name} agregado al carrito'),
                            backgroundColor: theme.brandCrimson,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                )
              else
                const AsiaStateView(
                  kind: AsiaStateKind.empty,
                  title: 'Pronto añadiremos más platos',
                  message: 'Explora el menú para ver categorías disponibles.',
                ),
              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }
}

// ==============================================================================
// 2. EXPLORADOR DE CATÁLOGO / MENÚ
// ==============================================================================

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    required this.catalogController,
    required this.cartController,
    required this.onProductSelected,
    required this.onNavigateToCart,
    required this.onToggleTheme,
    required this.isDark,
    super.key,
  });

  final CatalogController catalogController;
  final CartController cartController;
  final void Function(CatalogCategory category, CatalogProduct product) onProductSelected;
  final VoidCallback onNavigateToCart;
  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.catalogController.state.status == CatalogStatus.initial) {
      widget.catalogController.loadCatalog();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[widget.catalogController, widget.cartController]),
      builder: (BuildContext context, _) {
        final CatalogState state = widget.catalogController.state;
        final int cartCount = widget.cartController.state.totalQuantity;

        // Filtrado por buscador
        final List<CatalogProduct> filteredProducts = state.products.where((CatalogProduct p) {
          if (_searchQuery.isEmpty) return true;
          return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        final CatalogCategory? selectedCategory = state.categories.cast<CatalogCategory?>().firstWhere(
              (CatalogCategory? c) => c?.id == state.selectedCategoryId,
              orElse: () => state.categories.isNotEmpty ? state.categories.first : null,
            );

        return AsiaScaffold(
          title: 'Nuestra Carta',
          subtitle: selectedCategory?.name ?? 'Especialidades al Wok',
          onToggleTheme: widget.onToggleTheme,
          isDark: widget.isDark,
          onCartTap: widget.onNavigateToCart,
          cartCount: cartCount,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              // Buscador moderno
              AsiaTextField(
                controller: _searchCtrl,
                hintText: 'Buscar plato (ej. Chaufa, Wantán...)',
                prefixIcon: LucideIcons.search,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                onChanged: (String val) => setState(() => _searchQuery = val.trim()),
              ),
              const SizedBox(height: 16),

              // Chips horizontales de categorías
              if (state.categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: state.categories.map((CatalogCategory cat) {
                      final bool isSelected = cat.id == state.selectedCategoryId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AsiaChip(
                          key: ValueKey<String>('catalog-category-${cat.id}'),
                          label: cat.name,
                          icon: getCategoryIcon(cat.name),
                          isSelected: isSelected,
                          onTap: () => widget.catalogController.selectCategory(cat.id),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 20),

              // Lista de productos
              if (state.status == CatalogStatus.loading)
                const AsiaStateView(
                  kind: AsiaStateKind.loading,
                  title: 'Cargando platos...',
                )
              else if (state.failure != null)
                AsiaStateView(
                  kind: AsiaStateKind.error,
                  title: 'No pudimos cargar los platos',
                  message: 'Por favor revisa tu conexión e intenta de nuevo.',
                  actionLabel: 'Reintentar',
                  onAction: () => widget.catalogController.retry(),
                )
              else if (filteredProducts.isEmpty)
                AsiaStateView(
                  kind: AsiaStateKind.empty,
                  title: _searchQuery.isNotEmpty
                      ? 'No encontramos "$_searchQuery"'
                      : 'Esta categoría aún no tiene platos disponibles',
                  message: 'Prueba con otra búsqueda o categoría.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final CatalogProduct prod = filteredProducts[index];
                    return _ProductCard(
                      key: ValueKey<String>('catalog-product-${prod.id}'),
                      product: prod,
                      categoryName: selectedCategory?.name ?? 'Plato especial',
                      onTap: () {
                        if (selectedCategory != null) {
                          widget.onProductSelected(selectedCategory, prod);
                        }
                      },
                      onAddToCart: () {
                        widget.cartController.addProduct(
                          CartProductSnapshot(
                            id: prod.id,
                            categoryId: prod.categoryId,
                            name: prod.name,
                            unitPriceCents: prod.priceCents,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${prod.name} agregado al carrito'),
                            backgroundColor: theme.brandCrimson,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }
}

// ==============================================================================
// 3. DETALLE DE PRODUCTO
// ==============================================================================

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    required this.controller,
    required this.cartController,
    required this.onBack,
    required this.onNavigateToCart,
    super.key,
  });

  final ProductDetailController controller;
  final CartController cartController;
  final VoidCallback onBack;
  final VoidCallback onNavigateToCart;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _handleAddToCart(CatalogProduct product) {
    widget.cartController.addProduct(
      CartProductSnapshot(
        id: product.id,
        categoryId: product.categoryId,
        name: product.name,
        unitPriceCents: product.priceCents,
      ),
      quantity: _quantity,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );
    widget.onNavigateToCart();
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final ProductDetailState state = widget.controller.state;
    final CatalogProduct? product = state.product;

    if (state.status == ProductDetailStatus.notFound || product == null) {
      return AsiaScaffold(
        title: 'Plato no encontrado',
        showBack: true,
        onBack: widget.onBack,
        body: AsiaStateView(
          kind: AsiaStateKind.error,
          title: 'El plato solicitado no existe',
          actionLabel: 'Regresar a la carta',
          onAction: widget.onBack,
        ),
      );
    }

    final int totalPriceCents = product.priceCents * _quantity;

    return AsiaScaffold(
      showBack: true,
      onBack: widget.onBack,
      title: product.name,
      subtitle: 'Detalle del plato',
      bottomAction: AsiaButton(
        key: const Key('product-add-to-cart'),
        label: 'Agregar al pedido · ${formatPrice(totalPriceCents)}',
        leading: LucideIcons.shoppingBag,
        onPressed: () => _handleAddToCart(product),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          // Gran contenedor visual del plato
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: AsiaRadii.brCard,
              border: Border.all(color: theme.border, width: 0.8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    getCategoryIcon(product.name),
                    size: 64,
                    color: theme.brandCrimson,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.brandGold.withValues(alpha: 0.15),
                      borderRadius: AsiaRadii.brPill,
                    ),
                    child: Text(
                      'Preparado al momento al Wok',
                      style: AsiaTypography.labelSmall.copyWith(
                        color: theme.brandGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título y Precio
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  product.name,
                  style: AsiaTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatPrice(product.priceCents),
                style: AsiaTypography.titleLarge.copyWith(
                  color: theme.brandCrimson,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Elaborado con los mejores insumos frescos, sazonado con sillao superior, aceite de ajonjolí y el inconfundible fuego del wok tradicional.',
            style: AsiaTypography.bodyMedium.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: 24),

          // Contador de cantidad
          AsiaCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Cantidad de porciones',
                  style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: <Widget>[
                    _CounterButton(
                      icon: LucideIcons.minus,
                      onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$_quantity',
                        style: AsiaTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    _CounterButton(
                      icon: LucideIcons.plus,
                      onTap: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Observaciones para la cocina
          AsiaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(LucideIcons.messageSquare, size: 17, color: theme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Instrucciones para cocina (Opcional)',
                      style: AsiaTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AsiaTextField(
                  controller: _notesCtrl,
                  hintText: 'Ej. Sin cebolla china, salsa agridulce aparte...',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

// ==============================================================================
// COMPONENTES PRIVADOS DE CATÁLOGO
// ==============================================================================

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.categoryName,
    required this.onTap,
    required this.onAddToCart,
    super.key,
  });

  final CatalogProduct product;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: AsiaRadii.brMd,
              border: Border.all(color: theme.border, width: 0.8),
            ),
            child: Icon(
              getCategoryIcon(product.name),
              size: 28,
              color: theme.brandCrimson,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  categoryName,
                  style: AsiaTypography.labelSmall.copyWith(
                    color: theme.brandGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AsiaTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(product.priceCents),
                  style: AsiaTypography.titleSmall.copyWith(
                    color: theme.brandCrimson,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AsiaPressable(
            onPressed: onAddToCart,
            borderRadius: AsiaRadii.brPill,
            semanticLabel: 'Agregar ${product.name}',
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.brandCrimson.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.plus,
                size: 19,
                color: theme.brandCrimson,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final bool canTap = onTap != null;

    return AsiaPressable(
      onPressed: onTap,
      borderRadius: AsiaRadii.brPill,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: canTap ? theme.surfaceSubtle : theme.surfaceSubtle.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: theme.border, width: 0.8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: canTap ? theme.textPrimary : theme.textTertiary,
        ),
      ),
    );
  }
}
