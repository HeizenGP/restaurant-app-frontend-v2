import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/components/admin_badge.dart';
import '../../../core/design_system/components/admin_button.dart';
import '../../../core/design_system/components/admin_card.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../../../core/layout/breakpoints.dart';
import '../../orders/application/order_controller.dart';
import '../../orders/domain/order_models.dart';
import '../application/kitchen_controller.dart';
import '../domain/kitchen_models.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({
    required this.kitchenController,
    this.orderController,
    super.key,
  });

  final KitchenController kitchenController;
  final OrderController? orderController;

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.kitchenController.loadTickets();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        widget.kitchenController.loadTickets(silent: true);
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
      listenable: widget.kitchenController,
      builder: (BuildContext context, _) {
        final List<KitchenTicket> received =
            widget.kitchenController.receivedTickets;
        final List<KitchenTicket> preparing =
            widget.kitchenController.preparingTickets;
        final List<KitchenTicket> ready = widget.kitchenController.readyTickets;
        final bool isLoading = widget.kitchenController.isLoading;
        final String? error = widget.kitchenController.errorMessage;

        return Padding(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Monitor de Cocina (KDS)',
                          style: AsiaTypography.displayMedium.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${received.length} en espera • ${preparing.length} en preparación • ${ready.length} listos',
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminButton(
                    label: 'Actualizar',
                    icon: LucideIcons.refreshCw,
                    variant: AdminButtonVariant.secondary,
                    size: AdminButtonSize.sm,
                    isLoading: isLoading,
                    onPressed: () => widget.kitchenController.loadTickets(),
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.md),

              // Modality filters
              AdminCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AsiaSpacing.md,
                  vertical: AsiaSpacing.sm,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _buildModalityChip('Todos', null),
                      _buildModalityChip('Mesa / Salón', 'LOCAL'),
                      _buildModalityChip('Para Llevar', 'PICKUP'),
                      _buildModalityChip('Delivery', 'DELIVERY'),
                    ],
                  ),
                ),
              ),
              if (error != null) ...<Widget>[
                const SizedBox(height: AsiaSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AsiaSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.error.withValues(alpha: 0.1),
                    borderRadius: AsiaRadii.md,
                    border: Border.all(
                      color: tokens.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.alertTriangle, color: tokens.error, size: 18),
                      const SizedBox(width: AsiaSpacing.sm),
                      Expanded(
                        child: Text(
                          error,
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AsiaSpacing.lg),

              // Board
              Expanded(
                child: isLoading && widget.kitchenController.tickets.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: _buildColumn(
                              context: context,
                              title: 'En espera',
                              icon: LucideIcons.clock,
                              accentColor: AsiaPalette.amber,
                              tickets: received,
                              emptyLabel: 'Sin comandas en espera',
                            ),
                          ),
                          const SizedBox(width: AsiaSpacing.md),
                          Expanded(
                            child: _buildColumn(
                              context: context,
                              title: 'En preparación',
                              icon: LucideIcons.flame,
                              accentColor: AsiaPalette.blue,
                              tickets: preparing,
                              emptyLabel: 'Nada cocinándose ahora',
                            ),
                          ),
                          const SizedBox(width: AsiaSpacing.md),
                          Expanded(
                            child: _buildColumn(
                              context: context,
                              title: 'Listo',
                              icon: LucideIcons.checkCircle2,
                              accentColor: AsiaPalette.jade,
                              tickets: ready,
                              emptyLabel: 'Sin pedidos listos',
                            ),
                          ),
                        ],
                      )
                    : DefaultTabController(
                        length: 3,
                        child: Column(
                          children: <Widget>[
                            TabBar(
                              labelColor: tokens.brandCrimson,
                              unselectedLabelColor: tokens.textSecondary,
                              indicatorColor: tokens.brandCrimson,
                              tabs: <Tab>[
                                Tab(text: 'En espera (${received.length})'),
                                Tab(
                                  text: 'En preparación (${preparing.length})',
                                ),
                                Tab(text: 'Listo (${ready.length})'),
                              ],
                            ),
                            const SizedBox(height: AsiaSpacing.md),
                            Expanded(
                              child: TabBarView(
                                children: <Widget>[
                                  _buildTicketList(
                                    context,
                                    received,
                                    'Sin comandas en espera',
                                  ),
                                  _buildTicketList(
                                    context,
                                    preparing,
                                    'Nada cocinándose ahora',
                                  ),
                                  _buildTicketList(
                                    context,
                                    ready,
                                    'Sin pedidos listos',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalityChip(String label, String? value) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isSelected = widget.kitchenController.modalityFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => widget.kitchenController.setModalityFilter(value),
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

  Widget _buildColumn({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<KitchenTicket> tickets,
    required String emptyLabel,
  }) {
    final AsiaThemeTokens tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.cardElevated.withValues(alpha: 0.45),
        borderRadius: AsiaRadii.lg,
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: <Widget>[
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AsiaSpacing.md,
              vertical: AsiaSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: tokens.border)),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AsiaTypography.headingMedium.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: AsiaRadii.pill,
                  ),
                  child: Text(
                    '${tickets.length}',
                    style: AsiaTypography.caption.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTicketList(context, tickets, emptyLabel)),
        ],
      ),
    );
  }

  Widget _buildTicketList(
    BuildContext context,
    List<KitchenTicket> tickets,
    String emptyLabel,
  ) {
    final AsiaThemeTokens tokens = context.tokens;
    if (tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Text(
            emptyLabel,
            style: AsiaTypography.caption.copyWith(color: tokens.textTertiary),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AsiaSpacing.md),
      itemCount: tickets.length,
      separatorBuilder: (_, _) => const SizedBox(height: AsiaSpacing.md),
      itemBuilder: (BuildContext context, int index) =>
          _buildTicketCard(context, tickets[index]),
    );
  }

  Widget _buildTicketCard(BuildContext context, KitchenTicket ticket) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isUpdating =
        widget.kitchenController.updatingTicketId == ticket.id;
    final String shortOrder = ticket.orderId.length >= 8
        ? ticket.orderId.substring(0, 8).toUpperCase()
        : ticket.orderId.toUpperCase();
    final Duration elapsed = DateTime.now().difference(ticket.createdAt);
    final String elapsedLabel = elapsed.inMinutes < 1
        ? 'Ahora'
        : '${elapsed.inMinutes} min';

    final Color borderColor = switch (ticket.status) {
      KitchenTicketStatus.received => AsiaPalette.amber.withValues(alpha: 0.5),
      KitchenTicketStatus.preparing => AsiaPalette.blue.withValues(alpha: 0.5),
      KitchenTicketStatus.ready => AsiaPalette.jade.withValues(alpha: 0.5),
    };

    return Container(
      padding: const EdgeInsets.all(AsiaSpacing.md),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AsiaRadii.md,
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header
          Row(
            children: <Widget>[
              if (ticket.tableCode != null && ticket.tableCode!.isNotEmpty) ...<Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.brandCrimson.withValues(alpha: 0.12),
                    borderRadius: AsiaRadii.sm,
                    border: Border.all(
                      color: tokens.brandCrimson.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        LucideIcons.armchair,
                        size: 13,
                        color: tokens.brandCrimson,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.tableCode!,
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.brandCrimson,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...<Widget>[
                AdminBadge(
                  label: ticket.modalityLabel,
                  variant: AdminBadgeVariant.info,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  '#$shortOrder',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(LucideIcons.clock, size: 12, color: tokens.textTertiary),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('HH:mm').format(ticket.createdAt)} ($elapsedLabel)',
                style: AsiaTypography.caption.copyWith(
                  color: tokens.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.sm),
          Divider(color: tokens.borderSubtle, height: 1),
          const SizedBox(height: AsiaSpacing.sm),

          // Items
          ...ticket.lines.map((KitchenTicketLine line) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.brandCrimson.withValues(alpha: 0.12),
                      borderRadius: AsiaRadii.sm,
                    ),
                    child: Text(
                      '${line.quantity}x',
                      style: AsiaTypography.caption.copyWith(
                        color: tokens.brandCrimson,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line.productName,
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AsiaSpacing.md),

          // Action button based on status
          if (ticket.isReceived)
            AdminButton(
              label: 'Iniciar preparación',
              icon: LucideIcons.flame,
              variant: AdminButtonVariant.gold,
              size: AdminButtonSize.sm,
              isFullWidth: true,
              isLoading: isUpdating,
              onPressed: () async {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );
                final bool ok = await widget.kitchenController.startTicket(
                  ticket.id,
                );
                if (!ok && mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.kitchenController.errorMessage ??
                            'No se pudo iniciar la preparación.',
                      ),
                      backgroundColor: tokens.error,
                    ),
                  );
                }
              },
            )
          else if (ticket.isPreparing)
            AdminButton(
              label: 'Marcar como listo',
              icon: LucideIcons.checkCircle2,
              variant: AdminButtonVariant.primary,
              size: AdminButtonSize.sm,
              isFullWidth: true,
              isLoading: isUpdating,
              onPressed: () async {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );
                final bool ok = await widget.kitchenController.markReady(
                  ticket.id,
                );
                if (ok && mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Comanda ${ticket.tableCode ?? '#$shortOrder'} marcada como LISTA.',
                      ),
                      backgroundColor: AsiaPalette.jade,
                    ),
                  );
                } else if (!ok && mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.kitchenController.errorMessage ??
                            'No se pudo marcar como listo.',
                      ),
                      backgroundColor: tokens.error,
                    ),
                  );
                }
              },
            )
          else if (ticket.isReady) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AsiaPalette.jade.withValues(alpha: 0.12),
                borderRadius: AsiaRadii.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    LucideIcons.checkCheck,
                    size: 14,
                    color: AsiaPalette.jade,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Listo para servir / entregar',
                    style: AsiaTypography.caption.copyWith(
                      color: AsiaPalette.jade,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.orderController != null) ...<Widget>[
              const SizedBox(height: AsiaSpacing.xs),
              AdminButton(
                label: ticket.modality.toUpperCase() == 'LOCAL'
                    ? 'Marcar como Servido'
                    : (ticket.modality.toUpperCase() == 'DELIVERY'
                          ? 'Marcar Entregado'
                          : 'Marcar Recogido'),
                icon: LucideIcons.send,
                variant: AdminButtonVariant.secondary,
                size: AdminButtonSize.sm,
                isFullWidth: true,
                onPressed: () async {
                  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                    context,
                  );
                  final OrderModality mod = OrderModality.fromString(
                    ticket.modality,
                  );
                  final bool ok = await widget.orderController!.fulfillOrder(
                    ticket.orderId,
                    mod,
                  );
                  if (ok && mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Pedido ${ticket.tableCode ?? '#$shortOrder'} marcado como servido. Ya puede cobrarse en caja.',
                        ),
                        backgroundColor: AsiaPalette.jade,
                      ),
                    );
                    await widget.kitchenController.loadTickets(silent: true);
                  } else if (!ok && mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.orderController!.errorMessage ??
                              'No se pudo marcar como servido.',
                        ),
                        backgroundColor: tokens.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}
