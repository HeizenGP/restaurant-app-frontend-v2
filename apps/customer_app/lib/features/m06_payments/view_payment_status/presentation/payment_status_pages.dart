import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../app/theme/theme_mode_controller.dart';
import '../../../../../core/design_system/design_system.dart';
import '../application/payment_status_controller.dart';
import '../domain/payment_models.dart';

class AdvanceStatusPage extends StatefulWidget {
  const AdvanceStatusPage({
    required this.themeModeController,
    required this.controller,
    required this.orderId,
    required this.onViewOrder,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final PaymentStatusController controller;
  final String orderId;
  final VoidCallback onViewOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  State<AdvanceStatusPage> createState() => _AdvanceStatusPageState();
}

class _AdvanceStatusPageState extends State<AdvanceStatusPage> {
  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant AdvanceStatusPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId ||
        oldWidget.controller != widget.controller) {
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.controller.loadAdvance(widget.orderId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final PaymentStatusState state = widget.controller.state;
        final AdvanceSummary? advance =
            state.view == PaymentStatusView.advance &&
                state.phase == PaymentStatusPhase.ready &&
                state.orderId == widget.orderId
            ? state.advance
            : null;
        if (advance != null) {
          return AdvanceSummaryPage(
            themeModeController: widget.themeModeController,
            summary: advance,
            onViewOrder: widget.onViewOrder,
            onBackPressed: widget.onBackPressed,
            showBackButton: widget.showBackButton,
            initials: widget.initials,
            avatarPath: widget.avatarPath,
            onAvatarPressed: widget.onAvatarPressed,
            onCartPressed: widget.onCartPressed,
            cartItemCount: widget.cartItemCount,
          );
        }
        return _PaymentStatePage(
          pageKey: const Key('page-advance-state'),
          themeModeController: widget.themeModeController,
          title: 'Anticipo del 50 %',
          subtitle: 'Solo aplicable a recojo o delivery.',
          state: state,
          loadingTitle: 'Consultando anticipo',
          onBackPressed: widget.onBackPressed ?? widget.onViewOrder,
          showBackButton: widget.showBackButton,
          initials: widget.initials,
          avatarPath: widget.avatarPath,
          onAvatarPressed: widget.onAvatarPressed,
          onCartPressed: widget.onCartPressed,
          cartItemCount: widget.cartItemCount,
          onRetry: state.canRetry
              ? () {
                  unawaited(widget.controller.retry());
                }
              : null,
        );
      },
    );
  }
}

class AdvanceSummaryPage extends StatelessWidget {
  const AdvanceSummaryPage({
    required this.themeModeController,
    required this.summary,
    required this.onViewOrder,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final AdvanceSummary summary;
  final VoidCallback onViewOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return _PaymentFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-advance-summary'),
        title: 'Anticipo del 50 %',
        subtitle: 'Solo aplicable a recojo o delivery.',
        contentGap: 35,
        themeModeController: themeModeController,
        onBackPressed: onBackPressed ?? onViewOrder,
        showBackButton: showBackButton,
        initials: initials,
        avatarPath: avatarPath,
        onAvatarPressed: onAvatarPressed,
        onCartPressed: onCartPressed,
        cartItemCount: cartItemCount,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChifaCard(
              key: const Key('advance-total'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Total del pedido',
              subtitle: 'S/ ${summary.totalAmount} · importe real del servidor',
              minimumHeight: 77,
            ),
            const SizedBox(height: 23),
            ChifaCard(
              key: const Key('advance-required'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Anticipo requerido',
              subtitle: 'S/ ${summary.requiredAmount} · 50 % según backend',
              minimumHeight: 77,
            ),
            const SizedBox(height: 23),
            ChifaCard(
              key: const Key('advance-verification'),
              icon: LucideIcons.info,
              iconColor: _figmaIconColor(context),
              title: 'Estado de verificación',
              subtitle: _verificationSubtitle(summary),
              minimumHeight: 77,
            ),
            const SizedBox(height: 34),
            ChifaCard(
              key: const Key('advance-no-electronic-payment'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Sin pago electrónico',
              subtitle: 'Registro manual o simulado, sin pasarela',
              minimumHeight: 77,
              onTap: () => _showPaymentGatewayDialog(context, summary.requiredAmount),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('advance-pay-gateway-button'),
              icon: const Icon(LucideIcons.creditCard, size: 18),
              label: const Text('Simular pago (Yape, Plin o Tarjeta)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appPalette.brandRed,
                side: BorderSide(color: context.appPalette.brandRed),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _showPaymentGatewayDialog(context, summary.requiredAmount),
            ),
            const SizedBox(height: 40),
            ChifaButton(
              key: const Key('advance-view-order'),
              label: 'Ver estado del pedido',
              height: 54,
              borderRadius: 14,
              onPressed: onViewOrder,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderPaymentStatusPage extends StatefulWidget {
  const OrderPaymentStatusPage({
    required this.themeModeController,
    required this.controller,
    required this.orderId,
    required this.onBackToOrder,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final PaymentStatusController controller;
  final String orderId;
  final VoidCallback onBackToOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  State<OrderPaymentStatusPage> createState() => _OrderPaymentStatusPageState();
}

class _OrderPaymentStatusPageState extends State<OrderPaymentStatusPage> {
  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant OrderPaymentStatusPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId ||
        oldWidget.controller != widget.controller) {
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.controller.loadPayments(widget.orderId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final PaymentStatusState state = widget.controller.state;
        final PaymentSummary? summary =
            state.view == PaymentStatusView.payments &&
                state.phase == PaymentStatusPhase.ready &&
                state.orderId == widget.orderId
            ? state.paymentSummary
            : null;
        if (summary != null) {
          return PaymentSummaryPage(
            themeModeController: widget.themeModeController,
            summary: summary,
            onBackToOrder: widget.onBackToOrder,
            onBackPressed: widget.onBackPressed,
            showBackButton: widget.showBackButton,
            initials: widget.initials,
            avatarPath: widget.avatarPath,
            onAvatarPressed: widget.onAvatarPressed,
            onCartPressed: widget.onCartPressed,
            cartItemCount: widget.cartItemCount,
          );
        }
        return _PaymentStatePage(
          pageKey: const Key('page-payment-state'),
          themeModeController: widget.themeModeController,
          title: 'Estado de pago',
          subtitle: 'Resumen consultable de tu pedido.',
          state: state,
          loadingTitle: 'Consultando pagos',
          onBackPressed: widget.onBackPressed ?? widget.onBackToOrder,
          showBackButton: widget.showBackButton,
          initials: widget.initials,
          avatarPath: widget.avatarPath,
          onAvatarPressed: widget.onAvatarPressed,
          onCartPressed: widget.onCartPressed,
          cartItemCount: widget.cartItemCount,
          onRetry: state.canRetry
              ? () {
                  unawaited(widget.controller.retry());
                }
              : null,
        );
      },
    );
  }
}

class PaymentSummaryPage extends StatelessWidget {
  const PaymentSummaryPage({
    required this.themeModeController,
    required this.summary,
    required this.onBackToOrder,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final PaymentSummary summary;
  final VoidCallback onBackToOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return _PaymentFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-payment-summary'),
        title: 'Estado de pago',
        subtitle: 'Resumen consultable de tu pedido.',
        contentGap: 30,
        themeModeController: themeModeController,
        onBackPressed: onBackPressed ?? onBackToOrder,
        showBackButton: showBackButton,
        initials: initials,
        avatarPath: avatarPath,
        onAvatarPressed: onAvatarPressed,
        onCartPressed: onCartPressed,
        cartItemCount: cartItemCount,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChifaCard(
              key: const Key('payment-total'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Total del pedido',
              subtitle: 'S/ ${summary.totalAmount} · total_amount desde la API',
              minimumHeight: 77,
            ),
            const SizedBox(height: 22),
            ChifaCard(
              key: const Key('payment-paid'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Pagado',
              subtitle:
                  'S/ ${summary.paidAmount} · incluye anticipo registrado',
              minimumHeight: 77,
            ),
            const SizedBox(height: 22),
            ChifaCard(
              key: const Key('payment-balance'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Saldo pendiente',
              subtitle: 'S/ ${summary.balance} · calculado por backend',
              minimumHeight: 77,
            ),
            const SizedBox(height: 22),
            ChifaCard(
              key: const Key('payment-status'),
              icon: LucideIcons.info,
              iconColor: _figmaIconColor(context),
              title: 'Estado: ${summary.paymentStatus}',
              subtitle: 'payment_status desde GET /payments',
              minimumHeight: 77,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('payment-gateway-button'),
              icon: const Icon(LucideIcons.creditCard, size: 18),
              label: const Text('Simular pago (Yape, Plin o Tarjeta)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appPalette.brandRed,
                side: BorderSide(color: context.appPalette.brandRed),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _showPaymentGatewayDialog(context, summary.balance),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'El cobro lo registra el personal autorizado.',
                    key: const Key('payment-staff-note'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 23),
            ChifaButton(
              key: const Key('payment-back-to-order'),
              label: 'Volver al pedido',
              height: 54,
              borderRadius: 14,
              onPressed: onBackToOrder,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStatePage extends StatelessWidget {
  const _PaymentStatePage({
    required this.pageKey,
    required this.themeModeController,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.loadingTitle,
    this.onRetry,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
  });

  final Key pageKey;
  final ThemeModeController themeModeController;
  final String title;
  final String subtitle;
  final PaymentStatusState state;
  final String loadingTitle;
  final VoidCallback? onRetry;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    final bool isFailure = state.phase == PaymentStatusPhase.failure;
    return _PaymentFrame(
      child: ChifaPageScaffold(
        pageKey: pageKey,
        title: title,
        subtitle: subtitle,
        themeModeController: themeModeController,
        onBackPressed: onBackPressed,
        showBackButton: showBackButton,
        initials: initials,
        avatarPath: avatarPath,
        onAvatarPressed: onAvatarPressed,
        onCartPressed: onCartPressed,
        cartItemCount: cartItemCount,
        child: ChifaStateView(
          kind: isFailure ? ChifaStateKind.error : ChifaStateKind.loading,
          title: isFailure ? 'No pudimos consultar' : loadingTitle,
          message: isFailure
              ? state.failure?.message ?? 'Inténtalo nuevamente.'
              : 'Espera un momento.',
          actionLabel: onRetry == null ? null : 'Reintentar',
          onAction: onRetry,
        ),
      ),
    );
  }
}

String _verificationSubtitle(AdvanceSummary summary) {
  if (!summary.isVerified) return 'Pendiente de verificación administrativa';
  return 'S/ ${summary.verifiedAmount} · verificado por Administrador';
}

Color _figmaIconColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFE2BC75)
      : const Color(0xFF922832);
}

void _showPaymentGatewayDialog(BuildContext context, String amount) {
  final AppPalette palette = context.appPalette;
  int selectedGateway = 0; // 0: Yape, 1: Plin, 2: Tarjeta
  final TextEditingController phoneController = TextEditingController(text: '987 654 321');
  final TextEditingController cardController = TextEditingController(text: '4557 1234 5678 9012');
  final TextEditingController expiryController = TextEditingController(text: '12/28');
  final TextEditingController cvvController = TextEditingController(text: '123');
  bool isPaid = false;

  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            key: const Key('payment-gateway-dialog'),
            backgroundColor: palette.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: palette.border),
            ),
            title: Row(
              children: <Widget>[
                Icon(LucideIcons.creditCard, color: palette.accentGold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPaid ? '¡Pago Simulado Exitoso!' : 'Pasarela de Pago',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: isPaid
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(LucideIcons.circleCheck, color: Colors.green, size: 54),
                        const SizedBox(height: 12),
                        Text(
                          'Monto abonado: S/ $amount',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tu comprobante ha sido registrado y el personal del restaurante podrá confirmarlo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: palette.surfaceTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Monto a pagar:',
                                style: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: palette.textPrimary,
                                ),
                              ),
                              Text(
                                'S/ $amount',
                                style: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: palette.brandRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Selecciona el método de pago:',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                key: const Key('gateway-option-yape'),
                                onTap: () => setState(() => selectedGateway = 0),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedGateway == 0
                                        ? const Color(0xFF742284).withValues(alpha: 0.15)
                                        : palette.surfaceTint,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedGateway == 0
                                          ? const Color(0xFF742284)
                                          : palette.border,
                                      width: selectedGateway == 0 ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      const Icon(LucideIcons.smartphone, color: Color(0xFF742284), size: 20),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Yape',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF742284),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                key: const Key('gateway-option-plin'),
                                onTap: () => setState(() => selectedGateway = 1),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedGateway == 1
                                        ? const Color(0xFF00B4D8).withValues(alpha: 0.15)
                                        : palette.surfaceTint,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedGateway == 1
                                          ? const Color(0xFF00B4D8)
                                          : palette.border,
                                      width: selectedGateway == 1 ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      const Icon(LucideIcons.qrCode, color: Color(0xFF00B4D8), size: 20),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Plin',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF00B4D8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                key: const Key('gateway-option-card'),
                                onTap: () => setState(() => selectedGateway = 2),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedGateway == 2
                                        ? palette.brandRed.withValues(alpha: 0.15)
                                        : palette.surfaceTint,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedGateway == 2
                                          ? palette.brandRed
                                          : palette.border,
                                      width: selectedGateway == 2 ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Icon(LucideIcons.creditCard, color: palette.brandRed, size: 20),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tarjeta',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: palette.brandRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (selectedGateway == 0 || selectedGateway == 1) ...<Widget>[
                          Text(
                            selectedGateway == 0
                                ? 'Yapear al número de KAIRO:'
                                : 'Transferir por Plin al número:',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 12,
                              color: palette.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: palette.surfaceTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(LucideIcons.phone, size: 16),
                                const SizedBox(width: 6),
                                const Text(
                                  '999 888 777 (KAIRO)',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            key: const Key('gateway-phone-input'),
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Tu número de celular remitente',
                              hintText: '987 654 321',
                              prefixIcon: const Icon(LucideIcons.phone, size: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ] else ...<Widget>[
                          TextField(
                            key: const Key('gateway-card-input'),
                            controller: cardController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Número de tarjeta',
                              hintText: '4557 0000 0000 0000',
                              prefixIcon: const Icon(LucideIcons.creditCard, size: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: expiryController,
                                  decoration: InputDecoration(
                                    labelText: 'MM/AA',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: cvvController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'CVV',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  isPaid ? 'Aceptar' : 'Cancelar',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: palette.textSecondary,
                  ),
                ),
              ),
              if (!isPaid)
                ElevatedButton(
                  key: const Key('gateway-confirm-button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.brandRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    setState(() {
                      isPaid = true;
                    });
                  },
                  child: const Text('Confirmar pago'),
                ),
            ],
          );
        },
      );
    },
  );
}

class _PaymentFrame extends StatelessWidget {
  const _PaymentFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: palette.background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(body: child),
    );
  }
}
