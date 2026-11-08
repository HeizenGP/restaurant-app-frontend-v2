import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/design_system/components/admin_badge.dart';
import '../../../core/design_system/components/admin_button.dart';
import '../../../core/design_system/components/admin_card.dart';
import '../../../core/design_system/components/admin_skeleton_loader.dart';
import '../../../core/design_system/components/stat_card.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../../../core/layout/breakpoints.dart';
import '../../dashboard/application/dashboard_controller.dart';
import '../../dashboard/domain/dashboard_models.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({
    required this.dashboardController,
    super.key,
  });

  final DashboardController dashboardController;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedRange = 'HOY';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.dashboardController.loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDesktop = Breakpoints.isDesktop(context);
    final bool isTablet = Breakpoints.isTablet(context);

    return ListenableBuilder(
      listenable: widget.dashboardController,
      builder: (BuildContext context, _) {
        final DashboardStats? stats = widget.dashboardController.stats;
        final bool isLoading = widget.dashboardController.isLoading;
        final String? errorMessage = widget.dashboardController.errorMessage;
        final NumberFormat currencyFmt = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

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
                      Text('Reportes & Analítica', style: AsiaTypography.displaySmall.copyWith(color: tokens.textPrimary)),
                      const SizedBox(height: AsiaSpacing.xs),
                      Text('Indicadores de rendimiento, canales de venta y demanda culinaria', style: AsiaTypography.bodyMedium.copyWith(color: tokens.textSecondary)),
                    ],
                  ),
                  Wrap(
                    spacing: AsiaSpacing.sm,
                    children: <Widget>[
                      AdminButton(
                        label: 'Actualizar',
                        icon: LucideIcons.refreshCw,
                        variant: AdminButtonVariant.secondary,
                        onPressed: () => widget.dashboardController.loadDashboard(),
                      ),
                      AdminButton(
                        label: 'Exportar Resumen',
                        icon: LucideIcons.download,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reporte consolidado listo para exportar'),
                              backgroundColor: AsiaPalette.jade,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Time range filter
              Row(
                children: <Widget>[
                  _buildRangeChip('Hoy (Tiempo Real)', 'HOY'),
                  const SizedBox(width: AsiaSpacing.sm),
                  _buildRangeChip('Esta Semana', 'SEMANA'),
                  const SizedBox(width: AsiaSpacing.sm),
                  _buildRangeChip('Este Mes', 'MES'),
                ],
              ),
              const SizedBox(height: AsiaSpacing.lg),

              if (errorMessage != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(AsiaSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.error.withValues(alpha: 0.1),
                    borderRadius: AsiaRadii.md,
                    border: Border.all(color: tokens.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.alertTriangle, color: tokens.error),
                      const SizedBox(width: AsiaSpacing.sm),
                      Expanded(
                        child: Text(errorMessage, style: AsiaTypography.bodyMedium.copyWith(color: tokens.error)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AsiaSpacing.lg),
              ],

              if (isLoading && stats == null)
                const AdminTableSkeleton(rows: 6, columns: 4)
              else if (stats != null) ...<Widget>[
                // KPI Grid
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int cols = isDesktop ? 4 : (isTablet ? 2 : 1);
                    final double cardWidth = (constraints.maxWidth - (cols - 1) * AsiaSpacing.md) / cols;

                    final double avgTicket = stats.todayOrdersCount > 0
                        ? (stats.todaySales / stats.todayOrdersCount)
                        : 0.0;
                    final double tableOccupancyRate = stats.totalTablesCount > 0
                        ? (stats.occupiedTablesCount / stats.totalTablesCount * 100)
                        : 0.0;

                    return Wrap(
                      spacing: AsiaSpacing.md,
                      runSpacing: AsiaSpacing.md,
                      children: <Widget>[
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: 'Ventas Totales',
                            value: currencyFmt.format(stats.todaySales),
                            subtitle: 'Ingresos por cobros efectivos',
                            icon: LucideIcons.dollarSign,
                            accentColor: AsiaPalette.jade,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: 'Ticket Promedio',
                            value: currencyFmt.format(avgTicket),
                            subtitle: 'Gasto promedio por comensal',
                            icon: LucideIcons.trendingUp,
                            accentColor: AsiaPalette.gold,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: 'Ocupación de Salón',
                            value: '${tableOccupancyRate.toStringAsFixed(1)}%',
                            subtitle: '${stats.occupiedTablesCount} de ${stats.totalTablesCount} mesas ocupadas',
                            icon: LucideIcons.armchair,
                            accentColor: AsiaPalette.blue,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: StatCard(
                            title: 'Pedidos Procesados',
                            value: '${stats.todayOrdersCount}',
                            subtitle: '${stats.activeOrdersCount} actualmente activos',
                            icon: LucideIcons.shoppingBag,
                            accentColor: tokens.brandCrimson,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AsiaSpacing.xl),

                // Breakdown section
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: _buildModalityCard(context, stats)),
                      const SizedBox(width: AsiaSpacing.lg),
                      Expanded(child: _buildStatusCard(context, stats)),
                    ],
                  )
                else ...<Widget>[
                  _buildModalityCard(context, stats),
                  const SizedBox(height: AsiaSpacing.lg),
                  _buildStatusCard(context, stats),
                ],
                const SizedBox(height: AsiaSpacing.xl),

                // Top Products Ranking
                _buildTopProductsCard(context, stats),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRangeChip(String label, String value) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isSelected = _selectedRange == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedRange = value),
      selectedColor: tokens.brandCrimson,
      backgroundColor: tokens.cardElevated,
      labelStyle: AsiaTypography.caption.copyWith(
        color: isSelected ? Colors.white : tokens.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? tokens.brandCrimson : tokens.border),
    );
  }

  Widget _buildModalityCard(BuildContext context, DashboardStats stats) {
    final AsiaThemeTokens tokens = context.tokens;
    final int total = stats.ordersByModality.values.fold(0, (int a, int b) => a + b);

    return AdminCard(
      title: 'Distribución por Modalidad',
      subtitle: 'Composición de canales de servicio',
      child: total == 0
          ? Padding(
              padding: const EdgeInsets.all(AsiaSpacing.xl),
              child: Center(
                child: Text('No hay pedidos registrados en el período.', style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary)),
              ),
            )
          : Column(
              children: stats.ordersByModality.entries.map((MapEntry<String, int> entry) {
                final double percent = total > 0 ? (entry.value / total) : 0.0;
                final String label = entry.key == 'DINE_IN'
                    ? 'Consumo en Salón'
                    : (entry.key == 'TAKEAWAY' ? 'Para Llevar' : 'Delivery');
                final Color color = entry.key == 'DINE_IN'
                    ? AsiaPalette.jade
                    : (entry.key == 'TAKEAWAY' ? AsiaPalette.gold : AsiaPalette.blue);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AsiaSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(label, style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: tokens.textPrimary)),
                          Text('${entry.value} (${(percent * 100).toStringAsFixed(1)}%)', style: AsiaTypography.caption.copyWith(color: tokens.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: AsiaSpacing.xs),
                      ClipRRect(
                        borderRadius: AsiaRadii.pill,
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: tokens.cardElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildStatusCard(BuildContext context, DashboardStats stats) {
    final AsiaThemeTokens tokens = context.tokens;
    final int total = stats.ordersByStatus.values.fold(0, (int a, int b) => a + b);

    return AdminCard(
      title: 'Flujo de Estados de Pedidos',
      subtitle: 'Monitoreo de ciclo de vida de comandas',
      child: total == 0
          ? Padding(
              padding: const EdgeInsets.all(AsiaSpacing.xl),
              child: Center(
                child: Text('No hay pedidos registrados en el período.', style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary)),
              ),
            )
          : Column(
              children: stats.ordersByStatus.entries.map((MapEntry<String, int> entry) {
                final double percent = total > 0 ? (entry.value / total) : 0.0;
                final Color color = _getStatusColor(entry.key);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AsiaSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: AsiaSpacing.sm),
                              Text(entry.key, style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: tokens.textPrimary)),
                            ],
                          ),
                          Text('${entry.value} (${(percent * 100).toStringAsFixed(1)}%)', style: AsiaTypography.caption.copyWith(color: tokens.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: AsiaSpacing.xs),
                      ClipRRect(
                        borderRadius: AsiaRadii.pill,
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: tokens.cardElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTopProductsCard(BuildContext context, DashboardStats stats) {
    final AsiaThemeTokens tokens = context.tokens;

    return AdminCard(
      title: 'Platos & Bebidas Más Vendidos',
      subtitle: 'Ranking de los productos con mayor demanda acumulada',
      child: stats.topProducts.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AsiaSpacing.xl),
              child: Center(
                child: Text('No hay ventas registradas aún para elaborar el ranking.', style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary)),
              ),
            )
          : Column(
              children: stats.topProducts.asMap().entries.map((MapEntry<int, TopProduct> entry) {
                final int rank = entry.key + 1;
                final TopProduct prod = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AsiaSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: rank <= 3 ? tokens.brandGold.withValues(alpha: 0.15) : tokens.cardElevated,
                          borderRadius: AsiaRadii.md,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#$rank',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: rank <= 3 ? tokens.brandGold : tokens.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AsiaSpacing.md),
                      Expanded(
                        child: Text(
                          prod.name,
                          style: AsiaTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: tokens.textPrimary),
                        ),
                      ),
                      AdminBadge(
                        label: '${prod.totalQuantity} unidades',
                        variant: rank <= 3 ? AdminBadgeVariant.brand : AdminBadgeVariant.neutral,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DELIVERED':
        return AsiaPalette.jade;
      case 'CONFIRMED':
      case 'APPROVED':
        return AsiaPalette.blue;
      case 'PREPARING':
        return AsiaPalette.gold;
      case 'CANCELLED':
        return AsiaPalette.crimson;
      default:
        return const Color(0xFF94A3B8);
    }
  }
}
