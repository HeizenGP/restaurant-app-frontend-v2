import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../choose_fulfillment/domain/fulfillment_models.dart';
import '../../submit_order/domain/order_models.dart';
import '../application/order_tracking_controller.dart';
import '../domain/order_tracking_models.dart';

class OrderDetailTrackingPage extends StatefulWidget {
  const OrderDetailTrackingPage({
    required this.themeModeController,
    required this.controller,
    required this.orderId,
    required this.onBackToOrders,
    this.onViewAdvance,
    this.onViewPayments,
    this.showBackButton,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    super.key,
  });

  final ThemeModeController themeModeController;
  final OrderTrackingController controller;
  final String orderId;
  final VoidCallback onBackToOrders;
  final ValueChanged<String>? onViewAdvance;
  final ValueChanged<String>? onViewPayments;
  final bool? showBackButton;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;

  @override
  State<OrderDetailTrackingPage> createState() =>
      _OrderDetailTrackingPageState();
}

class _OrderDetailTrackingPageState extends State<OrderDetailTrackingPage> {
  @override
  void initState() {
    super.initState();
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(covariant OrderDetailTrackingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId ||
        oldWidget.controller != widget.controller) {
      _scheduleLoad();
    }
  }

  void _scheduleLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.controller.load(widget.orderId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final OrderTrackingState state = widget.controller.state;
        if (state.phase == OrderTrackingPhase.loading &&
            (state.order == null || state.tracking == null)) {
          return _TrackingFrame(
            child: ChifaPageScaffold(
              pageKey: const Key('page-order-tracking-loading'),
              title: 'Detalle y seguimiento',
              subtitle: 'Estado en tiempo real de tu pedido.',
              themeModeController: widget.themeModeController,
              onBackPressed: widget.onBackToOrders,
              showBackButton: widget.showBackButton,
              child: const ChifaStateView(
                key: Key('tracking-loading-state'),
                kind: ChifaStateKind.loading,
                title: 'Consultando seguimiento',
                message: 'Espera un momento.',
              ),
            ),
          );
        }

        if (state.phase == OrderTrackingPhase.failure &&
            (state.order == null || state.tracking == null)) {
          return _TrackingFrame(
            child: ChifaPageScaffold(
              pageKey: const Key('page-order-tracking-error'),
              title: 'Detalle y seguimiento',
              subtitle: 'Estado en tiempo real de tu pedido.',
              themeModeController: widget.themeModeController,
              onBackPressed: widget.onBackToOrders,
              showBackButton: widget.showBackButton,
              child: ChifaStateView(
                key: const Key('tracking-error-state'),
                kind: ChifaStateKind.error,
                title: 'No pudimos consultar',
                message: state.failure?.message ?? 'Inténtalo nuevamente.',
                actionLabel: state.canRetry ? 'Reintentar' : null,
                onAction: state.canRetry
                    ? () {
                        unawaited(widget.controller.retry());
                      }
                    : null,
              ),
            ),
          );
        }

        final OrderSnapshot? order = state.order;
        final OrderTrackingSnapshot? tracking = state.tracking;
        if (order == null || tracking == null) {
          return _TrackingFrame(
            child: ChifaPageScaffold(
              pageKey: const Key('page-order-tracking-empty'),
              title: 'Detalle y seguimiento',
              subtitle: 'Estado en tiempo real de tu pedido.',
              themeModeController: widget.themeModeController,
              onBackPressed: widget.onBackToOrders,
              showBackButton: widget.showBackButton,
              child: const ChifaStateView(
                key: Key('tracking-empty-state'),
                kind: ChifaStateKind.empty,
                title: 'Sin datos de seguimiento',
                message: 'No se encontraron datos para este pedido.',
              ),
            ),
          );
        }

        return _TrackingContentPage(
          themeModeController: widget.themeModeController,
          controller: widget.controller,
          order: order,
          tracking: tracking,
          onBackToOrders: widget.onBackToOrders,
          showBackButton: widget.showBackButton,
          onCartPressed: widget.onCartPressed,
          cartItemCount: widget.cartItemCount,
          initials: widget.initials,
          avatarPath: widget.avatarPath,
          onAvatarPressed: widget.onAvatarPressed,
          onViewAdvance: widget.onViewAdvance != null
              ? () => widget.onViewAdvance!(order.id)
              : null,
          onViewPayments: widget.onViewPayments != null
              ? () => widget.onViewPayments!(order.id)
              : null,
        );
      },
    );
  }
}

class _TrackingContentPage extends StatelessWidget {
  const _TrackingContentPage({
    required this.themeModeController,
    required this.controller,
    required this.order,
    required this.tracking,
    required this.onBackToOrders,
    this.showBackButton,
    this.onViewAdvance,
    this.onViewPayments,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
  });

  final ThemeModeController themeModeController;
  final OrderTrackingController controller;
  final OrderSnapshot order;
  final OrderTrackingSnapshot tracking;
  final VoidCallback onBackToOrders;
  final bool? showBackButton;
  final VoidCallback? onViewAdvance;
  final VoidCallback? onViewPayments;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool showAdvance =
        tracking.modality != FulfillmentMode.local && onViewAdvance != null;
    final OrderTrackingState state = controller.state;
    final bool isCancelled =
        state.isCancellationRequested || order.status == 'CANCELLED';
    final bool canCancel = !isCancelled &&
        order.status != 'CLOSED' &&
        order.status != 'REJECTED' &&
        order.status != 'CANCELLED';

    return _TrackingFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-order-tracking'),
        title: 'Detalle y seguimiento',
        subtitle: 'Estado en tiempo real de tu pedido.',
        contentGap: 14,
        themeModeController: themeModeController,
        onBackPressed: onBackToOrders,
        showBackButton: showBackButton,
        onCartPressed: onCartPressed,
        cartItemCount: cartItemCount,
        initials: initials,
        avatarPath: avatarPath,
        onAvatarPressed: onAvatarPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Cancellation banner if requested
            if (isCancelled) ...<Widget>[
              ChifaCard(
                key: const Key('tracking-cancellation-card'),
                icon: LucideIcons.circleAlert,
                iconColor: palette.brandRed,
                title: 'Cancelación solicitada',
                subtitle:
                    'Motivo: ${state.cancellationObservation ?? "Solicitud registrada"}${state.cancellationRequestedAt != null ? "\nFecha: ${_formatDate(state.cancellationRequestedAt)}" : ""}',
                subtitleMaxLines: 4,
                minimumHeight: 68,
              ),
              const SizedBox(height: 10),
            ],
            ChifaCard(
              key: const Key('tracking-stage-card'),
              icon: LucideIcons.clock3,
              iconColor: _figmaIconColor(context),
              title: 'Etapa: ${tracking.stage}',
              subtitle: _stageDescription(tracking),
              minimumHeight: 68,
            ),
            const SizedBox(height: 10),
            ChifaCard(
              key: const Key('tracking-modality-card'),
              icon: _modalityIcon(order.modality),
              iconColor: _figmaIconColor(context),
              title: _modalityTitle(order.modality),
              subtitle: 'Pedido #${_shortId(order.id)} · ${_modalitySubtitle(order)}',
              minimumHeight: 68,
            ),
            const SizedBox(height: 10),
            ChifaCard(
              key: const Key('tracking-products-card'),
              icon: LucideIcons.utensilsCrossed,
              iconColor: _figmaIconColor(context),
              title: 'Productos (${order.lines.length})',
              subtitle: order.lines
                  .map(
                    (OrderLineSnapshot l) =>
                        '${l.quantity}x ${l.productName} · S/ ${l.unitPrice}',
                  )
                  .join('\n'),
              subtitleMaxLines: 12,
              minimumHeight: 76,
              onTap: () => _showOrderDetailsDialog(context, order),
            ),
            const SizedBox(height: 10),
            ChifaCard(
              key: const Key('tracking-payment-card'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Estado de pago: ${tracking.paymentStatus}',
              subtitle:
                  'Total: S/ ${tracking.totalAmount} · Pagado: S/ ${tracking.paidAmount} · Saldo: S/ ${tracking.balance}',
              minimumHeight: 68,
            ),
            const SizedBox(height: 16),
            if (showAdvance) ...<Widget>[
              ChifaButton(
                key: const Key('tracking-advance-button'),
                label: 'Ver anticipo (50 %)',
                height: 46,
                borderRadius: 14,
                onPressed: onViewAdvance,
              ),
              const SizedBox(height: 8),
            ],
            if (onViewPayments != null) ...<Widget>[
              ChifaButton(
                key: const Key('tracking-payments-button'),
                label: 'Ver estado de pagos',
                height: 46,
                borderRadius: 14,
                onPressed: onViewPayments,
              ),
              const SizedBox(height: 8),
            ],
            if (canCancel) ...<Widget>[
              ChifaButton(
                key: const Key('tracking-cancel-button'),
                label: 'Solicitar cancelación',
                height: 46,
                borderRadius: 14,
                onPressed: () => _showCancellationDialog(context, controller),
              ),
              const SizedBox(height: 8),
            ],
            ChifaButton(
              key: const Key('tracking-back-button'),
              label: 'Volver a mis pedidos',
              height: 48,
              borderRadius: 14,
              onPressed: onBackToOrders,
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, OrderSnapshot order) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: const Key('order-breakdown-dialog'),
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: palette.border),
          ),
          title: Row(
            children: <Widget>[
              Icon(
                LucideIcons.receipt,
                size: 20,
                color:
                    isDark ? const Color(0xFFE2BC75) : const Color(0xFF922832),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detalle del pedido',
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'ID: #${order.id}',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
                Text(
                  'Fecha: ${_formatDate(order.createdAt)}',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    color: palette.textSecondary,
                  ),
                ),
                Text(
                  'Modalidad: ${_modalityTitle(order.modality)}',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: palette.border),
                const SizedBox(height: 10),
                for (final OrderLineSnapshot line in order.lines) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: palette.surfaceTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${line.quantity}x',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: palette.brandRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                line.productName,
                                style: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: palette.textPrimary,
                                ),
                              ),
                              Text(
                                'S/ ${line.unitPrice} c/u',
                                style: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 11,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'S/ ${_calculateSubtotal(line)}',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Divider(height: 1, color: palette.border),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Total a pagar',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      'S/ ${order.totalAmount}',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: palette.brandRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontWeight: FontWeight.w600,
                  color: palette.brandRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _calculateSubtotal(OrderLineSnapshot line) {
    final double? unit = double.tryParse(line.unitPrice);
    if (unit == null) return line.unitPrice;
    return (unit * line.quantity).toStringAsFixed(2);
  }

  void _showCancellationDialog(
    BuildContext context,
    OrderTrackingController controller,
  ) {
    final TextEditingController reasonController = TextEditingController();
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final AppPalette palette = context.appPalette;

            return AlertDialog(
              key: const Key('cancellation-dialog'),
              backgroundColor: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: palette.border),
              ),
              title: Row(
                children: <Widget>[
                  Icon(
                    LucideIcons.circleAlert,
                    color: palette.brandRed,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Solicitar cancelación',
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Indica el motivo u observación para solicitar la cancelación de tu pedido:',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('cancellation-reason-input'),
                      controller: reasonController,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 14,
                        color: palette.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ej. Error al ordenar, cambio de planes...',
                        hintStyle: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13,
                          color: palette.textSecondary.withValues(alpha: 0.6),
                        ),
                        errorText: errorText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: palette.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: palette.brandRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  key: const Key('cancellation-back-action'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Volver',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  key: const Key('cancellation-confirm-action'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.brandRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final String text = reasonController.text.trim();
                    if (text.isEmpty) {
                      setState(() {
                        errorText = 'Por favor ingresa una observación.';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    await controller.requestCancellation(reason: text);
                  },
                  child: const Text(
                    'Confirmar cancelación',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = dt.month.toString().padLeft(2, '0');
    final String year = dt.year.toString();
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _stageDescription(OrderTrackingSnapshot tracking) {
    final List<String> parts = <String>[
      'Estado: ${tracking.orderStatus}',
    ];
    if (tracking.kitchenStatus != null) {
      parts.add('Cocina: ${tracking.kitchenStatus}');
    }
    if (tracking.fulfillmentKind != null) {
      parts.add('Entrega: ${tracking.fulfillmentKind}');
    }
    return parts.join(' · ');
  }

  IconData _modalityIcon(FulfillmentMode modality) {
    return switch (modality) {
      FulfillmentMode.local => LucideIcons.store,
      FulfillmentMode.pickup => LucideIcons.packageCheck,
      FulfillmentMode.delivery => LucideIcons.mapPin,
    };
  }

  String _modalityTitle(FulfillmentMode modality) {
    return switch (modality) {
      FulfillmentMode.local => 'Consumo en local',
      FulfillmentMode.pickup => 'Para recojo',
      FulfillmentMode.delivery => 'Entrega a domicilio',
    };
  }

  String _modalitySubtitle(OrderSnapshot order) {
    return switch (order.modality) {
      FulfillmentMode.local =>
        order.tableId != null ? 'Mesa: ${order.tableId}' : 'Mesa en local',
      FulfillmentMode.pickup =>
        order.contactName != null
            ? 'Contacto: ${order.contactName}'
            : 'Recojo en restaurante',
      FulfillmentMode.delivery =>
        order.deliveryAddress != null
            ? 'Dirección: ${order.deliveryAddress}'
            : 'Delivery registrado',
    };
  }

  Color _figmaIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE2BC75)
        : const Color(0xFF922832);
  }

  String _shortId(String id) {
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  }
}

class _TrackingFrame extends StatelessWidget {
  const _TrackingFrame({required this.child});

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
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(body: child),
    );
  }
}
