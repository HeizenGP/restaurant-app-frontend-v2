import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../choose_fulfillment/domain/fulfillment_models.dart';
import '../../submit_order/domain/order_models.dart';
import '../application/order_history_controller.dart';
import '../application/order_tracking_controller.dart';
import '../domain/order_tracking_models.dart';

class OrdersHistoryPage extends StatefulWidget {
  const OrdersHistoryPage({
    required this.themeModeController,
    required this.controller,
    required this.onOpenOrderDetail,
    this.onBackPressed,
    this.showBackButton,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onNotificationPressed,
    this.tableLabel,
    super.key,
  });

  final ThemeModeController themeModeController;
  final OrderHistoryController controller;
  final ValueChanged<String> onOpenOrderDetail;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onNotificationPressed;
  final String? tableLabel;

  @override
  State<OrdersHistoryPage> createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.controller.loadOrders());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final OrderHistoryState state = widget.controller.state;
        return ChifaPageScaffold(
          pageKey: const Key('page-pedidos'),
          title: 'Mis pedidos',
          subtitle: 'Solicitudes e historial de esta cuenta.',
          contentGap: 13,
          themeModeController: widget.themeModeController,
          onBackPressed: widget.onBackPressed,
          showBackButton: widget.showBackButton,
          onCartPressed: widget.onCartPressed,
          cartItemCount: widget.cartItemCount,
          initials: widget.initials,
          avatarPath: widget.avatarPath,
          onAvatarPressed: widget.onAvatarPressed,
          onNotificationPressed: widget.onNotificationPressed,
          tableLabel: widget.tableLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _OrderFilterChips(
                selectedFilter: state.selectedFilter,
                onFilterChanged: widget.controller.setFilter,
              ),
              const SizedBox(height: 24),
              _buildContent(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, OrderHistoryState state) {
    if (state.phase == OrderHistoryPhase.loading && state.orders.isEmpty) {
      return const ChifaStateView(
        key: Key('orders-loading-state'),
        kind: ChifaStateKind.loading,
        title: 'Cargando pedidos',
        message: 'Espera un momento.',
      );
    }

    if (state.phase == OrderHistoryPhase.failure && state.orders.isEmpty) {
      return ChifaStateView(
        key: const Key('orders-error-state'),
        kind: ChifaStateKind.error,
        title: 'No pudimos cargar pedidos',
        message: state.failure?.message ?? 'Inténtalo nuevamente.',
        actionLabel: state.canRetry ? 'Reintentar' : null,
        onAction: state.canRetry
            ? () {
                unawaited(widget.controller.retry());
              }
            : null,
      );
    }

    final List<OrderSnapshot> filtered = state.filteredOrders;
    if (filtered.isEmpty) {
      return const ChifaStateView(
        key: Key('orders-empty-state'),
        kind: ChifaStateKind.empty,
        title: 'Sin pedidos',
        message: 'Aún no hay pedidos reales para mostrar',
      );
    }

    final Widget chevron = Icon(
      LucideIcons.chevronRight,
      color: context.appPalette.cardTextSecondary,
      size: 17,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < filtered.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 10),
          GestureDetector(
            onTap: () => widget.onOpenOrderDetail(filtered[i].id),
            child: ChifaCard(
              key: ValueKey<String>('order-card-${filtered[i].id}'),
              icon: LucideIcons.receiptText,
              iconColor: _figmaIconColor(context),
              title: _orderTitle(filtered[i]),
              subtitle: _orderSubtitle(filtered[i]),
              minimumHeight: 119,
              trailing: chevron,
            ),
          ),
        ],
      ],
    );
  }

  String _orderTitle(OrderSnapshot order) {
    final String shortId = order.id.length >= 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();
    if (OrderTrackingController.isCancellationRequestedFor(order.id)) {
      return 'Pedido #$shortId · cancelado/solicitado';
    }
    final String statusLabel = switch (order.status) {
      'REQUESTED' => 'reciente',
      'APPROVED' => 'aprobado',
      'CONFIRMED' => 'confirmado',
      'REJECTED' => 'rechazado',
      'CLOSED' => 'cerrado',
      _ => order.status.toLowerCase(),
    };
    return 'Pedido #$shortId · $statusLabel';
  }

  String _orderSubtitle(OrderSnapshot order) {
    if (OrderTrackingController.isCancellationRequestedFor(order.id)) {
      final String? obs =
          OrderTrackingController.cancellationObservationFor(order.id);
      final String obsText = obs != null ? ' · Obs: $obs' : '';
      return 'CANCELACIÓN SOLICITADA$obsText\n${_formatModality(order.modality)} · S/ ${order.totalAmount}';
    }
    final String statusDesc = switch (order.status) {
      'REQUESTED' => 'REQUESTED · pendiente de aprobación',
      'APPROVED' => 'APPROVED · en preparación',
      'CONFIRMED' => 'CONFIRMED · ver detalle',
      'REJECTED' => 'REJECTED · consultar motivo/estado',
      'CLOSED' => 'CLOSED · pedido finalizado',
      _ => '${order.status} · ver detalle',
    };
    return '$statusDesc\n${_formatModality(order.modality)} · S/ ${order.totalAmount}';
  }

  String _formatModality(FulfillmentMode modality) {
    return switch (modality) {
      FulfillmentMode.local => 'Consumo en local',
      FulfillmentMode.pickup => 'Para recojo',
      FulfillmentMode.delivery => 'Delivery',
    };
  }

  Color _figmaIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE2BC75)
        : const Color(0xFF922832);
  }
}

class _OrderFilterChips extends StatelessWidget {
  const _OrderFilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final OrderHistoryFilter selectedFilter;
  final ValueChanged<OrderHistoryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Row(
        children: <Widget>[
          ChifaChip(
            key: const Key('filter-all'),
            label: 'Todos',
            width: 98,
            onPressed: () => onFilterChanged(OrderHistoryFilter.all),
          ),
          const SizedBox(width: 14),
          ChifaChip(
            key: const Key('filter-pending'),
            label: 'Pendientes',
            width: 113,
            onPressed: () => onFilterChanged(OrderHistoryFilter.pending),
          ),
          const SizedBox(width: 10),
          ChifaChip(
            key: const Key('filter-confirmed'),
            label: 'Confirmados',
            width: 107,
            onPressed: () => onFilterChanged(OrderHistoryFilter.confirmed),
          ),
        ],
      ),
    );
  }
}
