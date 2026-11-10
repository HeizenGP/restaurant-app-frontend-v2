import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/components/admin_badge.dart';
import '../../../core/design_system/components/admin_button.dart';
import '../../../core/design_system/components/admin_card.dart';
import '../../../core/design_system/components/admin_dialog.dart';
import '../../../core/design_system/components/admin_text_field.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../application/catalog_controller.dart';
import '../domain/catalog_models.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({required this.catalogController, super.key});

  final CatalogController catalogController;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.catalogController.loadCatalog();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        widget.catalogController.loadCatalog(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return ListenableBuilder(
      listenable: widget.catalogController,
      builder: (BuildContext context, _) {
        final List<Category> categories = widget.catalogController.categories;
        final List<Product> products =
            widget.catalogController.filteredProducts;
        final bool isLoading = widget.catalogController.isLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header & Actions
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isNarrow = constraints.maxWidth < 640;
                  final Widget titleWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Carta & Productos',
                        style: AsiaTypography.displayMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${products.length} productos registrados en ${categories.length} categorías',
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                    ],
                  );

                  final Widget buttonsWidget = Wrap(
                    spacing: AsiaSpacing.md,
                    runSpacing: AsiaSpacing.sm,
                    children: <Widget>[
                      AdminButton(
                        label: 'Nueva Categoría',
                        icon: LucideIcons.folderPlus,
                        variant: AdminButtonVariant.secondary,
                        size: AdminButtonSize.sm,
                        onPressed: () => context.go('/products/categories/new'),
                      ),
                      AdminButton(
                        label: 'Nuevo Producto',
                        icon: LucideIcons.plus,
                        size: AdminButtonSize.sm,
                        onPressed: () => context.go('/products/new'),
                      ),
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        titleWidget,
                        const SizedBox(height: AsiaSpacing.md),
                        buttonsWidget,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      titleWidget,
                      buttonsWidget,
                    ],
                  );
                },
              ),
              const SizedBox(height: AsiaSpacing.xl),

              if (widget.catalogController.errorMessage != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(AsiaSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.error.withValues(alpha: 0.1),
                    borderRadius: AsiaRadii.md,
                    border: Border.all(
                      color: tokens.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.alertTriangle, color: tokens.error),
                      const SizedBox(width: AsiaSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.catalogController.errorMessage!,
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.error,
                          ),
                        ),
                      ),
                      AdminButton(
                        label: 'Reintentar',
                        size: AdminButtonSize.sm,
                        variant: AdminButtonVariant.secondary,
                        onPressed: () => widget.catalogController.loadCatalog(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AsiaSpacing.lg),
              ],

              // Filter & Search Toolbar
              AdminCard(
                padding: const EdgeInsets.all(AsiaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AdminTextField(
                      hintText: 'Buscar por plato, ingrediente o código...',
                      prefixIcon: LucideIcons.search,
                      onChanged: (String val) =>
                          widget.catalogController.setSearchQuery(val),
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    // Categories wrap bar (sin scroll horizontal)
                    Wrap(
                      spacing: AsiaSpacing.sm,
                      runSpacing: AsiaSpacing.sm,
                      children: <Widget>[
                        _buildCategoryChip(
                          context,
                          label: 'Todas las categorías',
                          isSelected:
                              widget.catalogController.selectedCategoryId ==
                              null,
                          onTap: () =>
                              widget.catalogController.selectCategory(null),
                        ),
                        ...categories.map((Category cat) {
                          final bool isSelected =
                              widget.catalogController.selectedCategoryId ==
                              cat.id;
                          return _buildCategoryChip(
                            context,
                            label: cat.name,
                            isSelected: isSelected,
                            onTap: () => widget.catalogController
                                .selectCategory(cat.id),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Products Responsive Table / Cards
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AsiaSpacing.xxxl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (products.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AsiaSpacing.xxxl),
                    child: Text(
                      'No se encontraron productos con los filtros seleccionados.',
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: tokens.textTertiary,
                      ),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth < 680) {
                      return _buildMobileProductList(
                        context,
                        products,
                        categories,
                        tokens,
                      );
                    }
                    return _buildDesktopProductTable(
                      context,
                      products,
                      categories,
                      tokens,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopProductTable(
    BuildContext context,
    List<Product> products,
    List<Category> categories,
    AsiaThemeTokens tokens,
  ) {
    final TextStyle headerStyle = AsiaTypography.caption.copyWith(
      color: tokens.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );

    return AdminCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AsiaSpacing.lg,
              vertical: AsiaSpacing.md,
            ),
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: const BorderRadius.vertical(
                top: AsiaRadii.mdRadius,
              ),
              border: Border(
                bottom: BorderSide(color: tokens.border),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(flex: 5, child: Text('PRODUCTO', style: headerStyle)),
                Expanded(flex: 3, child: Text('CATEGORÍA', style: headerStyle)),
                Expanded(flex: 2, child: Text('PRECIO', style: headerStyle)),
                Expanded(flex: 3, child: Text('STOCK ACTUAL', style: headerStyle)),
                Expanded(flex: 2, child: Text('DISPONIBLE', style: headerStyle)),
                SizedBox(
                  width: 50,
                  child: Text('EDITAR', style: headerStyle, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          // Product Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: tokens.border.withValues(alpha: 0.5),
            ),
            itemBuilder: (BuildContext context, int index) {
              final Product p = products[index];
              final Category? cat = categories.cast<Category?>().firstWhere(
                    (Category? c) => c?.id == p.categoryId,
                    orElse: () => null,
                  );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AsiaSpacing.lg,
                  vertical: AsiaSpacing.sm + 2,
                ),
                child: Row(
                  children: <Widget>[
                    // 1. Producto
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: tokens.cardElevated,
                              borderRadius: AsiaRadii.sm,
                              border: Border.all(color: tokens.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                                ? Image.network(
                                    p.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      LucideIcons.utensils,
                                      size: 18,
                                      color: tokens.textTertiary,
                                    ),
                                  )
                                : Icon(
                                    LucideIcons.utensils,
                                    size: 18,
                                    color: tokens.textTertiary,
                                  ),
                          ),
                          const SizedBox(width: AsiaSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  p.name,
                                  style: AsiaTypography.headingMedium.copyWith(
                                    color: tokens.textPrimary,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (p.description != null &&
                                    p.description!.isNotEmpty)
                                  Text(
                                    p.description!,
                                    style: AsiaTypography.caption.copyWith(
                                      color: tokens.textTertiary,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Categoría
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AdminBadge(
                          label: cat?.name ?? 'Sin categoría',
                          variant: AdminBadgeVariant.neutral,
                        ),
                      ),
                    ),

                    // 3. Precio
                    Expanded(
                      flex: 2,
                      child: Text(
                        'S/ ${p.price.toStringAsFixed(2)}',
                        style: AsiaTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.brandCrimson,
                        ),
                      ),
                    ),

                    // 4. Stock
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AdminBadge(
                            label: '${p.stockQty} und',
                            variant: p.isOutOfStock
                                ? AdminBadgeVariant.error
                                : (p.isLowStock
                                    ? AdminBadgeVariant.warning
                                    : AdminBadgeVariant.success),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(LucideIcons.edit2, size: 14),
                            tooltip: 'Ajustar Stock',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _openQuickStockDialog(context, p),
                          ),
                        ],
                      ),
                    ),

                    // 5. Disponibilidad
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Switch(
                          value: p.isAvailable,
                          activeThumbColor: tokens.brandJade,
                          onChanged: (bool val) {
                            widget.catalogController.toggleAvailability(
                              p.id,
                              val,
                            );
                          },
                        ),
                      ),
                    ),

                    // 6. Acciones
                    SizedBox(
                      width: 50,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(LucideIcons.pencil, size: 16),
                          tooltip: 'Editar Producto',
                          onPressed: () => context.go(
                            '/products/edit/${p.id}',
                            extra: p,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProductList(
    BuildContext context,
    List<Product> products,
    List<Category> categories,
    AsiaThemeTokens tokens,
  ) {
    return Column(
      children: products.map((Product p) {
        final Category? cat = categories.cast<Category?>().firstWhere(
              (Category? c) => c?.id == p.categoryId,
              orElse: () => null,
            );

        return Padding(
          padding: const EdgeInsets.only(bottom: AsiaSpacing.md),
          child: AdminCard(
            padding: const EdgeInsets.all(AsiaSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: tokens.cardElevated,
                        borderRadius: AsiaRadii.sm,
                        border: Border.all(color: tokens.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                          ? Image.network(
                              p.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                LucideIcons.utensils,
                                size: 20,
                                color: tokens.textTertiary,
                              ),
                            )
                          : Icon(
                              LucideIcons.utensils,
                              size: 20,
                              color: tokens.textTertiary,
                            ),
                    ),
                    const SizedBox(width: AsiaSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            p.name,
                            style: AsiaTypography.headingMedium.copyWith(
                              color: tokens.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          if (p.description != null &&
                              p.description!.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              p.description!,
                              style: AsiaTypography.caption.copyWith(
                                color: tokens.textTertiary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: AsiaSpacing.sm,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Text(
                                'S/ ${p.price.toStringAsFixed(2)}',
                                style: AsiaTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: tokens.brandCrimson,
                                ),
                              ),
                              AdminBadge(
                                label: cat?.name ?? 'Sin categoría',
                                variant: AdminBadgeVariant.neutral,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AsiaSpacing.md),
                Divider(
                  height: 1,
                  color: tokens.border.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AsiaSpacing.sm),
                Wrap(
                  spacing: AsiaSpacing.md,
                  runSpacing: AsiaSpacing.xs,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AdminBadge(
                          label: '${p.stockQty} und',
                          variant: p.isOutOfStock
                              ? AdminBadgeVariant.error
                              : (p.isLowStock
                                  ? AdminBadgeVariant.warning
                                  : AdminBadgeVariant.success),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(LucideIcons.edit2, size: 14),
                          tooltip: 'Ajustar Stock',
                          onPressed: () => _openQuickStockDialog(context, p),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          p.isAvailable ? 'Disponible' : 'Agotado',
                          style: AsiaTypography.caption.copyWith(
                            color: p.isAvailable
                                ? tokens.brandJade
                                : tokens.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: p.isAvailable,
                          activeThumbColor: tokens.brandJade,
                          onChanged: (bool val) {
                            widget.catalogController.toggleAvailability(
                              p.id,
                              val,
                            );
                          },
                        ),
                        const SizedBox(width: AsiaSpacing.xs),
                        IconButton(
                          icon: const Icon(LucideIcons.pencil, size: 16),
                          tooltip: 'Editar',
                          onPressed: () => context.go(
                            '/products/edit/${p.id}',
                            extra: p,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final AsiaThemeTokens tokens = context.tokens;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: tokens.brandCrimson.withValues(alpha: 0.15),
      checkmarkColor: tokens.brandCrimson,
      labelStyle: AsiaTypography.caption.copyWith(
        color: isSelected ? tokens.brandCrimson : tokens.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: tokens.cardElevated,
      side: BorderSide(
        color: isSelected
            ? tokens.brandCrimson.withValues(alpha: 0.4)
            : tokens.border,
      ),
    );
  }

  void _openQuickStockDialog(BuildContext context, Product product) {
    final TextEditingController qtyCtrl = TextEditingController(
      text: product.stockQty.toString(),
    );
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AdminDialog(
        title: 'Ajustar Inventario',
        subtitle: 'Modifica el stock actual para "${product.name}".',
        content: AdminTextField(
          controller: qtyCtrl,
          label: 'Cantidad disponible (unidades)',
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        confirmLabel: 'Guardar Stock',
        onConfirm: () async {
          final int? newQty = int.tryParse(qtyCtrl.text.trim());
          if (newQty != null && newQty >= 0) {
            final bool ok = await widget.catalogController.updateStock(
              product.id,
              newQty,
            );
            if (ok && ctx.mounted) {
              Navigator.of(ctx).pop();
            }
          }
        },
      ),
    );
  }
}
