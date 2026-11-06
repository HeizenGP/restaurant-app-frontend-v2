import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../order_tracking/application/order_history_controller.dart';
import '../order_tracking/domain/order_tracking_models.dart';
import '../submit_order/domain/order_models.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({
    required this.controller,
    required this.onBack,
    required this.onOrderSelected,
    super.key,
  });

  final OrderHistoryController controller;
  final VoidCallback onBack;
  final void Function(String orderId) onOrderSelected;

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, _) {
        final OrderHistoryState state = widget.controller.state;
        final List<OrderSnapshot> orders = state.filteredOrders;
        final bool isLoading = state.phase == OrderHistoryPhase.loading;

        return AsiaScaffold(
          title: 'Mis Pedidos',
          subtitle: 'Historial de comandas y pedidos anteriores',
          showBack: true,
          onBack: widget.onBack,
          body: isLoading
              ? const AsiaStateView(
                  kind: AsiaStateKind.loading,
                  title: 'Cargando tus pedidos...',
                )
              : state.failure != null
                  ? AsiaStateView(
                      kind: AsiaStateKind.error,
                      title: 'No pudimos cargar tu historial',
                      message: state.failure?.message,
                      actionLabel: 'Reintentar',
                      onAction: widget.controller.retry,
                    )
                  : orders.isEmpty
                      ? const AsiaStateView(
                          kind: AsiaStateKind.empty,
                          title: 'Aún no tienes pedidos registrados',
                          message: 'Realiza tu primer pedido y podrás seguir su preparación aquí.',
                          icon: LucideIcons.receiptText,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(height: 12),
                            // Selector de filtro
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: <Widget>[
                                  AsiaChip(
                                    label: 'Todos',
                                    isSelected: state.selectedFilter == OrderHistoryFilter.all,
                                    onTap: () => widget.controller.setFilter(OrderHistoryFilter.all),
                                  ),
                                  const SizedBox(width: 8),
                                  AsiaChip(
                                    label: 'Pendientes',
                                    isSelected: state.selectedFilter == OrderHistoryFilter.pending,
                                    onTap: () => widget.controller.setFilter(OrderHistoryFilter.pending),
                                  ),
                                  const SizedBox(width: 8),
                                  AsiaChip(
                                    label: 'Confirmados',
                                    isSelected: state.selectedFilter == OrderHistoryFilter.confirmed,
                                    onTap: () => widget.controller.setFilter(OrderHistoryFilter.confirmed),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: orders.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (BuildContext context, int index) {
                                final OrderSnapshot order = orders[index];
                                final String shortId = order.id.length >= 8
                                    ? order.id.substring(0, 8).toUpperCase()
                                    : order.id.toUpperCase();

                                final bool isCompleted = order.status == 'CLOSED' || order.status == 'DELIVERED';
                                final bool isCancelled = order.status == 'CANCELLED';

                                final Color statusColor = isCompleted
                                    ? theme.success
                                    : (isCancelled ? theme.error : theme.brandGold);

                                return AsiaCard(
                                  onTap: () => widget.onOrderSelected(order.id),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.12),
                                          borderRadius: AsiaRadii.brSm,
                                        ),
                                        child: Icon(
                                          isCompleted
                                              ? LucideIcons.checkCheck
                                              : (isCancelled ? LucideIcons.circleX : LucideIcons.clock),
                                          color: statusColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Text(
                                                  'Pedido #$shortId',
                                                  style: AsiaTypography.titleSmall.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withValues(alpha: 0.12),
                                                    borderRadius: AsiaRadii.brPill,
                                                  ),
                                                  child: Text(
                                                    order.status,
                                                    style: TextStyle(
                                                      color: statusColor,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              'Total: S/ ${order.totalAmount} · ${order.lines.length} items',
                                              style: AsiaTypography.bodySmall.copyWith(
                                                color: theme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(LucideIcons.chevronRight, size: 18, color: theme.textTertiary),
                                    ],
                                  ),
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
