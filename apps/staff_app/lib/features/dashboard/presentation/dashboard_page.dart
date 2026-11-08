import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../../auth/application/auth_controller.dart';
import '../application/dashboard_controller.dart';
import '../domain/dashboard_models.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.dashboardController,
    required this.authController,
    super.key,
  });

  final DashboardController dashboardController;
  final AuthController authController;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.dashboardController.loadDashboard();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        widget.dashboardController.loadDashboard(silent: true);
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
    final bool isDesktop = Breakpoints.isDesktop(context);
    final bool isTablet = Breakpoints.isTablet(context);

    return ListenableBuilder(
      listenable: widget.dashboardController,
      builder: (BuildContext context, _) {
        final bool isLoading = widget.dashboardController.isLoading;
        final DashboardStats? stats = widget.dashboardController.stats;
        final String? errorMessage = widget.dashboardController.errorMessage;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(context),
              const SizedBox(height: AsiaSpacing.xl),
              if (errorMessage != null) ...<Widget>[
                _buildErrorBanner(context, errorMessage),
                const SizedBox(height: AsiaSpacing.lg),
              ],
              if (isLoading && stats == null)
                _buildLoadingSkeletons(context)
              else if (stats != null) ...<Widget>[
                _buildKpiGrid(context, stats, isDesktop, isTablet),
                const SizedBox(height: AsiaSpacing.xl),
                _buildAnalyticsRow(context, stats, isDesktop),
                const SizedBox(height: AsiaSpacing.xl),
                _buildRecentOrdersSection(context, stats),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final String greetingName =
        widget.authController.currentUser?.displayName ?? 'Administrador';
    final String todayFormatted =
        DateFormat('EEEE d MMMM, yyyy', 'es').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '¡Bienvenido, $greetingName!',
              style: AsiaTypography.displayMedium.copyWith(
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              todayFormatted.toUpperCase(),
              style: AsiaTypography.caption.copyWith(
                color: tokens.textTertiary,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AdminButton(
          label: 'Actualizar',
          icon: LucideIcons.refreshCw,
          variant: AdminButtonVariant.secondary,
          size: AdminButtonSize.sm,
          isLoading: widget.dashboardController.isLoading,
          onPressed: () => widget.dashboardController.refresh(),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    final AsiaThemeTokens tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(AsiaSpacing.md),
      decoration: BoxDecoration(
        color: tokens.error.withValues(alpha: 0.1),
        borderRadius: AsiaRadii.md,
        border: Border.all(color: tokens.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: tokens.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AsiaTypography.bodyMedium.copyWith(color: tokens.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(
    BuildContext context,
    DashboardStats stats,
    bool isDesktop,
    bool isTablet,
  ) {
    final AsiaThemeTokens tokens = context.tokens;
    final int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);

    final List<Widget> kpiCards = <Widget>[
      StatCard(
        title: 'Ventas de Hoy',
        value: 'S/ ${stats.todaySales.toStringAsFixed(2)}',
        subtitle: '${stats.todayOrdersCount} pedidos procesados',
        trend: '+12% vs ayer',
        isPositiveTrend: true,
        icon: LucideIcons.dollarSign,
        accentColor: tokens.brandCrimson,
      ),
      StatCard(
        title: 'Pedidos Activos',
        value: '${stats.activeOrdersCount}',
        subtitle: 'En preparación o espera',
        icon: LucideIcons.shoppingBag,
        accentColor: tokens.brandGold,
        onTap: () => context.go('/orders'),
      ),
      StatCard(
        title: 'Mesas Ocupadas',
        value: '${stats.occupiedTablesCount} / ${stats.totalTablesCount}',
        subtitle: '${stats.totalTablesCount - stats.occupiedTablesCount} disponibles',
        icon: LucideIcons.armchair,
        accentColor: tokens.brandJade,
        onTap: () => context.go('/tables'),
      ),
      StatCard(
        title: 'Alertas de Stock',
        value: '${stats.lowStockCount}',
        subtitle: stats.lowStockCount > 0 ? 'Insumos por agotarse' : 'Niveles óptimos',
        icon: LucideIcons.alertTriangle,
        accentColor: stats.lowStockCount > 0 ? tokens.error : tokens.info,
        onTap: () => context.go('/inventory'),
      ),
    ];

    if (crossAxisCount == 1) {
      return Column(
        children: kpiCards
            .map((Widget c) => Padding(
                  padding: const EdgeInsets.only(bottom: AsiaSpacing.md),
                  child: c,
                ))
            .toList(),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double itemWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * AsiaSpacing.lg) /
                crossAxisCount;
        return Wrap(
          spacing: AsiaSpacing.lg,
          runSpacing: AsiaSpacing.lg,
          children: kpiCards
              .map((Widget card) => SizedBox(width: itemWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildAnalyticsRow(
    BuildContext context,
    DashboardStats stats,
    bool isDesktop,
  ) {
    final AsiaThemeTokens tokens = context.tokens;

    final Widget modalityBreakdown = AdminCard(
      title: 'Canales y Modalidad',
      subtitle: 'Distribución de pedidos según tipo de entrega',
      child: Column(
        children: <Widget>[
          _buildModalityBar(
            context,
            label: 'Salón / Mesas',
            count: stats.ordersByModality['LOCAL'] ?? 0,
            total: stats.todayOrdersCount,
            color: tokens.brandCrimson,
            icon: LucideIcons.utensils,
          ),
          const SizedBox(height: AsiaSpacing.md),
          _buildModalityBar(
            context,
            label: 'Delivery Oficial KAIRO',
            count: stats.ordersByModality['DELIVERY'] ?? 0,
            total: stats.todayOrdersCount,
            color: tokens.brandGold,
            icon: LucideIcons.bike,
          ),
          const SizedBox(height: AsiaSpacing.md),
          _buildModalityBar(
            context,
            label: 'Para Llevar (Pickup)',
            count: stats.ordersByModality['PICKUP'] ?? 0,
            total: stats.todayOrdersCount,
            color: tokens.brandJade,
            icon: LucideIcons.packageCheck,
          ),
        ],
      ),
    );

    final Widget topSellingProducts = AdminCard(
      title: 'Platos Más Solicitados',
      subtitle: 'Ranking de volumen por unidades en carta',
      child: stats.topProducts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AsiaSpacing.lg),
                child: Text(
                  'Aún no hay platos registrados en el día.',
                  style: AsiaTypography.bodySmall.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ),
            )
          : Column(
              children: stats.topProducts.asMap().entries.map((MapEntry<int, TopProduct> entry) {
                final int rank = entry.key + 1;
                final TopProduct p = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: rank == 1
                              ? tokens.brandGold.withValues(alpha: 0.2)
                              : tokens.cardElevated,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$rank',
                          style: AsiaTypography.caption.copyWith(
                            color: rank == 1 ? tokens.brandGold : tokens.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.name,
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AdminBadge(
                        label: '${p.totalQuantity} und',
                        variant: AdminBadgeVariant.neutral,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: modalityBreakdown),
          const SizedBox(width: AsiaSpacing.lg),
          Expanded(child: topSellingProducts),
        ],
      );
    }

    return Column(
      children: <Widget>[
        modalityBreakdown,
        const SizedBox(height: AsiaSpacing.lg),
        topSellingProducts,
      ],
    );
  }

  Widget _buildModalityBar(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    final AsiaThemeTokens tokens = context.tokens;
    final double percent = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: AsiaTypography.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$count pedidos (${(percent * 100).toStringAsFixed(0)}%)',
              style: AsiaTypography.caption.copyWith(
                color: tokens.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AsiaRadii.pill,
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: tokens.cardElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection(BuildContext context, DashboardStats stats) {
    final AsiaThemeTokens tokens = context.tokens;

    return AdminCard(
      title: 'Actividad Reciente de Pedidos',
      subtitle: 'Últimas operaciones ingresadas al sistema',
      action: AdminButton(
        label: 'Ver Todos',
        variant: AdminButtonVariant.ghost,
        size: AdminButtonSize.sm,
        icon: LucideIcons.arrowRight,
        onPressed: () => context.go('/orders'),
      ),
      padding: EdgeInsets.zero,
      child: stats.recentOrders.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AsiaSpacing.xl),
              child: Center(
                child: Text(
                  'No hay pedidos registrados en la jornada.',
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
                  DataColumn(label: Text('ID Pedido')),
                  DataColumn(label: Text('Modalidad')),
                  DataColumn(label: Text('Canal')),
                  DataColumn(label: Text('Cliente / Mesa')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Hora')),
                ],
                rows: stats.recentOrders.map((DashboardOrder order) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(
                          order.id.substring(0, 8).toUpperCase(),
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.brandCrimson,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(Text(order.modality)),
                      DataCell(Text(order.channel)),
                      DataCell(
                        Text(
                          order.contactName ?? (order.tableId != null ? 'Mesa ${order.tableId!.substring(0, 4)}' : '-'),
                        ),
                      ),
                      DataCell(
                        Text(
                          'S/ ${order.totalAmount.toStringAsFixed(2)}',
                          style: AsiaTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(_buildStatusBadge(order.status)),
                      DataCell(
                        Text(
                          DateFormat('HH:mm').format(order.createdAt),
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.textTertiary,
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

  Widget _buildStatusBadge(String status) {
    switch (status.toUpperCase()) {
      case 'REQUESTED':
        return const AdminBadge(label: 'SOLICITADO', variant: AdminBadgeVariant.warning);
      case 'APPROVED':
        return const AdminBadge(label: 'APROBADO', variant: AdminBadgeVariant.info);
      case 'CONFIRMED':
        return const AdminBadge(label: 'CONFIRMADO', variant: AdminBadgeVariant.brand);
      case 'CLOSED':
        return const AdminBadge(label: 'CERRADO', variant: AdminBadgeVariant.success);
      case 'REJECTED':
      case 'CANCELLED':
        return const AdminBadge(label: 'CANCELADO', variant: AdminBadgeVariant.error);
      default:
        return AdminBadge(label: status, variant: AdminBadgeVariant.neutral);
    }
  }

  Widget _buildLoadingSkeletons(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: const <Widget>[
            Expanded(child: AdminSkeletonLoader(height: 120)),
            SizedBox(width: 16),
            Expanded(child: AdminSkeletonLoader(height: 120)),
            SizedBox(width: 16),
            Expanded(child: AdminSkeletonLoader(height: 120)),
            SizedBox(width: 16),
            Expanded(child: AdminSkeletonLoader(height: 120)),
          ],
        ),
        const SizedBox(height: 24),
        const AdminSkeletonLoader(height: 300),
      ],
    );
  }
}
