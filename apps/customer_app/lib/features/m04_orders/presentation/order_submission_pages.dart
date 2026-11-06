import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../../m04_orders/manage_cart/domain/cart_models.dart';
import '../choose_fulfillment/domain/fulfillment_models.dart';
import '../submit_order/application/submit_order_controller.dart';
import '../submit_order/domain/order_models.dart';

class OrderReviewPage extends StatefulWidget {
  const OrderReviewPage({
    required this.controller,
    required this.items,
    required this.fulfillment,
    required this.onBack,
    required this.onOrderPlaced,
    required this.onShowException,
    super.key,
  });

  final SubmitOrderController controller;
  final List<CartItem> items;
  final FulfillmentDraft fulfillment;
  final VoidCallback onBack;
  final void Function(OrderSnapshot order) onOrderPlaced;
  final VoidCallback onShowException;

  @override
  State<OrderReviewPage> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  Future<void> _handleSubmit() async {
    final bool ok = await widget.controller.submit();
    if (!mounted) return;

    if (ok && widget.controller.state.order != null) {
      widget.onOrderPlaced(widget.controller.state.order!);
    } else {
      widget.onShowException();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, _) {
        final OrderSubmissionState state = widget.controller.state;
        final bool isSubmitting = state.phase == OrderSubmissionPhase.submitting;

        int totalCents = 0;
        for (final CartItem item in widget.items) {
          totalCents += item.product.unitPriceCents * item.quantity;
        }
        final double totalSoles = totalCents / 100.0;
        final bool requiresAdvance = widget.fulfillment.mode != FulfillmentMode.local;
        final double advanceSoles = totalSoles * 0.5;

        final String modalityLabel = switch (widget.fulfillment.mode) {
          FulfillmentMode.local => 'Mesa en restaurante (${widget.fulfillment.tableId})',
          FulfillmentMode.delivery => 'Envío a domicilio (${widget.fulfillment.deliveryAddress})',
          FulfillmentMode.pickup => 'Recojo en local (${widget.fulfillment.contactName})',
        };

        return AsiaScaffold(
          title: 'Confirmar Pedido',
          subtitle: 'Revisa tu pedido antes de enviarlo a cocina',
          showBack: true,
          onBack: isSubmitting ? null : widget.onBack,
          bottomAction: AsiaButton(
            key: const Key('order-review-submit-button'),
            label: isSubmitting ? 'Enviando a cocina...' : 'Confirmar y Enviar Pedido',
            isLoading: isSubmitting,
            leading: LucideIcons.send,
            onPressed: isSubmitting ? null : _handleSubmit,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 12),
              // Card de Modalidad
              AsiaCard(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.brandCrimson.withValues(alpha: 0.1),
                        borderRadius: AsiaRadii.brSm,
                      ),
                      child: Icon(
                        widget.fulfillment.mode == FulfillmentMode.local
                            ? LucideIcons.utensils
                            : (widget.fulfillment.mode == FulfillmentMode.delivery
                                ? LucideIcons.bike
                                : LucideIcons.shoppingBag),
                        color: theme.brandCrimson,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Modalidad de atención',
                            style: AsiaTypography.labelSmall.copyWith(color: theme.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            modalityLabel,
                            style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Items del pedido
              AsiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Platos a preparar (${widget.items.length})',
                      style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.items.length,
                      separatorBuilder: (BuildContext context, int index) => const Divider(height: 16),
                      itemBuilder: (BuildContext context, int index) {
                        final CartItem item = widget.items[index];
                        final double lineSoles = (item.product.unitPriceCents * item.quantity) / 100.0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${item.quantity}x ${item.product.name}',
                                    style: AsiaTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.notes != null && item.notes!.isNotEmpty)
                                    Text(
                                      'Nota: ${item.notes}',
                                      style: AsiaTypography.bodySmall.copyWith(
                                        color: theme.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${lineSoles.toStringAsFixed(2)}',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Totales y anticipos
              AsiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Resumen de cobro',
                      style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Total del pedido', style: AsiaTypography.bodyMedium),
                        Text(
                          'S/ ${totalSoles.toStringAsFixed(2)}',
                          style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (requiresAdvance) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Anticipo requerido (50 %)',
                            style: AsiaTypography.bodyMedium.copyWith(color: theme.brandGold),
                          ),
                          Text(
                            'S/ ${advanceSoles.toStringAsFixed(2)}',
                            style: AsiaTypography.titleSmall.copyWith(
                              color: theme.brandGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }
}

class OrderSubmittedPage extends StatelessWidget {
  const OrderSubmittedPage({
    required this.order,
    required this.onViewTracking,
    required this.onGoHome,
    super.key,
  });

  final OrderSnapshot order;
  final VoidCallback onViewTracking;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: theme.success.withValues(alpha: 0.3), width: 1.2),
              ),
              child: Icon(LucideIcons.check, size: 40, color: theme.success),
            ),
            const SizedBox(height: 20),
            Text(
              '¡Pedido Recibido con Éxito!',
              textAlign: TextAlign.center,
              style: AsiaTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Pedido #${order.id.length >= 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
              style: AsiaTypography.titleSmall.copyWith(
                color: theme.brandGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Tu comanda ya llegó a la cocina. Nuestro maestro wok comenzará a preparar tus platos de inmediato.',
                textAlign: TextAlign.center,
                style: AsiaTypography.bodyMedium.copyWith(color: theme.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            AsiaButton(
              key: const Key('submitted-view-tracking-button'),
              label: 'Ver Seguimiento en Vivo',
              leading: LucideIcons.clock,
              onPressed: onViewTracking,
            ),
            const SizedBox(height: 12),
            AsiaButton(
              label: 'Volver a la carta principal',
              variant: AsiaButtonVariant.secondary,
              onPressed: onGoHome,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderExceptionPage extends StatelessWidget {
  const OrderExceptionPage({
    required this.controller,
    required this.onRetry,
    required this.onBack,
    super.key,
  });

  final SubmitOrderController controller;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final String error = controller.state.failure?.message ??
        'No pudimos conectar con el restaurante. Por favor verifica tu conexión.';

    return AsiaScaffold(
      title: 'Problema con el pedido',
      showBack: true,
      onBack: onBack,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.circleAlert, size: 36, color: theme.error),
            ),
            const SizedBox(height: 20),
            Text(
              'No pudimos enviar tu pedido',
              textAlign: TextAlign.center,
              style: AsiaTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: AsiaTypography.bodyMedium.copyWith(color: theme.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            AsiaButton(
              key: const Key('exception-retry-button'),
              label: 'Reintentar Envío Seguro',
              leading: LucideIcons.refreshCw,
              onPressed: onRetry,
            ),
            const SizedBox(height: 12),
            AsiaButton(
              label: 'Regresar a revisar el pedido',
              variant: AsiaButtonVariant.secondary,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
