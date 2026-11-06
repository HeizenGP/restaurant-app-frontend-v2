import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../view_payment_status/application/payment_status_controller.dart';
import '../view_payment_status/domain/payment_models.dart';

class AdvanceStatusPage extends StatefulWidget {
  const AdvanceStatusPage({
    required this.orderId,
    required this.controller,
    required this.onBack,
    required this.onViewOrder,
    super.key,
  });

  final String orderId;
  final PaymentStatusController controller;
  final VoidCallback onBack;
  final VoidCallback onViewOrder;

  @override
  State<AdvanceStatusPage> createState() => _AdvanceStatusPageState();
}

class _AdvanceStatusPageState extends State<AdvanceStatusPage> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.loadAdvance(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, _) {
        final PaymentStatusState state = widget.controller.state;
        final AdvanceSummary? advance = state.advance;

        if (state.phase == PaymentStatusPhase.loading && advance == null) {
          return AsiaScaffold(
            title: 'Anticipo del Pedido',
            showBack: true,
            onBack: widget.onBack,
            body: const AsiaStateView(
              kind: AsiaStateKind.loading,
              title: 'Consultando anticipo...',
            ),
          );
        }

        if (state.phase == PaymentStatusPhase.failure && advance == null) {
          return AsiaScaffold(
            title: 'Anticipo del Pedido',
            showBack: true,
            onBack: widget.onBack,
            body: AsiaStateView(
              kind: AsiaStateKind.error,
              title: 'No pudimos consultar el anticipo',
              message: state.failure?.message,
              actionLabel: 'Reintentar',
              onAction: () => widget.controller.retry(),
            ),
          );
        }

        if (advance == null) {
          return AsiaScaffold(
            title: 'Anticipo del Pedido',
            showBack: true,
            onBack: widget.onBack,
            body: const AsiaStateView(
              kind: AsiaStateKind.empty,
              title: 'Sin información de anticipo',
            ),
          );
        }

        final bool isVerified = advance.isVerified;

        return AsiaScaffold(
          title: 'Anticipo (50 %)',
          subtitle: 'Pedido #${advance.orderId.length >= 8 ? advance.orderId.substring(0, 8).toUpperCase() : advance.orderId.toUpperCase()}',
          showBack: true,
          onBack: widget.onBack,
          bottomAction: AsiaButton(
            label: 'Ver Seguimiento del Pedido',
            leading: LucideIcons.receiptText,
            onPressed: widget.onViewOrder,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 12),
              // Banner de estado de verificación
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isVerified
                      ? theme.success.withValues(alpha: 0.12)
                      : theme.brandGold.withValues(alpha: 0.12),
                  borderRadius: AsiaRadii.brCard,
                  border: Border.all(
                    color: isVerified
                        ? theme.success.withValues(alpha: 0.3)
                        : theme.brandGold.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      isVerified ? LucideIcons.checkCheck : LucideIcons.clock,
                      color: isVerified ? theme.success : theme.brandGold,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            isVerified
                                ? 'Anticipo verificado'
                                : 'Pendiente de verificación administrativa',
                            style: AsiaTypography.titleSmall.copyWith(
                              color: isVerified ? theme.success : theme.brandGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isVerified
                                ? 'El pago del 50 % fue validado por caja. Tu pedido está en marcha.'
                                : 'Nuestro equipo está confirmando la transferencia o comprobante.',
                            style: AsiaTypography.bodySmall.copyWith(color: theme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Desglose de montos
              AsiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Detalle económico',
                      style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    _AmountRow(label: 'Total del pedido', amount: 'S/ ${advance.totalAmount}'),
                    const SizedBox(height: 10),
                    _AmountRow(
                      label: 'Anticipo requerido (50 %)',
                      amount: 'S/ ${advance.requiredAmount}',
                      amountColor: theme.brandGold,
                    ),
                    const SizedBox(height: 10),
                    _AmountRow(
                      label: 'Monto verificado',
                      amount: 'S/ ${advance.verifiedAmount}',
                      amountColor: theme.success,
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider()),
                    _AmountRow(
                      label: 'Saldo pendiente contra entrega',
                      amount: 'S/ ${advance.remainingAmount}',
                      isBold: true,
                    ),
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

class OrderPaymentStatusPage extends StatefulWidget {
  const OrderPaymentStatusPage({
    required this.orderId,
    required this.controller,
    required this.onBack,
    super.key,
  });

  final String orderId;
  final PaymentStatusController controller;
  final VoidCallback onBack;

  @override
  State<OrderPaymentStatusPage> createState() => _OrderPaymentStatusPageState();
}

class _OrderPaymentStatusPageState extends State<OrderPaymentStatusPage> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.loadPayments(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, _) {
        final PaymentStatusState state = widget.controller.state;
        final PaymentSummary? summary = state.paymentSummary;

        if (state.phase == PaymentStatusPhase.loading && summary == null) {
          return AsiaScaffold(
            title: 'Estado de Pagos',
            showBack: true,
            onBack: widget.onBack,
            body: const AsiaStateView(
              kind: AsiaStateKind.loading,
              title: 'Consultando pagos...',
            ),
          );
        }

        if (summary == null) {
          return AsiaScaffold(
            title: 'Estado de Pagos',
            showBack: true,
            onBack: widget.onBack,
            body: const AsiaStateView(
              kind: AsiaStateKind.empty,
              title: 'No hay pagos registrados',
            ),
          );
        }

        return AsiaScaffold(
          title: 'Estado de Pagos',
          subtitle: 'Comprobantes y abonos registrados',
          showBack: true,
          onBack: widget.onBack,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 12),
              AsiaCard(
                child: Column(
                  children: <Widget>[
                    _AmountRow(label: 'Total pedido', amount: 'S/ ${summary.totalAmount}'),
                    const SizedBox(height: 10),
                    _AmountRow(label: 'Total pagado', amount: 'S/ ${summary.paidAmount}', amountColor: theme.success),
                    const SizedBox(height: 10),
                    _AmountRow(label: 'Saldo restante', amount: 'S/ ${summary.balance}', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Abonos recibidos (${summary.payments.length})',
                style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (summary.payments.isEmpty)
                const AsiaStateView(
                  kind: AsiaStateKind.empty,
                  title: 'Sin abonos aún',
                  message: 'Los pagos confirmados aparecerán listados aquí.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summary.payments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final PaymentRecord record = summary.payments[index];
                    return AsiaCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                record.kind,
                                style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (record.methodCode != null)
                                Text('Método: ${record.methodCode}', style: AsiaTypography.bodySmall),
                            ],
                          ),
                          Text(
                            'S/ ${record.amount}',
                            style: AsiaTypography.titleMedium.copyWith(
                              color: theme.success,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.amountColor,
    this.isBold = false,
  });

  final String label;
  final String amount;
  final Color? amountColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: isBold
              ? AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)
              : AsiaTypography.bodyMedium,
        ),
        Text(
          amount,
          style: (isBold
                  ? AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w800)
                  : AsiaTypography.bodyMedium)
              .copyWith(color: amountColor ?? theme.textPrimary),
        ),
      ],
    );
  }
}
