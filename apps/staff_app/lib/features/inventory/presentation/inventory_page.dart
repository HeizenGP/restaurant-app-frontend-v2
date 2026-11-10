import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import '../../products/domain/catalog_models.dart';
import '../application/inventory_controller.dart';
import '../domain/inventory_models.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({required this.inventoryController, super.key});

  final InventoryController inventoryController;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.inventoryController.loadInventory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return ListenableBuilder(
      listenable: widget.inventoryController,
      builder: (BuildContext context, _) {
        final List<Product> products =
            widget.inventoryController.filteredProducts;
        final List<StockMovement> movements =
            widget.inventoryController.movements;
        final bool isLoading = widget.inventoryController.isLoading;
        final int lowStockTotal = widget.inventoryController.products
            .where((Product p) => p.isLowStock || p.isOutOfStock)
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Inventario & Control de Stock',
                        style: AsiaTypography.displayMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Auditoría y control de existencias en almacén',
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  AdminButton(
                    label: 'Actualizar',
                    icon: LucideIcons.refreshCw,
                    variant: AdminButtonVariant.secondary,
                    size: AdminButtonSize.sm,
                    isLoading: isLoading,
                    onPressed: () => widget.inventoryController.loadInventory(),
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.lg),

              // Low Stock Warning Banner
              if (lowStockTotal > 0) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(AsiaSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.warning.withValues(alpha: 0.1),
                    borderRadius: AsiaRadii.md,
                    border: Border.all(
                      color: tokens.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.alertTriangle, color: tokens.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hay $lowStockTotal productos con stock crítico o agotado que requieren reposición inmediata.',
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AsiaSpacing.lg),
              ],

              // Tab Bar
              AdminCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: tokens.brandCrimson,
                  unselectedLabelColor: tokens.textSecondary,
                  indicatorColor: tokens.brandCrimson,
                  tabs: const <Widget>[
                    Tab(text: 'Existencias Actuales'),
                    Tab(text: 'Historial de Movimientos'),
                  ],
                ),
              ),
              const SizedBox(height: AsiaSpacing.lg),

              // Tab Views
              SizedBox(
                height: 540,
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _buildStockTableTab(context, products, isLoading),
                    _buildMovementsTab(context, movements, isLoading),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockTableTab(
    BuildContext context,
    List<Product> products,
    bool isLoading,
  ) {
    final AsiaThemeTokens tokens = context.tokens;

    if (isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return AdminCard(
      title: 'Inventario de Platos y Bebidas',
      subtitle: 'Niveles actuales de disponibilidad en tiempo real',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Solo críticos',
            style: AsiaTypography.caption.copyWith(color: tokens.textSecondary),
          ),
          Switch(
            value: widget.inventoryController.onlyLowStock,
            activeThumbColor: tokens.warning,
            onChanged: (bool val) =>
                widget.inventoryController.toggleOnlyLowStock(val),
          ),
        ],
      ),
      padding: EdgeInsets.zero,
      child: products.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AsiaSpacing.xxxl),
                child: Text(
                  'No hay productos registrados.',
                  style: AsiaTypography.bodyMedium.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(tokens.cardElevated),
                columns: const <DataColumn>[
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Precio')),
                  DataColumn(label: Text('Stock Actual')),
                  DataColumn(label: Text('Estado de Nivel')),
                  DataColumn(label: Text('Ajuste Rápido')),
                ],
                rows: products.map((Product p) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          p.name,
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(Text('S/ ${p.price.toStringAsFixed(2)}')),
                      DataCell(
                        Text(
                          '${p.stockQty} unidades',
                          style: AsiaTypography.headingMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.isOutOfStock
                                ? tokens.error
                                : (p.isLowStock
                                      ? tokens.warning
                                      : tokens.success),
                          ),
                        ),
                      ),
                      DataCell(
                        AdminBadge(
                          label: p.isOutOfStock
                              ? 'AGOTADO'
                              : (p.isLowStock ? 'STOCK BAJO' : 'ÓPTIMO'),
                          variant: p.isOutOfStock
                              ? AdminBadgeVariant.error
                              : (p.isLowStock
                                    ? AdminBadgeVariant.warning
                                    : AdminBadgeVariant.success),
                        ),
                      ),
                      DataCell(
                        AdminButton(
                          label: 'Modificar',
                          icon: LucideIcons.slidersHorizontal,
                          variant: AdminButtonVariant.secondary,
                          size: AdminButtonSize.sm,
                          onPressed: () => _openAdjustModal(context, p),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildMovementsTab(
    BuildContext context,
    List<StockMovement> movements,
    bool isLoading,
  ) {
    final AsiaThemeTokens tokens = context.tokens;

    if (isLoading && movements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (movements.isEmpty) {
      return Center(
        child: Text(
          'No hay movimientos de inventario registrados.',
          style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary),
        ),
      );
    }

    return AdminCard(
      title: 'Auditoría de Kardex y Movimientos',
      subtitle: 'Trazabilidad de entradas, salidas y correcciones manuales',
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(tokens.cardElevated),
          columns: const <DataColumn>[
            DataColumn(label: Text('Fecha y Hora')),
            DataColumn(label: Text('Producto')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Variación')),
            DataColumn(label: Text('Usuario')),
          ],
          rows: movements.map((StockMovement m) {
            final bool isPositive = m.quantityDelta > 0;
            return DataRow(
              cells: <DataCell>[
                DataCell(
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(m.recordedAt),
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textTertiary,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    m.productName,
                    style: AsiaTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  AdminBadge(label: m.kind, variant: AdminBadgeVariant.neutral),
                ),
                DataCell(
                  Text(
                    '${isPositive ? '+' : ''}${m.quantityDelta}',
                    style: AsiaTypography.bodyMedium.copyWith(
                      color: isPositive ? tokens.success : tokens.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    m.actorUserId != null
                        ? m.actorUserId!.substring(0, 8)
                        : 'Sistema',
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openAdjustModal(BuildContext context, Product product) {
    final TextEditingController qtyCtrl = TextEditingController(
      text: product.stockQty.toString(),
    );

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AdminDialog(
        title: 'Ajuste de Existencias',
        subtitle:
            'Actualiza la cantidad de unidades en almacén para "${product.name}".',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Stock actual registrado: ${product.stockQty} unidades.',
              style: AsiaTypography.bodySmall.copyWith(
                color: ctx.tokens.textSecondary,
              ),
            ),
            const SizedBox(height: AsiaSpacing.md),
            AdminTextField(
              controller: qtyCtrl,
              label: 'Nueva cantidad total',
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        confirmLabel: 'Confirmar Ajuste',
        onConfirm: () async {
          final int? newQty = int.tryParse(qtyCtrl.text.trim());
          if (newQty != null && newQty >= 0) {
            final bool ok = await widget.inventoryController.adjustStock(
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
