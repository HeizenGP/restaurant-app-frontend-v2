import 'dart:async';
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
import '../../../core/layout/breakpoints.dart';
import '../application/order_controller.dart';
import '../domain/order_models.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({required this.orderController, super.key});

  final OrderController orderController;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  StaffOrder? _selectedOrder;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.orderController.loadOrders();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        widget.orderController.loadOrders(silent: true);
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
    final bool isDesktop = Breakpoints.isDesktop(context);

    return ListenableBuilder(
      listenable: widget.orderController,
      builder: (BuildContext context, _) {
        final List<StaffOrder> orders = widget.orderController.filteredOrders;
        final bool isLoading = widget.orderController.isLoading;

        if (_selectedOrder != null) {
          // Keep selection synced with fresh data
          final StaffOrder? fresh = orders.cast<StaffOrder?>().firstWhere(
                (StaffOrder? o) => o?.id == _selectedOrder!.id,
                orElse: () => null,
              );
          if (fresh != null) {
            _selectedOrder = fresh;
          }
        }

        return Padding(
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
                        'Administración de Pedidos',
                        style: AsiaTypography.displayMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Control operativo y despacho en tiempo real',
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  AdminButton(
                    label: 'Refrescar',
                    icon: LucideIcons.refreshCw,
                    variant: AdminButtonVariant.secondary,
                    size: AdminButtonSize.sm,
                    isLoading: isLoading,
                    onPressed: () => widget.orderController.loadOrders(),
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.lg),

              // Filter Bar
              AdminCard(
                padding: const EdgeInsets.all(AsiaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AdminTextField(
                      hintText: 'Buscar por ID, cliente, mesa o teléfono...',
                      prefixIcon: LucideIcons.search,
                      onChanged: (String val) =>
                          widget.orderController.setSearchQuery(val),
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _buildFilterChip(
                            label: 'TODOS',
                            isSelected: widget.orderController.statusFilter == null,
                            onTap: () =>
                                widget.orderController.setStatusFilter(null),
                          ),
                          _buildFilterChip(
                            label: 'SOLICITADOS',
                            isSelected: widget.orderController.statusFilter ==
                                OrderStatus.requested,
                            onTap: () => widget.orderController
                                .setStatusFilter(OrderStatus.requested),
                          ),
                          _buildFilterChip(
                            label: 'APROBADOS',
                            isSelected: widget.orderController.statusFilter ==
                                OrderStatus.approved,
                            onTap: () => widget.orderController
                                .setStatusFilter(OrderStatus.approved),
                          ),
                          _buildFilterChip(
                            label: 'CONFIRMADOS',
                            isSelected: widget.orderController.statusFilter ==
                                OrderStatus.confirmed,
                            onTap: () => widget.orderController
                                .setStatusFilter(OrderStatus.confirmed),
                          ),
                          _buildFilterChip(
                            label: 'CERRADOS',
                            isSelected: widget.orderController.statusFilter ==
                                OrderStatus.closed,
                            onTap: () => widget.orderController
                                .setStatusFilter(OrderStatus.closed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AsiaSpacing.lg),

              // Main Orders Body
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: _buildOrdersList(context, orders, isLoading),
                          ),
                          const SizedBox(width: AsiaSpacing.lg),
                          Expanded(
                            flex: 2,
                            child: _buildDetailPanel(context, _selectedOrder),
                          ),
                        ],
                      )
                    : _buildOrdersList(context, orders, isLoading),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
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

  Widget _buildOrdersList(
    BuildContext context,
    List<StaffOrder> orders,
    bool isLoading,
  ) {
    final AsiaThemeTokens tokens = context.tokens;

    if (isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No hay pedidos para mostrar.',
          style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary),
        ),
      );
    }

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: AsiaSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final StaffOrder order = orders[index];
        final bool isSelected = _selectedOrder?.id == order.id;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedOrder = order);
              if (!Breakpoints.isDesktop(context)) {
                _openDetailSheet(context, order);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AsiaSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? tokens.cardElevated : tokens.card,
                borderRadius: AsiaRadii.md,
                border: Border.all(
                  color: isSelected ? tokens.brandCrimson : tokens.border,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: <Widget>[
                  // Icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tokens.brandCrimson.withValues(alpha: 0.1),
                      borderRadius: AsiaRadii.sm,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      order.modality == OrderModality.local
                          ? LucideIcons.utensils
                          : (order.modality == OrderModality.delivery
                              ? LucideIcons.bike
                              : LucideIcons.packageCheck),
                      color: tokens.brandCrimson,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AsiaSpacing.md),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'PEDIDO #${order.id.substring(0, 8).toUpperCase()}',
                              style: AsiaTypography.headingMedium.copyWith(
                                color: tokens.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.modality.displayName} • ${order.contactName ?? (order.tableId != null ? 'Mesa ${order.tableId!.substring(0, 4)}' : 'Cliente')} • ${order.items.length} platos',
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total & Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'S/ ${order.totalAmount.toStringAsFixed(2)}',
                        style: AsiaTypography.headingMedium.copyWith(
                          color: tokens.brandGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('HH:mm').format(order.createdAt),
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPanel(BuildContext context, StaffOrder? order) {
    final AsiaThemeTokens tokens = context.tokens;

    if (order == null) {
      return AdminCard(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Text(
              'Selecciona un pedido de la lista para ver sus detalles y ejecutar acciones operativas.',
              style: AsiaTypography.bodyMedium.copyWith(
                color: tokens.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final bool isActionLoading = widget.orderController.isActionLoading;

    return AdminCard(
      title: 'Detalle de Pedido #${order.id.substring(0, 8).toUpperCase()}',
      subtitle: '${order.modality.displayName} • Canal: ${order.channel}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header Summary Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildStatusBadge(order.status),
              Text(
                'S/ ${order.totalAmount.toStringAsFixed(2)}',
                style: AsiaTypography.metricMedium.copyWith(
                  color: tokens.brandCrimson,
                ),
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.md),
          Divider(color: tokens.borderSubtle),
          const SizedBox(height: AsiaSpacing.sm),

          // Client / Table Info
          if (order.tableId != null)
            _buildInfoRow('Mesa asignada:', order.tableId!.substring(0, 8)),
          if (order.contactName != null)
            _buildInfoRow('Cliente:', order.contactName!),
          if (order.contactPhone != null)
            _buildInfoRow('Teléfono:', order.contactPhone!),
          if (order.deliveryAddress != null)
            _buildInfoRow('Dirección de entrega:', order.deliveryAddress!),
          _buildInfoRow('Hora de solicitud:', DateFormat('HH:mm:ss - dd/MM/yyyy').format(order.createdAt)),

          const SizedBox(height: AsiaSpacing.md),
          Text(
            'Platos e Ítems Solicitados',
            style: AsiaTypography.headingMedium.copyWith(
              color: tokens.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AsiaSpacing.sm),

          // Items list
          Container(
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AsiaRadii.md,
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: order.items.map((OrderItem item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tokens.brandCrimson.withValues(alpha: 0.15),
                          borderRadius: AsiaRadii.sm,
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.brandCrimson,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.productName,
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        'S/ ${item.subtotal.toStringAsFixed(2)}',
                        style: AsiaTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AsiaSpacing.xl),

          // Operational Action Buttons
          Text(
            'Acciones Operativas',
            style: AsiaTypography.headingMedium.copyWith(
              color: tokens.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AsiaSpacing.sm),

          if (order.isRequested) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AdminButton(
                    label: 'Aprobar Pedido',
                    icon: LucideIcons.check,
                    isLoading: isActionLoading,
                    onPressed: () => widget.orderController
                        .decideOrder(order.id, approved: true),
                  ),
                ),
                const SizedBox(width: AsiaSpacing.md),
                Expanded(
                  child: AdminButton(
                    label: 'Rechazar',
                    icon: LucideIcons.x,
                    variant: AdminButtonVariant.danger,
                    isLoading: isActionLoading,
                    onPressed: () => widget.orderController
                        .decideOrder(order.id, approved: false),
                  ),
                ),
              ],
            ),
          ] else if (order.isApproved) ...<Widget>[
            AdminButton(
              label: 'Confirmar y Enviar a Cocina',
              icon: LucideIcons.chefHat,
              variant: AdminButtonVariant.gold,
              isFullWidth: true,
              isLoading: isActionLoading,
              onPressed: () => widget.orderController.confirmOrder(order.id),
            ),
          ] else if (order.isConfirmed) ...<Widget>[
            AdminButton(
              label: 'Cobrar en Caja (S/ ${order.totalAmount.toStringAsFixed(2)})',
              icon: LucideIcons.dollarSign,
              variant: AdminButtonVariant.primary,
              isFullWidth: true,
              isLoading: isActionLoading,
              onPressed: () => _openPaymentDialog(context, order),
            ),
            const SizedBox(height: AsiaSpacing.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: AdminButton(
                    label: order.modality == OrderModality.local
                        ? 'Servir en Mesa'
                        : (order.modality == OrderModality.delivery
                            ? 'Entregar a Delivery'
                            : 'Entregar en Tienda'),
                    icon: LucideIcons.send,
                    isLoading: isActionLoading,
                    onPressed: () => widget.orderController
                        .fulfillOrder(order.id, order.modality),
                  ),
                ),
                const SizedBox(width: AsiaSpacing.md),
                Expanded(
                  child: AdminButton(
                    label: 'Cerrar Pedido',
                    icon: LucideIcons.checkCheck,
                    variant: AdminButtonVariant.secondary,
                    isLoading: isActionLoading,
                    onPressed: () =>
                        widget.orderController.closeOrder(order.id),
                  ),
                ),
              ],
            ),
          ] else if (order.isClosed) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(AsiaSpacing.md),
              decoration: BoxDecoration(
                color: tokens.success.withValues(alpha: 0.1),
                borderRadius: AsiaRadii.md,
                border: Border.all(color: tokens.success.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: Text(
                '✓ Pedido cerrado y finalizado exitosamente.',
                style: AsiaTypography.caption.copyWith(
                  color: tokens.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final AsiaThemeTokens tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AsiaTypography.caption.copyWith(
                color: tokens.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AsiaTypography.caption.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    switch (status) {
      case OrderStatus.requested:
        return const AdminBadge(label: 'SOLICITADO', variant: AdminBadgeVariant.warning);
      case OrderStatus.approved:
        return const AdminBadge(label: 'APROBADO', variant: AdminBadgeVariant.info);
      case OrderStatus.confirmed:
        return const AdminBadge(label: 'CONFIRMADO', variant: AdminBadgeVariant.brand);
      case OrderStatus.closed:
        return const AdminBadge(label: 'CERRADO', variant: AdminBadgeVariant.success);
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return const AdminBadge(label: 'CANCELADO', variant: AdminBadgeVariant.error);
    }
  }

  void _openDetailSheet(BuildContext context, StaffOrder order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => Container(
        padding: const EdgeInsets.all(AsiaSpacing.lg),
        decoration: BoxDecoration(
          color: context.tokens.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(child: _buildDetailPanel(context, order)),
      ),
    );
  }

  void _openPaymentDialog(BuildContext context, StaffOrder order) {
    final TextEditingController amountCtrl =
        TextEditingController(text: order.totalAmount.toStringAsFixed(2));
    final TextEditingController refCtrl = TextEditingController();
    String selectedMethod = 'EFECTIVO';

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            final AsiaThemeTokens tokens = ctx.tokens;

            return AdminDialog(
              title: 'Cobrar Pedido #${order.id.substring(0, 8).toUpperCase()}',
              subtitle: 'Registro de cobro directo en caja para el pedido actual.',
              maxWidth: 440,
              confirmLabel: 'Confirmar Cobro',
              isConfirmLoading: widget.orderController.isActionLoading,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onConfirm: () async {
                final double? amount = double.tryParse(amountCtrl.text.trim());
                if (amount == null || amount <= 0) return;

                final ScaffoldMessengerState messenger =
                    ScaffoldMessenger.of(context);
                final NavigatorState nav = Navigator.of(dialogContext);

                final bool ok = await widget.orderController.recordPayment(
                  orderId: order.id,
                  amount: amount,
                  methodCode: selectedMethod,
                  referenceCode:
                      refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
                );

                if (ok && mounted) {
                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cobro de S/ ${amount.toStringAsFixed(2)} registrado con éxito.',
                      ),
                      backgroundColor: tokens.success,
                    ),
                  );
                } else if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.orderController.errorMessage ??
                            'Error al registrar cobro.',
                      ),
                      backgroundColor: tokens.error,
                    ),
                  );
                }
              },
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Total de la orden: S/ ${order.totalAmount.toStringAsFixed(2)}',
                    style: AsiaTypography.headingMedium.copyWith(
                      color: tokens.brandCrimson,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AsiaSpacing.md),
                  AdminTextField(
                    controller: amountCtrl,
                    label: 'Monto a Cobrar (S/)',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: LucideIcons.dollarSign,
                  ),
                  const SizedBox(height: AsiaSpacing.md),
                  Text(
                    'Método de Pago',
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: tokens.cardElevated,
                      borderRadius: AsiaRadii.md,
                      border: Border.all(color: tokens.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMethod,
                        isExpanded: true,
                        dropdownColor: tokens.cardElevated,
                        style: AsiaTypography.bodyMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                              value: 'EFECTIVO', child: Text('Efectivo')),
                          DropdownMenuItem(value: 'YAPE', child: Text('Yape')),
                          DropdownMenuItem(value: 'PLIN', child: Text('Plin')),
                          DropdownMenuItem(
                              value: 'TARJETA',
                              child: Text('Tarjeta de Débito / Crédito')),
                        ],
                        onChanged: (String? val) {
                          if (val != null) {
                            setState(() => selectedMethod = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AsiaSpacing.md),
                  AdminTextField(
                    controller: refCtrl,
                    label: 'Código de Operación / Ref (opcional)',
                    hintText: 'ej. 128492 o últimos 4 dígitos',
                    prefixIcon: LucideIcons.hash,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
