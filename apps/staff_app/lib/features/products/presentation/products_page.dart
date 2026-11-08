import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.catalogController.loadCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return ListenableBuilder(
      listenable: widget.catalogController,
      builder: (BuildContext context, _) {
        final List<Category> categories = widget.catalogController.categories;
        final List<Product> products = widget.catalogController.filteredProducts;
        final bool isLoading = widget.catalogController.isLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
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
                  ),
                  Row(
                    children: <Widget>[
                      AdminButton(
                        label: 'Nueva Categoría',
                        icon: LucideIcons.folderPlus,
                        variant: AdminButtonVariant.secondary,
                        size: AdminButtonSize.sm,
                        onPressed: () => _openCreateCategoryDialog(context),
                      ),
                      const SizedBox(width: AsiaSpacing.md),
                      AdminButton(
                        label: 'Nuevo Producto',
                        icon: LucideIcons.plus,
                        size: AdminButtonSize.sm,
                        onPressed: categories.isEmpty
                            ? null
                            : () => _openSaveProductDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Filter & Search Toolbar
              AdminCard(
                padding: const EdgeInsets.all(AsiaSpacing.md),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AdminTextField(
                            hintText: 'Buscar por plato, ingrediente o código...',
                            prefixIcon: LucideIcons.search,
                            onChanged: (String val) =>
                                widget.catalogController.setSearchQuery(val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    // Categories Scrollable Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _buildCategoryChip(
                            context,
                            label: 'Todas las categorías',
                            isSelected:
                                widget.catalogController.selectedCategoryId == null,
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Products Data Table
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
                AdminCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(tokens.cardElevated),
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Producto')),
                        DataColumn(label: Text('Categoría')),
                        DataColumn(label: Text('Precio')),
                        DataColumn(label: Text('Stock Actual')),
                        DataColumn(label: Text('Disponibilidad')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: products.map((Product p) {
                        final Category? cat = categories.cast<Category?>().firstWhere(
                              (Category? c) => c?.id == p.categoryId,
                              orElse: () => null,
                            );
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: tokens.cardElevated,
                                      borderRadius: AsiaRadii.sm,
                                      border: Border.all(color: tokens.border),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: p.imageUrl != null &&
                                            p.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            p.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                Icon(LucideIcons.utensils,
                                                    size: 16,
                                                    color: tokens.textTertiary),
                                          )
                                        : Icon(LucideIcons.utensils,
                                            size: 16,
                                            color: tokens.textTertiary),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        p.name,
                                        style: AsiaTypography.headingMedium
                                            .copyWith(
                                          color: tokens.textPrimary,
                                          fontSize: 14,
                                        ),
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
                                ],
                              ),
                            ),
                            DataCell(
                              AdminBadge(
                                label: cat?.name ?? 'Sin categoría',
                                variant: AdminBadgeVariant.neutral,
                              ),
                            ),
                            DataCell(
                              Text(
                                'S/ ${p.price.toStringAsFixed(2)}',
                                style: AsiaTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: tokens.brandCrimson,
                                ),
                              ),
                            ),
                            DataCell(
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
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(LucideIcons.edit2, size: 14),
                                    tooltip: 'Ajustar Stock',
                                    onPressed: () => _openQuickStockDialog(context, p),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Switch(
                                value: p.isAvailable,
                                activeThumbColor: tokens.brandJade,
                                onChanged: (bool val) {
                                  widget.catalogController
                                      .toggleAvailability(p.id, val);
                                },
                              ),
                            ),
                            DataCell(
                              Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: const Icon(LucideIcons.settings, size: 16),
                                    tooltip: 'Editar Producto',
                                    onPressed: () => _openSaveProductDialog(
                                      context,
                                      product: p,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final AsiaThemeTokens tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
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
      ),
    );
  }

  void _openCreateCategoryDialog(BuildContext context) {
    final TextEditingController nameCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AdminDialog(
        title: 'Nueva Categoría',
        subtitle: 'Crea una sección para agrupar platos en la carta de KAIRO.',
        content: AdminTextField(
          controller: nameCtrl,
          label: 'Nombre de la categoría',
          hintText: 'Ej. Sopas y Dim Sum',
          autofocus: true,
        ),
        confirmLabel: 'Crear Categoría',
        onConfirm: () async {
          if (nameCtrl.text.trim().isNotEmpty) {
            final bool ok = await widget.catalogController
                .createCategory(nameCtrl.text.trim());
            if (ok && ctx.mounted) {
              Navigator.of(ctx).pop();
            }
          }
        },
      ),
    );
  }

  void _openQuickStockDialog(BuildContext context, Product product) {
    final TextEditingController qtyCtrl =
        TextEditingController(text: product.stockQty.toString());
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
            final bool ok = await widget.catalogController
                .updateStock(product.id, newQty);
            if (ok && ctx.mounted) {
              Navigator.of(ctx).pop();
            }
          }
        },
      ),
    );
  }

  void _openSaveProductDialog(BuildContext context, {Product? product}) {
    final bool isEdit = product != null;
    final List<Category> categories = widget.catalogController.categories;

    String selectedCategoryId = product?.categoryId ?? categories.first.id;
    final TextEditingController nameCtrl =
        TextEditingController(text: product?.name ?? '');
    final TextEditingController priceCtrl =
        TextEditingController(text: product?.price.toString() ?? '');
    final TextEditingController stockCtrl =
        TextEditingController(text: product?.stockQty.toString() ?? '20');
    final TextEditingController descCtrl =
        TextEditingController(text: product?.description ?? '');
    final TextEditingController imgCtrl =
        TextEditingController(text: product?.imageUrl ?? '');

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return AdminDialog(
            title: isEdit ? 'Editar Plato' : 'Nuevo Plato en Carta',
            subtitle: isEdit
                ? 'Modifica los datos del producto seleccionado'
                : 'Ingresa los detalles para publicarlo en la app y pedidos',
            maxWidth: 580,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: categories.map((Category cat) {
                    return DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    if (val != null) {
                      setStateDialog(() => selectedCategoryId = val);
                    }
                  },
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: nameCtrl,
                  label: 'Nombre del Plato',
                  hintText: 'Ej. Chaufa Especial de Mariscos',
                ),
                const SizedBox(height: AsiaSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AdminTextField(
                        controller: priceCtrl,
                        label: 'Precio (S/.)',
                        hintText: '38.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: AsiaSpacing.md),
                    Expanded(
                      child: AdminTextField(
                        controller: stockCtrl,
                        label: 'Stock Inicial',
                        hintText: '25',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: imgCtrl,
                  label: 'URL de Imagen (Opcional)',
                  hintText: 'https://...',
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: descCtrl,
                  label: 'Descripción / Ingredientes',
                  hintText: 'Arroz al wok con mariscos selectos, cebolla china y salsa de ostión.',
                  maxLines: 3,
                ),
              ],
            ),
            confirmLabel: isEdit ? 'Guardar Cambios' : 'Crear Plato',
            onConfirm: () async {
              final double? price = double.tryParse(priceCtrl.text.trim());
              final int? stock = int.tryParse(stockCtrl.text.trim());
              if (nameCtrl.text.trim().isEmpty || price == null) return;

              final bool ok = await widget.catalogController.saveProduct(
                productId: product?.id,
                categoryId: selectedCategoryId,
                name: nameCtrl.text.trim(),
                price: price,
                initialStock: stock,
                imageUrl: imgCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );
              if (ok && ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
          );
        },
      ),
    );
  }
}
