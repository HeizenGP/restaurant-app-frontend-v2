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
    super.key,
  });

  final ThemeModeController themeModeController;
  final OrderTrackingController controller;
  final String orderId;
  final VoidCallback onBackToOrders;
  final ValueChanged<String>? onViewAdvance;
  final ValueChanged<String>? onViewPayments;

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
          order: order,
          tracking: tracking,
          onBackToOrders: widget.onBackToOrders,
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
    required this.order,
    required this.tracking,
    required this.onBackToOrders,
    this.onViewAdvance,
    this.onViewPayments,
  });

  final ThemeModeController themeModeController;
  final OrderSnapshot order;
  final OrderTrackingSnapshot tracking;
  final VoidCallback onBackToOrders;
  final VoidCallback? onViewAdvance;
  final VoidCallback? onViewPayments;

  @override
  Widget build(BuildContext context) {
    final bool showAdvance =
        tracking.modality != FulfillmentMode.local && onViewAdvance != null;

    return _TrackingFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-order-tracking'),
        title: 'Detalle y seguimiento',
        subtitle: 'Estado en tiempo real de tu pedido.',
        contentGap: 24,
        themeModeController: themeModeController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChifaCard(
              key: const Key('tracking-stage-card'),
              icon: LucideIcons.clock3,
              iconColor: _figmaIconColor(context),
              title: 'Etapa: ${tracking.stage}',
              subtitle: _stageDescription(tracking),
              minimumHeight: 77,
            ),
            const SizedBox(height: 16),
            ChifaCard(
              key: const Key('tracking-modality-card'),
              icon: _modalityIcon(order.modality),
              iconColor: _figmaIconColor(context),
              title: _modalityTitle(order.modality),
              subtitle: _modalitySubtitle(order),
              minimumHeight: 77,
            ),
            const SizedBox(height: 16),
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
              minimumHeight: 90,
            ),
            const SizedBox(height: 16),
            ChifaCard(
              key: const Key('tracking-payment-card'),
              icon: LucideIcons.wallet,
              iconColor: _figmaIconColor(context),
              title: 'Estado de pago: ${tracking.paymentStatus}',
              subtitle:
                  'Total: S/ ${tracking.totalAmount} · Pagado: S/ ${tracking.paidAmount} · Saldo: S/ ${tracking.balance}',
              minimumHeight: 77,
            ),
            const SizedBox(height: 28),
            if (showAdvance) ...<Widget>[
              ChifaButton(
                key: const Key('tracking-advance-button'),
                label: 'Ver anticipo (50 %)',
                height: 50,
                borderRadius: 14,
                onPressed: onViewAdvance,
              ),
              const SizedBox(height: 12),
            ],
            if (onViewPayments != null) ...<Widget>[
              ChifaButton(
                key: const Key('tracking-payments-button'),
                label: 'Ver estado de pagos',
                height: 50,
                borderRadius: 14,
                onPressed: onViewPayments,
              ),
              const SizedBox(height: 12),
            ],
            ChifaButton(
              key: const Key('tracking-back-button'),
              label: 'Volver a mis pedidos',
              height: 54,
              borderRadius: 14,
              onPressed: onBackToOrders,
            ),
          ],
        ),
      ),
    );
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
