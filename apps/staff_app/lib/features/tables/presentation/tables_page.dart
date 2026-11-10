import 'dart:async';

import 'package:flutter/material.dart';
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
import '../../auth/application/auth_controller.dart';
import '../../payments/application/payment_controller.dart';
import '../../payments/domain/payment_models.dart';
import '../application/table_controller.dart';
import '../domain/table_models.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({
    required this.tableController,
    required this.paymentController,
    this.authController,
    super.key,
  });

  final TableController tableController;
  final PaymentController paymentController;
  final AuthController? authController;

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.tableController.loadTables();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        widget.tableController.loadTables(silent: true);
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

    return ListenableBuilder(
      listenable: widget.tableController,
      builder: (BuildContext context, _) {
        final List<RestaurantTable> tables =
            widget.tableController.filteredTables;
        final bool isLoading = widget.tableController.isLoading;
        final int occupied = widget.tableController.occupiedCount;
        final int available = widget.tableController.availableCount;
        final List<String> areas = widget.tableController.availableAreas;

        return SingleChildScrollView(
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
                        'Administración de Mesas',
                        style: AsiaTypography.displayMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$occupied ocupadas • $available disponibles para comensales',
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AdminButton(
                        label: 'Nueva Mesa',
                        icon: LucideIcons.plus,
                        size: AdminButtonSize.sm,
                        onPressed: () => _openCreateTableDialog(context),
                      ),
                      const SizedBox(width: AsiaSpacing.md),
                      AdminButton(
                        label: 'Actualizar',
                        icon: LucideIcons.refreshCw,
                        variant: AdminButtonVariant.secondary,
                        size: AdminButtonSize.sm,
                        isLoading: isLoading,
                        onPressed: () => widget.tableController.loadTables(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Area Filter Tabs
              if (areas.isNotEmpty) ...<Widget>[
                AdminCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _buildAreaChip(
                          context,
                          label:
                              'Todas las áreas (${widget.tableController.tables.length})',
                          isSelected:
                              widget.tableController.selectedArea == null,
                          onTap: () => widget.tableController.selectArea(null),
                        ),
                        ...areas.map((String area) {
                          final bool isSelected =
                              widget.tableController.selectedArea == area;
                          final int count = widget.tableController.tables
                              .where((RestaurantTable t) => t.area == area)
                              .length;
                          return _buildAreaChip(
                            context,
                            label: '$area ($count)',
                            isSelected: isSelected,
                            onTap: () =>
                                widget.tableController.selectArea(area),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AsiaSpacing.xl),
              ],

              // Table Grid
              if (isLoading && tables.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (tables.isEmpty)
                AdminCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            LucideIcons.armchair,
                            size: 48,
                            color: tokens.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay mesas en esta área',
                            style: AsiaTypography.headingMedium.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double width = constraints.maxWidth;
                    final int crossAxisCount = width > 1200
                        ? 4
                        : (width > 900 ? 3 : (width > 600 ? 2 : 1));

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AsiaSpacing.lg,
                        mainAxisSpacing: AsiaSpacing.lg,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _buildTableCard(context, tables[index]);
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAreaChip(
    BuildContext context, {
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

  Widget _buildTableCard(BuildContext context, RestaurantTable table) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool occupied = table.isOccupied;

    return Container(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AsiaRadii.lg,
        border: Border.all(
          color: occupied
              ? tokens.brandGold.withValues(alpha: 0.5)
              : tokens.border,
          width: occupied ? 1.5 : 1.0,
        ),
        boxShadow: occupied
            ? <BoxShadow>[
                BoxShadow(
                  color: tokens.brandGold.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(AsiaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: occupied
                      ? tokens.brandGold.withValues(alpha: 0.15)
                      : tokens.cardElevated,
                  borderRadius: AsiaRadii.sm,
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.armchair,
                  size: 18,
                  color: occupied ? tokens.brandGold : tokens.textSecondary,
                ),
              ),
              AdminBadge(
                label: occupied ? 'OCUPADA' : 'DISPONIBLE',
                variant: occupied
                    ? AdminBadgeVariant.warning
                    : AdminBadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.md),
          Text(
            table.code,
            style: AsiaTypography.displaySmall.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            table.area,
            style: AsiaTypography.caption.copyWith(color: tokens.textTertiary),
          ),
          const Spacer(),
          Divider(color: tokens.borderSubtle, height: 1),
          const SizedBox(height: AsiaSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                occupied ? 'En servicio' : 'Lista para asignar',
                style: AsiaTypography.caption.copyWith(
                  color: occupied ? tokens.brandGold : tokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (occupied) ...<Widget>[
                Wrap(
                  spacing: AsiaSpacing.xs,
                  children: <Widget>[
                    AdminButton(
                      label: 'Liberar',
                      icon: LucideIcons.logOut,
                      variant: AdminButtonVariant.secondary,
                      size: AdminButtonSize.sm,
                      onPressed: () async {
                        final ScaffoldMessengerState messenger =
                            ScaffoldMessenger.of(context);
                        final bool ok = await widget.tableController
                            .toggleOccupancy(table.id, false);
                        if (!ok && context.mounted) {
                          final String msg =
                              widget.tableController.errorMessage ??
                              'No se pudo liberar la mesa.';
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              backgroundColor: tokens.error,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        } else if (ok && context.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Mesa ${table.code} liberada con éxito',
                              ),
                              backgroundColor: AsiaPalette.jade,
                            ),
                          );
                        }
                      },
                    ),
                    AdminButton(
                      label: 'Cobrar mesa',
                      icon: LucideIcons.walletCards,
                      variant: AdminButtonVariant.primary,
                      size: AdminButtonSize.sm,
                      onPressed: () => _openChargeTableDialog(context, table),
                    ),
                  ],
                ),
              ] else ...<Widget>[
                AdminButton(
                  label: 'Ocupar',
                  icon: LucideIcons.circleCheck,
                  variant: AdminButtonVariant.secondary,
                  size: AdminButtonSize.sm,
                  onPressed: () async {
                    final ScaffoldMessengerState messenger =
                        ScaffoldMessenger.of(context);
                    final bool ok = await widget.tableController
                        .toggleOccupancy(table.id, true);
                    if (!ok && context.mounted) {
                      final String msg =
                          widget.tableController.errorMessage ??
                          'No se pudo ocupar la mesa.';
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: tokens.error,
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showOpenRegisterPrompt(BuildContext context, RestaurantTable table) {
    final TextEditingController amountCtrl = TextEditingController(
      text: '100.00',
    );
    final TextEditingController cashierCtrl = TextEditingController(
      text:
          widget.authController?.currentUser?.displayName ?? 'Cajero Principal',
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AdminDialog(
        title: 'Caja Cerrada - Apertura Requerida',
        subtitle:
            'Para cobrar en la mesa ${table.code}, debes abrir el turno de caja primero',
        maxWidth: 480,
        confirmLabel: 'Abrir Caja y Cobrar',
        onCancel: () => Navigator.of(dialogContext).pop(),
        onConfirm: () async {
          if (formKey.currentState?.validate() ?? false) {
            final double initial = double.parse(amountCtrl.text.trim());
            widget.paymentController.openCashRegister(
              initialAmount: initial,
              userName: cashierCtrl.text.trim(),
            );
            Navigator.of(dialogContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Caja abierta exitosamente con S/ ${initial.toStringAsFixed(2)}',
                ),
                backgroundColor: AsiaPalette.jade,
              ),
            );
            // Now proceed to open charge table dialog
            await _openChargeTableDialog(context, table);
          }
        },
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AdminTextField(
                controller: cashierCtrl,
                label: 'Responsable de Caja',
                prefixIcon: LucideIcons.user,
                validator: (String? val) =>
                    val == null || val.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: AsiaSpacing.md),
              AdminTextField(
                controller: amountCtrl,
                label: 'Fondo Inicial en Efectivo (S/)',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: LucideIcons.wallet,
                validator: (String? val) {
                  final double? p = double.tryParse(val?.trim() ?? '');
                  return (p == null || p < 0)
                      ? 'Ingresa un monto válido'
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openChargeTableDialog(
    BuildContext context,
    RestaurantTable table,
  ) async {
    // Check if cash register is open first
    if (!widget.paymentController.isCashRegisterOpen) {
      _showOpenRegisterPrompt(context, table);
      return;
    }

    final AsiaThemeTokens tokens = context.tokens;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final TableAccountSummary? account = await widget.paymentController
        .loadTableAccount(table.id);
    if (!context.mounted) return;
    if (account == null) {
      final String raw = widget.paymentController.errorMessage ?? '';
      final String msg =
          (raw.contains('not found') ||
              raw.contains('No se encontró') ||
              raw.contains('404'))
          ? 'La mesa ${table.code} no tiene una cuenta con pedidos activos pendientes de cobro.'
          : (raw.isNotEmpty
                ? raw
                : 'No se encontró una cuenta para la mesa ${table.code}.');

      messenger.showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: tokens.brandCrimson),
      );
      return;
    }

    if (account.balance <= 0.001) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'La cuenta de la mesa ${table.code} ya está totalmente saldada (Saldo: S/ 0.00).',
          ),
          backgroundColor: AsiaPalette.jade,
        ),
      );
      await widget.tableController.loadTables(silent: true);
      return;
    }

    // State for item selection: Key is '${order.id}_$lineIndex'
    final Map<String, bool> selectedItems = <String, bool>{};
    for (final TableAccountOrder order in account.orders) {
      for (int i = 0; i < order.lines.length; i++) {
        selectedItems['${order.id}_$i'] = true;
      }
    }

    // State for payment method
    bool isSplitPayment =
        false; // false = Pago Único, true = Pago Mixto (Efectivo + Yape)
    String singleMethod = 'EFECTIVO';

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController singleAmountCtrl = TextEditingController();
    final TextEditingController singleRefCtrl = TextEditingController();
    final TextEditingController splitCashCtrl = TextEditingController();
    final TextEditingController splitYapeCtrl = TextEditingController();
    final TextEditingController splitYapeRefCtrl = TextEditingController();

    double computeSelectedTotal() {
      if (account.orders.isEmpty) {
        return account.balance;
      }
      double sum = 0.0;
      for (final TableAccountOrder order in account.orders) {
        for (int i = 0; i < order.lines.length; i++) {
          if (selectedItems['${order.id}_$i'] ?? false) {
            sum += order.lines[i].subtotal;
          }
        }
      }
      return sum;
    }

    void syncControllers(double total) {
      final double capped = total > account.balance ? account.balance : total;
      singleAmountCtrl.text = capped.toStringAsFixed(2);
      final double half = double.parse((capped / 2).toStringAsFixed(2));
      splitCashCtrl.text = half.toStringAsFixed(2);
      splitYapeCtrl.text = (capped - half).toStringAsFixed(2);
    }

    syncControllers(computeSelectedTotal());

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          final AsiaThemeTokens tokens = context.tokens;
          final double selectedTotal = computeSelectedTotal();
          final double effectiveCharge = selectedTotal > account.balance
              ? account.balance
              : selectedTotal;

          return AdminDialog(
            title: 'Cobrar Mesa ${table.code}',
            subtitle: 'Cuenta consolidada · ${account.orders.length} pedido(s)',
            maxWidth: 680,
            confirmLabel: 'Registrar Cobro',
            isConfirmLoading: widget.paymentController.isSaving,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              if (effectiveCharge <= 0) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Selecciona al menos un ítem o pedido para cobrar.',
                    ),
                  ),
                );
                return;
              }

              TableAccountSummary? updated;

              if (!isSplitPayment) {
                // Single payment mode
                final double amount = double.parse(
                  singleAmountCtrl.text.trim(),
                );
                updated = await widget.paymentController
                    .recordTableAccountPayment(
                      tableId: table.id,
                      amount: amount,
                      methodCode: singleMethod,
                      referenceCode: singleMethod == 'EFECTIVO'
                          ? null
                          : (singleRefCtrl.text.trim().isEmpty
                                ? null
                                : singleRefCtrl.text.trim()),
                    );
              } else {
                // Split payment mode: Cash + Yape
                final double cashAmount = double.parse(
                  splitCashCtrl.text.trim(),
                );
                final double yapeAmount = double.parse(
                  splitYapeCtrl.text.trim(),
                );
                final String yapeRef = splitYapeRefCtrl.text.trim();

                TableAccountSummary? step1;
                if (cashAmount > 0) {
                  step1 = await widget.paymentController
                      .recordTableAccountPayment(
                        tableId: table.id,
                        amount: cashAmount,
                        methodCode: 'EFECTIVO',
                        referenceCode: null,
                      );

                  if (step1 == null) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.paymentController.errorMessage ??
                              'Error al procesar el cobro en efectivo.',
                        ),
                        backgroundColor: tokens.error,
                      ),
                    );
                    return;
                  }
                }

                if (yapeAmount > 0 &&
                    (step1 == null || step1.balance > 0.001)) {
                  final double chargeYape = step1 != null
                      ? (yapeAmount > step1.balance
                            ? step1.balance
                            : yapeAmount)
                      : yapeAmount;

                  updated = await widget.paymentController
                      .recordTableAccountPayment(
                        tableId: table.id,
                        amount: chargeYape,
                        methodCode: 'YAPE',
                        referenceCode: yapeRef,
                      );
                } else {
                  updated = step1;
                }
              }

              if (!dialogContext.mounted) return;
              if (updated == null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.paymentController.errorMessage ??
                          'No se pudo registrar el cobro.',
                    ),
                    backgroundColor: tokens.error,
                  ),
                );
                return;
              }

              Navigator.of(dialogContext).pop();
              await widget.tableController.loadTables(silent: true);

              if (updated.balance <= 0.001) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '¡Cuenta de ${table.code} pagada totalmente! Mesa liberada con éxito.',
                    ),
                    backgroundColor: AsiaPalette.jade,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cobro parcial registrado. Saldo pendiente en ${table.code}: S/ ${updated.balance.toStringAsFixed(2)}',
                    ),
                    backgroundColor: AsiaPalette.blue,
                  ),
                );
              }
            },
            content: Form(
              key: formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 520),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Balance overview card
                      Container(
                        padding: const EdgeInsets.all(AsiaSpacing.md),
                        decoration: BoxDecoration(
                          color: tokens.cardElevated,
                          borderRadius: AsiaRadii.md,
                          border: Border.all(color: tokens.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Total Cuenta: S/ ${account.totalAmount.toStringAsFixed(2)}',
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Saldo Pendiente: S/ ${account.balance.toStringAsFixed(2)}',
                                  style: AsiaTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: tokens.brandCrimson,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  'Ítems Seleccionados:',
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                                Text(
                                  'S/ ${selectedTotal.toStringAsFixed(2)}',
                                  style: AsiaTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AsiaPalette.jade,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AsiaSpacing.md),

                      // Quick Selection Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Detalle de Pedidos e Ítems a Cobrar',
                            style: AsiaTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: tokens.textSecondary,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    for (final TableAccountOrder o
                                        in account.orders) {
                                      for (int i = 0; i < o.lines.length; i++) {
                                        selectedItems['${o.id}_$i'] = true;
                                      }
                                    }
                                    syncControllers(computeSelectedTotal());
                                  });
                                },
                                child: Text(
                                  'Seleccionar Todos',
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.brandCrimson,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AsiaSpacing.md),
                              InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    for (final TableAccountOrder o
                                        in account.orders) {
                                      for (int i = 0; i < o.lines.length; i++) {
                                        selectedItems['${o.id}_$i'] = false;
                                      }
                                    }
                                    syncControllers(0.0);
                                  });
                                },
                                child: Text(
                                  'Deseleccionar',
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AsiaSpacing.sm),

                      // Itemized List by Orders
                      if (account.orders.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AsiaSpacing.md,
                          ),
                          child: Text(
                            'No hay pedidos cargados en la cuenta. Se cobrará el saldo directo.',
                            style: AsiaTypography.caption.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                        )
                      else
                        ...account.orders.map((TableAccountOrder order) {
                          final bool allSelected = order.lines
                              .asMap()
                              .entries
                              .every(
                                (MapEntry<int, TableAccountLine> e) =>
                                    selectedItems['${order.id}_${e.key}'] ??
                                    false,
                              );

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AsiaSpacing.sm,
                            ),
                            padding: const EdgeInsets.all(AsiaSpacing.sm),
                            decoration: BoxDecoration(
                              color: tokens.card,
                              borderRadius: AsiaRadii.sm,
                              border: Border.all(color: tokens.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Order header with toggle all for this order
                                Row(
                                  children: <Widget>[
                                    Checkbox(
                                      value: allSelected,
                                      activeColor: tokens.brandCrimson,
                                      onChanged: (bool? val) {
                                        setDialogState(() {
                                          for (
                                            int i = 0;
                                            i < order.lines.length;
                                            i++
                                          ) {
                                            selectedItems['${order.id}_$i'] =
                                                val ?? false;
                                          }
                                          syncControllers(
                                            computeSelectedTotal(),
                                          );
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Pedido #${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id} • ${order.status}',
                                        style: AsiaTypography.caption.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: tokens.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'S/ ${order.totalAmount.toStringAsFixed(2)}',
                                      style: AsiaTypography.caption.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: tokens.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 1),
                                // Lines inside order
                                ...order.lines.asMap().entries.map((
                                  MapEntry<int, TableAccountLine> entry,
                                ) {
                                  final int lineIdx = entry.key;
                                  final TableAccountLine line = entry.value;
                                  final String key = '${order.id}_$lineIdx';
                                  final bool isLineChecked =
                                      selectedItems[key] ?? false;

                                  return InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        selectedItems[key] = !isLineChecked;
                                        syncControllers(computeSelectedTotal());
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AsiaSpacing.sm,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: isLineChecked,
                                              activeColor: tokens.brandCrimson,
                                              onChanged: (bool? val) {
                                                setDialogState(() {
                                                  selectedItems[key] =
                                                      val ?? false;
                                                  syncControllers(
                                                    computeSelectedTotal(),
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: AsiaSpacing.sm),
                                          Expanded(
                                            child: Text(
                                              '${line.quantity} × ${line.productName}',
                                              style: AsiaTypography.bodyMedium
                                                  .copyWith(
                                                    color: isLineChecked
                                                        ? tokens.textPrimary
                                                        : tokens.textTertiary,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            'S/ ${line.subtotal.toStringAsFixed(2)}',
                                            style: AsiaTypography.bodyMedium
                                                .copyWith(
                                                  fontWeight: isLineChecked
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: isLineChecked
                                                      ? tokens.textPrimary
                                                      : tokens.textTertiary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: AsiaSpacing.md),
                      const Divider(),
                      const SizedBox(height: AsiaSpacing.sm),

                      // Payment Modality Selector (Dos modalidades: Pago Único vs Pago Mixto)
                      Text(
                        'Modalidad de Pago',
                        style: AsiaTypography.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AsiaSpacing.xs),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Pago Único')),
                              selected: !isSplitPayment,
                              selectedColor: tokens.brandCrimson,
                              backgroundColor: tokens.cardElevated,
                              labelStyle: AsiaTypography.caption.copyWith(
                                color: !isSplitPayment
                                    ? Colors.white
                                    : tokens.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) {
                                setDialogState(() {
                                  isSplitPayment = false;
                                  syncControllers(computeSelectedTotal());
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AsiaSpacing.md),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(
                                child: Text('Pago Mixto (Efectivo + Yape)'),
                              ),
                              selected: isSplitPayment,
                              selectedColor: tokens.brandCrimson,
                              backgroundColor: tokens.cardElevated,
                              labelStyle: AsiaTypography.caption.copyWith(
                                color: isSplitPayment
                                    ? Colors.white
                                    : tokens.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) {
                                setDialogState(() {
                                  isSplitPayment = true;
                                  syncControllers(computeSelectedTotal());
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AsiaSpacing.md),

                      // Fields for Single Payment Mode
                      if (!isSplitPayment) ...<Widget>[
                        AdminTextField(
                          controller: singleAmountCtrl,
                          label: 'Monto a Cobrar (S/)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: LucideIcons.dollarSign,
                          validator: (String? val) {
                            final double? parsed = double.tryParse(
                              val?.trim() ?? '',
                            );
                            if (parsed == null || parsed <= 0) {
                              return 'Ingresa un monto válido mayor a 0';
                            }
                            if (parsed > account.balance + 0.01) {
                              return 'El monto no puede superar el saldo pendiente (S/ ${account.balance.toStringAsFixed(2)})';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AsiaSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: singleMethod,
                          decoration: const InputDecoration(
                            labelText: 'Método de Pago',
                          ),
                          items: const <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: 'EFECTIVO',
                              child: Text('Efectivo'),
                            ),
                            DropdownMenuItem(
                              value: 'YAPE',
                              child: Text('Yape'),
                            ),
                            DropdownMenuItem(
                              value: 'PLIN',
                              child: Text('Plin'),
                            ),
                            DropdownMenuItem(
                              value: 'TARJETA',
                              child: Text('Tarjeta de Crédito / Débito'),
                            ),
                          ],
                          onChanged: (String? val) {
                            if (val != null) {
                              setDialogState(() => singleMethod = val);
                            }
                          },
                        ),
                        if (singleMethod != 'EFECTIVO') ...<Widget>[
                          const SizedBox(height: AsiaSpacing.md),
                          AdminTextField(
                            controller: singleRefCtrl,
                            label:
                                (singleMethod == 'YAPE' ||
                                    singleMethod == 'PLIN')
                                ? 'Número de Celular $singleMethod'
                                : 'Código de Operación (9 dígitos)',
                            hintText:
                                (singleMethod == 'YAPE' ||
                                    singleMethod == 'PLIN')
                                ? 'ej. 987654321 (inicia con 9)'
                                : 'ej. 123456789',
                            prefixIcon: LucideIcons.hash,
                            keyboardType: TextInputType.number,
                            validator: (String? val) {
                              final String trimmed = val?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'Obligatorio para pagos con $singleMethod';
                              }
                              if (singleMethod == 'YAPE' ||
                                  singleMethod == 'PLIN') {
                                if (!RegExp(r'^9[0-9]{8}$').hasMatch(trimmed)) {
                                  return '$singleMethod requiere un número de 9 dígitos que inicie con 9';
                                }
                              } else if (singleMethod == 'TARJETA') {
                                if (!RegExp(r'^[0-9]{9}$').hasMatch(trimmed)) {
                                  return 'Tarjeta requiere un número de operación de 9 dígitos';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ] else ...<Widget>[
                        // Fields for Split Payment Mode (Efectivo + Yape)
                        Container(
                          padding: const EdgeInsets.all(AsiaSpacing.sm),
                          decoration: BoxDecoration(
                            color: AsiaPalette.gold.withValues(alpha: 0.1),
                            borderRadius: AsiaRadii.sm,
                            border: Border.all(
                              color: AsiaPalette.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                LucideIcons.split,
                                size: 18,
                                color: AsiaPalette.gold,
                              ),
                              const SizedBox(width: AsiaSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Cobro dividido: Efectivo + Yape (Total objetivo: S/ ${effectiveCharge.toStringAsFixed(2)})',
                                  style: AsiaTypography.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ),
                              AdminButton(
                                label: '50% / 50%',
                                size: AdminButtonSize.sm,
                                variant: AdminButtonVariant.secondary,
                                onPressed: () {
                                  setDialogState(() {
                                    final double half = double.parse(
                                      (effectiveCharge / 2).toStringAsFixed(2),
                                    );
                                    splitCashCtrl.text = half.toStringAsFixed(
                                      2,
                                    );
                                    splitYapeCtrl.text =
                                        (effectiveCharge - half)
                                            .toStringAsFixed(2);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AsiaSpacing.md),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: AdminTextField(
                                controller: splitCashCtrl,
                                label: 'Monto en Efectivo (S/)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                prefixIcon: LucideIcons.banknote,
                                onChanged: (String val) {
                                  final double? cash = double.tryParse(
                                    val.trim(),
                                  );
                                  if (cash != null && cash <= effectiveCharge) {
                                    setDialogState(() {
                                      splitYapeCtrl.text =
                                          (effectiveCharge - cash)
                                              .toStringAsFixed(2);
                                    });
                                  }
                                },
                                validator: (String? val) {
                                  final double? p = double.tryParse(
                                    val?.trim() ?? '',
                                  );
                                  if (p == null || p < 0)
                                    return 'Monto inválido';
                                  final double yapeVal =
                                      double.tryParse(
                                        splitYapeCtrl.text.trim(),
                                      ) ??
                                      0.0;
                                  if ((p + yapeVal - effectiveCharge).abs() >
                                      0.02) {
                                    return 'Suma ≠ S/ ${effectiveCharge.toStringAsFixed(2)}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AsiaSpacing.md),
                            Expanded(
                              child: AdminTextField(
                                controller: splitYapeCtrl,
                                label: 'Monto en Yape (S/)',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                prefixIcon: LucideIcons.smartphone,
                                onChanged: (String val) {
                                  final double? yape = double.tryParse(
                                    val.trim(),
                                  );
                                  if (yape != null && yape <= effectiveCharge) {
                                    setDialogState(() {
                                      splitCashCtrl.text =
                                          (effectiveCharge - yape)
                                              .toStringAsFixed(2);
                                    });
                                  }
                                },
                                validator: (String? val) {
                                  final double? p = double.tryParse(
                                    val?.trim() ?? '',
                                  );
                                  if (p == null || p < 0)
                                    return 'Monto inválido';
                                  final double cashVal =
                                      double.tryParse(
                                        splitCashCtrl.text.trim(),
                                      ) ??
                                      0.0;
                                  if ((p + cashVal - effectiveCharge).abs() >
                                      0.02) {
                                    return 'Suma ≠ S/ ${effectiveCharge.toStringAsFixed(2)}';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AsiaSpacing.md),
                        AdminTextField(
                          controller: splitYapeRefCtrl,
                          label: 'Número de Celular Yape (Referencia)',
                          hintText: 'ej. 987654321 (9 dígitos)',
                          prefixIcon: LucideIcons.hash,
                          keyboardType: TextInputType.number,
                          validator: (String? val) {
                            final String trimmed = val?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Ingresa el número celular de la constancia Yape';
                            }
                            if (!RegExp(r'^9[0-9]{8}$').hasMatch(trimmed)) {
                              return 'Yape requiere un número de 9 dígitos que comience con 9';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    singleAmountCtrl.dispose();
    singleRefCtrl.dispose();
    splitCashCtrl.dispose();
    splitYapeCtrl.dispose();
    splitYapeRefCtrl.dispose();
  }

  void _openCreateTableDialog(BuildContext context) {
    final TextEditingController codeCtrl = TextEditingController();
    final TextEditingController areaCtrl = TextEditingController(
      text: 'Salón Principal',
    );

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AdminDialog(
        title: 'Agregar Nueva Mesa',
        subtitle: 'Crea una mesa física para la atención en salón o terraza.',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AdminTextField(
              controller: codeCtrl,
              label: 'Código de Mesa',
              hintText: 'Ej. MESA-09 o TERRAZA-01',
              autofocus: true,
            ),
            const SizedBox(height: AsiaSpacing.md),
            AdminTextField(
              controller: areaCtrl,
              label: 'Área / Ubicación',
              hintText: 'Ej. Salón Principal, Terraza, Barra',
            ),
          ],
        ),
        confirmLabel: 'Crear Mesa',
        onConfirm: () async {
          if (codeCtrl.text.trim().isNotEmpty) {
            final bool ok = await widget.tableController.createTable(
              code: codeCtrl.text.trim(),
              areaLabel: areaCtrl.text.trim(),
            );
            if (ok && ctx.mounted) {
              Navigator.of(ctx).pop();
            }
          }
        },
      ),
    );
  }
}
