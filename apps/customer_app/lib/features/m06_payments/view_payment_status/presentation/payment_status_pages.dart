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
    super.key,
  });

  final ThemeModeController themeModeController;
  final PaymentStatusController controller;
  final String orderId;
  final VoidCallback onViewOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;

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
    super.key,
  });

  final ThemeModeController themeModeController;
  final AdvanceSummary summary;
  final VoidCallback onViewOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;

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
            ),
            const SizedBox(height: 75),
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
    super.key,
  });

  final ThemeModeController themeModeController;
  final PaymentStatusController controller;
  final String orderId;
  final VoidCallback onBackToOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;

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
    super.key,
  });

  final ThemeModeController themeModeController;
  final PaymentSummary summary;
  final VoidCallback onBackToOrder;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;

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
            const SizedBox(height: 48),
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
