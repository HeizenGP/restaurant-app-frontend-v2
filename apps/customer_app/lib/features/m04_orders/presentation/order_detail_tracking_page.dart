import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../choose_fulfillment/domain/fulfillment_models.dart';
import '../order_tracking/application/order_tracking_controller.dart';
import '../order_tracking/domain/order_tracking_models.dart';
import '../submit_order/domain/order_models.dart';

class OrderDetailTrackingPage extends StatefulWidget {
  const OrderDetailTrackingPage({
    required this.orderId,
    required this.controller,
    required this.onBack,
    this.onViewAdvance,
    this.onViewPayments,
    super.key,
  });

  final String orderId;
  final OrderTrackingController controller;
  final VoidCallback onBack;
  final void Function(String orderId)? onViewAdvance;
  final void Function(String orderId)? onViewPayments;

  @override
  State<OrderDetailTrackingPage> createState() => _OrderDetailTrackingPageState();
}

class _OrderDetailTrackingPageState extends State<OrderDetailTrackingPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    unawaited(widget.controller.load(widget.orderId));
  }

  void _showOrderBreakdown(BuildContext context, OrderSnapshot order) {
    final AsiaTheme theme = context.asiaTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Detalle del pedido', style: AsiaTypography.titleMedium),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.lines.length,
              separatorBuilder: (BuildContext context, int index) => const Divider(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final OrderLineSnapshot line = order.lines[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${line.quantity}x ${line.productName}',
                      style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text('S/ ${line.unitPrice}', style: AsiaTypography.bodyMedium),
                  ],
                );
              },
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Total', style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)),
                Text(
                  'S/ ${order.totalAmount}',
                  style: AsiaTypography.titleSmall.copyWith(
                    color: theme.brandCrimson,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AsiaButton(
              label: 'Cerrar',
              variant: AsiaButtonVariant.secondary,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationDialog(BuildContext context) {
    final TextEditingController reasonCtrl = TextEditingController();
    final AsiaTheme theme = context.asiaTheme;

    showDialog<void>(
      context: context,
      builder: (BuildContext dContext) => AlertDialog(
        backgroundColor: theme.surface,
        shape: const RoundedRectangleBorder(borderRadius: AsiaRadii.brCard),
        title: Text('Solicitar cancelación', style: AsiaTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Indica el motivo por el cual deseas cancelar el pedido:',
              style: AsiaTypography.bodySmall,
            ),
            const SizedBox(height: 12),
            AsiaTextField(
              controller: reasonCtrl,
              hintText: 'Motivo de la cancelación...',
              maxLines: 2,
              autofocus: true,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: Text('Regresar', style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              if (reasonCtrl.text.trim().isNotEmpty) {
                Navigator.of(dContext).pop();
                final bool ok = await widget.controller.requestCancellation(
                  reason: reasonCtrl.text.trim(),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Cancelación solicitada con éxito'
                        : (widget.controller.state.failure?.message ?? 'No se pudo cancelar')),
                    backgroundColor: ok ? theme.brandCrimson : theme.error,
                  ),
                );
              }
            },
            child: Text('Confirmar', style: TextStyle(color: theme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, _) {
        final OrderTrackingState state = widget.controller.state;
        final OrderSnapshot? order = state.order;
        final OrderTrackingSnapshot? tracking = state.tracking;

        if (state.phase == OrderTrackingPhase.loading && order == null) {
          return AsiaScaffold(
            title: 'Seguimiento',
            showBack: true,
            onBack: widget.onBack,
            body: const AsiaStateView(
              kind: AsiaStateKind.loading,
              title: 'Consultando estado del pedido...',
            ),
          );
        }

        if (state.phase == OrderTrackingPhase.failure && order == null) {
          return AsiaScaffold(
            title: 'Seguimiento',
            showBack: true,
            onBack: widget.onBack,
            body: AsiaStateView(
              kind: AsiaStateKind.error,
              title: 'No pudimos consultar el pedido',
              message: state.failure?.message,
              actionLabel: 'Reintentar',
              onAction: _load,
            ),
          );
        }

        if (order == null || tracking == null) {
          return AsiaScaffold(
            title: 'Seguimiento',
            showBack: true,
            onBack: widget.onBack,
            body: const AsiaStateView(
              kind: AsiaStateKind.empty,
              title: 'Sin información disponible',
            ),
          );
        }

        final bool isCancelled = state.isCancellationRequested || order.status == 'CANCELLED';
        final bool canCancel = !isCancelled &&
            order.status != 'CLOSED' &&
            order.status != 'REJECTED' &&
            order.status != 'CANCELLED';
        final bool showAdvance = tracking.modality != FulfillmentMode.local && widget.onViewAdvance != null;

        final int stageIndex = switch (tracking.stage) {
          'CONFIRMED' || 'REQUESTED' => 1,
          'EN_COCINA' || 'PREPARING' => 2,
          'LISTO' || 'READY' || 'IN_DELIVERY' => 3,
          'DELIVERED' || 'CLOSED' => 4,
          _ => 1,
        };

        return AsiaScaffold(
          title: 'Seguimiento en Vivo',
          subtitle: 'Pedido #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
          showBack: true,
          onBack: widget.onBack,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 12),
              // Alerta si está cancelado
              if (isCancelled) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.error.withValues(alpha: 0.1),
                    borderRadius: AsiaRadii.brMd,
                    border: Border.all(color: theme.error.withValues(alpha: 0.3), width: 0.8),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.circleAlert, size: 20, color: theme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cancelación solicitada: ${state.cancellationObservation ?? "En proceso"}',
                          style: AsiaTypography.bodySmall.copyWith(
                            color: theme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Timeline de etapas
              AsiaCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Estado de preparación',
                      style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        _TimelineStep(
                          stepNumber: 1,
                          title: 'Comanda',
                          isActive: stageIndex >= 1,
                          isCurrent: stageIndex == 1,
                        ),
                        _TimelineConnector(isActive: stageIndex >= 2),
                        _TimelineStep(
                          stepNumber: 2,
                          title: 'Al Wok',
                          isActive: stageIndex >= 2,
                          isCurrent: stageIndex == 2,
                        ),
                        _TimelineConnector(isActive: stageIndex >= 3),
                        _TimelineStep(
                          stepNumber: 3,
                          title: 'Listo',
                          isActive: stageIndex >= 3,
                          isCurrent: stageIndex == 3,
                        ),
                        _TimelineConnector(isActive: stageIndex >= 4),
                        _TimelineStep(
                          stepNumber: 4,
                          title: 'Servido',
                          isActive: stageIndex >= 4,
                          isCurrent: stageIndex == 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Modalidad de entrega
              AsiaCard(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.brandGold.withValues(alpha: 0.12),
                        borderRadius: AsiaRadii.brSm,
                      ),
                      child: Icon(
                        order.modality == FulfillmentMode.local
                            ? LucideIcons.utensils
                            : (order.modality == FulfillmentMode.delivery
                                ? LucideIcons.bike
                                : LucideIcons.shoppingBag),
                        size: 20,
                        color: theme.brandGold,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            order.modality == FulfillmentMode.local
                                ? 'Consumo en Salón'
                                : (order.modality == FulfillmentMode.delivery
                                    ? 'Entrega a Domicilio'
                                    : 'Recojo en Local'),
                            style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.deliveryAddress ?? 'Chifa ASIA Salón Principal',
                            style: AsiaTypography.bodySmall.copyWith(color: theme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Resumen de Platos
              AsiaCard(
                onTap: () => _showOrderBreakdown(context, order),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.surfaceSubtle,
                        borderRadius: AsiaRadii.brSm,
                      ),
                      child: Icon(LucideIcons.utensilsCrossed, size: 20, color: theme.brandCrimson),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Platos del pedido (${order.lines.length})',
                            style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Toca para ver el desglose completo',
                            style: AsiaTypography.bodySmall.copyWith(color: theme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, size: 18, color: theme.textTertiary),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Estado de pagos
              AsiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Estado de pago',
                          style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tracking.paymentStatus == 'PAID'
                                ? theme.success.withValues(alpha: 0.15)
                                : theme.brandGold.withValues(alpha: 0.15),
                            borderRadius: AsiaRadii.brPill,
                          ),
                          child: Text(
                            tracking.paymentStatus,
                            style: AsiaTypography.labelSmall.copyWith(
                              color: tracking.paymentStatus == 'PAID' ? theme.success : theme.brandGold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Total: S/ ${tracking.totalAmount}', style: AsiaTypography.bodyMedium),
                        Text('Saldo: S/ ${tracking.balance}', style: AsiaTypography.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Acciones adicionales
              if (showAdvance) ...<Widget>[
                AsiaButton(
                  label: 'Ver Estado del Anticipo (50 %)',
                  variant: AsiaButtonVariant.secondary,
                  leading: LucideIcons.creditCard,
                  onPressed: () => widget.onViewAdvance!(order.id),
                ),
                const SizedBox(height: 10),
              ],
              if (canCancel) ...<Widget>[
                AsiaButton(
                  label: 'Solicitar Cancelación',
                  variant: AsiaButtonVariant.ghost,
                  leading: LucideIcons.ban,
                  onPressed: () => _showCancellationDialog(context),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ==============================================================================
// COMPONENTES DE TIMELINE
// ==============================================================================

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCurrent,
  });

  final int stepNumber;
  final String title;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    final Color circleBg = isActive ? theme.brandCrimson : theme.surfaceSubtle;
    final Color circleBorder = isCurrent ? theme.brandGold : (isActive ? theme.brandCrimson : theme.border);
    final Color textColor = isActive ? theme.textPrimary : theme.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            border: Border.all(color: circleBorder, width: isCurrent ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: TextStyle(
              color: isActive ? Colors.white : theme.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AsiaTypography.labelSmall.copyWith(
            color: textColor,
            fontSize: 10.5,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? theme.brandCrimson : theme.border,
        margin: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
}
