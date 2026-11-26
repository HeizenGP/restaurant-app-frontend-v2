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
import '../../orders/application/order_controller.dart';
import '../../orders/domain/order_models.dart';
import '../../payments/application/payment_controller.dart';
import '../../payments/domain/payment_models.dart';
import '../../products/application/catalog_controller.dart';
import '../../products/domain/catalog_models.dart';
import '../application/table_controller.dart';
import '../domain/table_models.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({
    required this.tableController,
    required this.paymentController,
    this.orderController,
    this.catalogController,
    this.authController,
    super.key,
  });

  final TableController tableController;
  final PaymentController paymentController;
  final OrderController? orderController;
  final CatalogController? catalogController;
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
      widget.catalogController?.loadCatalog(silent: true);
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
                        childAspectRatio: width > 1200
                            ? 0.92
                            : (width > 900 ? 0.95 : (width > 600 ? 1.05 : 1.15)),
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
              Row(
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
                  const SizedBox(width: 8),
                  AdminBadge(
                    label: occupied ? 'OCUPADA' : 'DISPONIBLE',
                    variant: occupied
                        ? AdminBadgeVariant.warning
                        : AdminBadgeVariant.success,
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.moreVertical,
                  size: 18,
                  color: tokens.textSecondary,
                ),
                tooltip: 'Opciones de mesa',
                onSelected: (String action) {
                  if (action == 'edit') {
                    _openEditTableDialog(context, table);
                  } else if (action == 'delete') {
                    _confirmDeleteTable(context, table);
                  }
                },
                itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          LucideIcons.pencil,
                          size: 15,
                          color: tokens.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        const Text('Editar mesa'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          LucideIcons.trash2,
                          size: 15,
                          color: tokens.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Eliminar mesa',
                          style: TextStyle(color: tokens.error),
                        ),
                      ],
                    ),
                  ),
                ],
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
          const SizedBox(height: AsiaSpacing.sm),
          Row(
            children: <Widget>[
              Icon(
                occupied ? LucideIcons.clock : LucideIcons.checkCircle2,
                size: 13,
                color: occupied ? tokens.brandGold : tokens.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                occupied ? 'En servicio' : 'Lista para asignar',
                style: AsiaTypography.caption.copyWith(
                  color: occupied ? tokens.brandGold : tokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.xs),
          if (occupied) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AdminButton(
                    label: 'Agregar pedido',
                    icon: LucideIcons.plusCircle,
                    variant: AdminButtonVariant.secondary,
                    size: AdminButtonSize.sm,
                    onPressed: () => _openAddOrderDialog(context, table),
                  ),
                ),
                const SizedBox(width: AsiaSpacing.xs),
                Expanded(
                  child: AdminButton(
                    label: 'Cobrar mesa',
                    icon: LucideIcons.walletCards,
                    variant: AdminButtonVariant.primary,
                    size: AdminButtonSize.sm,
                    onPressed: () => _openChargeTableDialog(context, table),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AsiaSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: AdminButton(
                label: 'Liberar mesa',
                icon: LucideIcons.logOut,
                variant: AdminButtonVariant.ghost,
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
            ),
          ] else ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: AdminButton(
                    label: 'Tomar pedido',
                    icon: LucideIcons.plusCircle,
                    variant: AdminButtonVariant.primary,
                    size: AdminButtonSize.sm,
                    onPressed: () => _openAddOrderDialog(context, table),
                  ),
                ),
                const SizedBox(width: AsiaSpacing.xs),
                Expanded(
                  child: AdminButton(
                    label: 'Ocupar mesa',
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
                ),
              ],
            ),
          ],
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
    bool isSplitPayment = false; // false = Pago Único, true = Pago Mixto
    String singleMethod = 'EFECTIVO';
    String splitMethod1 = 'EFECTIVO';
    String splitMethod2 = 'YAPE';

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController singleAmountCtrl = TextEditingController();
    final TextEditingController singleRefCtrl = TextEditingController();
    final TextEditingController splitAmount1Ctrl = TextEditingController();
    final TextEditingController splitAmount2Ctrl = TextEditingController();
    final TextEditingController splitRef1Ctrl = TextEditingController();
    final TextEditingController splitRef2Ctrl = TextEditingController();

    String getMethodName(String code) {
      switch (code) {
        case 'EFECTIVO':
          return 'Efectivo';
        case 'YAPE':
          return 'Yape';
        case 'PLIN':
          return 'Plin';
        case 'TARJETA':
          return 'Tarjeta';
        default:
          return code;
      }
    }

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
      splitAmount1Ctrl.text = half.toStringAsFixed(2);
      splitAmount2Ctrl.text = (capped - half).toStringAsFixed(2);
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
                // Split payment mode: Two selectable methods
                final double amount1 = double.parse(
                  splitAmount1Ctrl.text.trim(),
                );
                final double amount2 = double.parse(
                  splitAmount2Ctrl.text.trim(),
                );
                final String ref1 = splitRef1Ctrl.text.trim();
                final String ref2 = splitRef2Ctrl.text.trim();

                TableAccountSummary? step1;
                if (amount1 > 0) {
                  step1 = await widget.paymentController
                      .recordTableAccountPayment(
                        tableId: table.id,
                        amount: amount1,
                        methodCode: splitMethod1,
                        referenceCode: splitMethod1 == 'EFECTIVO'
                            ? null
                            : (ref1.isEmpty ? null : ref1),
                      );

                  if (step1 == null) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.paymentController.errorMessage ??
                              'Error al procesar el cobro con ${getMethodName(splitMethod1)}.',
                        ),
                        backgroundColor: tokens.error,
                      ),
                    );
                    return;
                  }
                }

                if (amount2 > 0 &&
                    (step1 == null || step1.balance > 0.001)) {
                  final double charge2 = step1 != null
                      ? (amount2 > step1.balance
                            ? step1.balance
                            : amount2)
                      : amount2;

                  updated = await widget.paymentController
                      .recordTableAccountPayment(
                        tableId: table.id,
                        amount: charge2,
                        methodCode: splitMethod2,
                        referenceCode: splitMethod2 == 'EFECTIVO'
                            ? null
                            : (ref2.isEmpty ? null : ref2),
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
                                child: Text('Pago Mixto (2 Métodos)'),
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
                          Container(
                            padding: const EdgeInsets.all(AsiaSpacing.md),
                            decoration: BoxDecoration(
                              color: tokens.cardElevated,
                              borderRadius: AsiaRadii.md,
                              border: Border.all(
                                color: tokens.brandCrimson.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      LucideIcons.receiptText,
                                      size: 16,
                                      color: tokens.brandCrimson,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Control de Voucher · $singleMethod',
                                      style: AsiaTypography.caption.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: tokens.brandCrimson,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ingresa el código o número de operación del voucher para el registro y control de caja.',
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textSecondary,
                                    fontSize: 11.5,
                                  ),
                                ),
                                const SizedBox(height: AsiaSpacing.sm),
                                AdminTextField(
                                  controller: singleRefCtrl,
                                  label: 'Código de Operación (Voucher)',
                                  hintText: (singleMethod == 'YAPE' ||
                                          singleMethod == 'PLIN')
                                      ? 'ej. 12345678 (N° de operación del voucher)'
                                      : 'ej. 000123 (N° de operación del POS)',
                                  prefixIcon: LucideIcons.hash,
                                  validator: (String? val) {
                                    final String trimmed = val?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return 'Ingresa el código de operación del voucher';
                                    }
                                    if (trimmed.length < 3) {
                                      return 'El código debe tener al menos 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...<Widget>[
                        // Fields for Split Payment Mode (Dos métodos seleccionables)
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
                                  'Cobro dividido: ${getMethodName(splitMethod1)} + ${getMethodName(splitMethod2)} (Total objetivo: S/ ${effectiveCharge.toStringAsFixed(2)})',
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
                                    splitAmount1Ctrl.text =
                                        half.toStringAsFixed(2);
                                    splitAmount2Ctrl.text =
                                        (effectiveCharge - half)
                                            .toStringAsFixed(2);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AsiaSpacing.md),
                        LayoutBuilder(
                          builder: (
                            BuildContext ctx,
                            BoxConstraints constraints,
                          ) {
                            final bool isRow = constraints.maxWidth > 500;
                            final Widget col1 = _buildSplitPaymentColumn(
                              tokens: tokens,
                              title: 'Primer Método',
                              selectedMethod: splitMethod1,
                              amountCtrl: splitAmount1Ctrl,
                              refCtrl: splitRef1Ctrl,
                              otherAmountCtrl: splitAmount2Ctrl,
                              effectiveCharge: effectiveCharge,
                              onMethodChanged: (String? val) {
                                if (val != null) {
                                  setDialogState(() => splitMethod1 = val);
                                }
                              },
                              onAmountChanged: (double val) {
                                setDialogState(() {
                                  splitAmount2Ctrl.text =
                                      (effectiveCharge - val)
                                          .toStringAsFixed(2);
                                });
                              },
                            );

                            final Widget col2 = _buildSplitPaymentColumn(
                              tokens: tokens,
                              title: 'Segundo Método',
                              selectedMethod: splitMethod2,
                              amountCtrl: splitAmount2Ctrl,
                              refCtrl: splitRef2Ctrl,
                              otherAmountCtrl: splitAmount1Ctrl,
                              effectiveCharge: effectiveCharge,
                              onMethodChanged: (String? val) {
                                if (val != null) {
                                  setDialogState(() => splitMethod2 = val);
                                }
                              },
                              onAmountChanged: (double val) {
                                setDialogState(() {
                                  splitAmount1Ctrl.text =
                                      (effectiveCharge - val)
                                          .toStringAsFixed(2);
                                });
                              },
                            );

                            if (isRow) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(child: col1),
                                  const SizedBox(width: AsiaSpacing.md),
                                  Expanded(child: col2),
                                ],
                              );
                            }

                            return Column(
                              children: <Widget>[
                                col1,
                                const SizedBox(height: AsiaSpacing.md),
                                col2,
                              ],
                            );
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
    splitAmount1Ctrl.dispose();
    splitAmount2Ctrl.dispose();
    splitRef1Ctrl.dispose();
    splitRef2Ctrl.dispose();
  }

  Widget _buildSplitPaymentColumn({
    required AsiaThemeTokens tokens,
    required String title,
    required String selectedMethod,
    required TextEditingController amountCtrl,
    required TextEditingController refCtrl,
    required TextEditingController otherAmountCtrl,
    required double effectiveCharge,
    required ValueChanged<String?> onMethodChanged,
    required ValueChanged<double> onAmountChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AsiaSpacing.md),
      decoration: BoxDecoration(
        color: tokens.cardElevated,
        borderRadius: AsiaRadii.md,
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AsiaTypography.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: selectedMethod,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(value: 'EFECTIVO', child: Text('Efectivo')),
              DropdownMenuItem(value: 'YAPE', child: Text('Yape')),
              DropdownMenuItem(value: 'PLIN', child: Text('Plin')),
              DropdownMenuItem(
                value: 'TARJETA',
                child: Text('Tarjeta de Crédito / Débito'),
              ),
            ],
            onChanged: onMethodChanged,
          ),
          const SizedBox(height: AsiaSpacing.md),
          AdminTextField(
            controller: amountCtrl,
            label: 'Monto a Cobrar (S/)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: LucideIcons.dollarSign,
            onChanged: (String val) {
              final double? parsed = double.tryParse(val.trim());
              if (parsed != null && parsed <= effectiveCharge) {
                onAmountChanged(parsed);
              }
            },
            validator: (String? val) {
              final double? p = double.tryParse(val?.trim() ?? '');
              if (p == null || p < 0) {
                return 'Monto inválido';
              }
              final double otherVal =
                  double.tryParse(otherAmountCtrl.text.trim()) ?? 0.0;
              if ((p + otherVal - effectiveCharge).abs() > 0.02) {
                return 'Suma ≠ S/ ${effectiveCharge.toStringAsFixed(2)}';
              }
              return null;
            },
          ),
          if (selectedMethod != 'EFECTIVO') ...<Widget>[
            const SizedBox(height: AsiaSpacing.md),
            AdminTextField(
              controller: refCtrl,
              label: 'Código de Operación ($selectedMethod)',
              hintText: (selectedMethod == 'YAPE' || selectedMethod == 'PLIN')
                  ? 'ej. 12345678 (constancia)'
                  : 'ej. 000123 (voucher POS)',
              prefixIcon: LucideIcons.hash,
              validator: (String? val) {
                final double p =
                    double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (p <= 0) return null;
                final String trimmed = val?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Obligatorio para $selectedMethod';
                }
                if (trimmed.length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
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

  void _openEditTableDialog(BuildContext context, RestaurantTable table) {
    final AsiaThemeTokens tokens = context.tokens;
    final TextEditingController codeCtrl = TextEditingController(
      text: table.code,
    );
    final TextEditingController areaCtrl = TextEditingController(
      text: table.area,
    );

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setDialogState) {
          return AdminDialog(
            title: 'Editar Mesa ${table.code}',
            subtitle: 'Actualiza el código o la zona asignada a esta mesa.',
            maxWidth: 450,
            confirmLabel: 'Guardar Cambios',
            isConfirmLoading: widget.tableController.isSaving,
            onConfirm: () async {
              final String newCode = codeCtrl.text.trim();
              final String newArea = areaCtrl.text.trim();
              if (newCode.isEmpty) return;

              final ScaffoldMessengerState messenger =
                  ScaffoldMessenger.of(context);
              final bool ok = await widget.tableController.updateTable(
                tableId: table.id,
                code: newCode,
                areaLabel: newArea.isEmpty ? null : newArea,
              );

              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
              if (ok) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Mesa $newCode actualizada correctamente.'),
                    backgroundColor: AsiaPalette.jade,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.tableController.errorMessage ??
                          'Error al actualizar la mesa.',
                    ),
                    backgroundColor: tokens.error,
                  ),
                );
              }
            },
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AdminTextField(
                  controller: codeCtrl,
                  label: 'Código de Mesa',
                  hintText: 'ej. MESA-01',
                  prefixIcon: LucideIcons.armchair,
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: areaCtrl,
                  label: 'Área / Ubicación',
                  hintText: 'ej. Salón Principal, Terraza, VIP',
                  prefixIcon: LucideIcons.mapPin,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteTable(BuildContext context, RestaurantTable table) {
    final AsiaThemeTokens tokens = context.tokens;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (table.isOccupied) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'La mesa ${table.code} está actualmente en servicio. Debes liberarla o cobrarla antes de eliminarla.',
          ),
          backgroundColor: tokens.brandCrimson,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AdminDialog(
        title: '¿Eliminar Mesa ${table.code}?',
        subtitle:
            'Esta acción removerá la mesa del restaurante de forma definitiva.',
        confirmLabel: 'Eliminar Mesa',
        isDanger: true,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final bool ok = await widget.tableController.deleteTable(table.id);
          if (ok) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Mesa ${table.code} eliminada con éxito.'),
                backgroundColor: AsiaPalette.jade,
              ),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  widget.tableController.errorMessage ??
                      'No se pudo eliminar la mesa.',
                ),
                backgroundColor: tokens.error,
              ),
            );
          }
        },
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Confirmas que deseas eliminar la mesa "${table.code}" situada en "${table.area}".',
            style: AsiaTypography.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddOrderDialog(
    BuildContext context,
    RestaurantTable table,
  ) async {
    final AsiaThemeTokens tokens = context.tokens;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    if (widget.orderController == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('El controlador de pedidos no está disponible.'),
        ),
      );
      return;
    }

    if (widget.catalogController != null) {
      if (widget.catalogController!.products.isEmpty) {
        await widget.catalogController!.loadCatalog();
      }
    }

    final List<Product> availableProducts =
        widget.catalogController?.products ?? <Product>[];
    if (availableProducts.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'No hay productos disponibles en el catálogo para ordenar.',
          ),
          backgroundColor: tokens.brandCrimson,
        ),
      );
      return;
    }
    if (!context.mounted) return;

    final Map<String, int> cart = <String, int>{};
    String filterText = '';

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          final List<Product> filtered = availableProducts.where((Product p) {
            if (!p.isAvailable) return false;
            if (filterText.isEmpty) return true;
            return p.name.toLowerCase().contains(filterText.toLowerCase()) ||
                (p.description?.toLowerCase().contains(
                      filterText.toLowerCase(),
                    ) ??
                    false);
          }).toList();

          double totalOrder = 0.0;
          cart.forEach((String prodId, int qty) {
            final Product? prod = availableProducts.cast<Product?>().firstWhere(
              (Product? p) => p?.id == prodId,
              orElse: () => null,
            );
            if (prod != null) {
              totalOrder += prod.price * qty;
            }
          });

          return AdminDialog(
            title: 'Agregar Pedido · Mesa ${table.code}',
            subtitle:
                'Selecciona los productos y cantidades para enviar la comanda a cocina.',
            maxWidth: 650,
            confirmLabel:
                'Enviar Pedido (S/ ${totalOrder.toStringAsFixed(2)})',
            isConfirmLoading: widget.orderController!.isActionLoading,
            onConfirm: () async {
              if (cart.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Selecciona al menos un producto para el pedido.',
                    ),
                  ),
                );
                return;
              }

              final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
              cart.forEach((String prodId, int qty) {
                if (qty > 0) {
                  items.add(<String, dynamic>{
                    'product_id': prodId,
                    'quantity': qty,
                  });
                }
              });

              final StaffOrder? created = await widget.orderController!
                  .createTableOrder(tableId: table.id, items: items);

              if (created != null) {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                await widget.tableController.toggleOccupancy(table.id, true);
                await widget.tableController.loadTables(silent: true);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '¡Pedido #${created.id.length > 8 ? created.id.substring(0, 8).toUpperCase() : created.id} creado y enviado a cocina para ${table.code}!',
                    ),
                    backgroundColor: AsiaPalette.jade,
                  ),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.orderController!.errorMessage ??
                          'Error al crear el pedido.',
                    ),
                    backgroundColor: tokens.error,
                  ),
                );
              }
            },
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AdminTextField(
                    label: 'Buscar Producto',
                    hintText: 'Filtrar por nombre del plato o bebida...',
                    prefixIcon: LucideIcons.search,
                    onChanged: (String val) {
                      setDialogState(() => filterText = val.trim());
                    },
                  ),
                  const SizedBox(height: AsiaSpacing.sm),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AsiaSpacing.xl),
                              child: Text(
                                'No se encontraron productos coincidentes.',
                                style: AsiaTypography.caption.copyWith(
                                  color: tokens.textTertiary,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (BuildContext _, int _) =>
                                const Divider(height: 1),
                            itemBuilder: (BuildContext ctx, int index) {
                              final Product p = filtered[index];
                              final int qty = cart[p.id] ?? 0;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            p.name,
                                            style: AsiaTypography.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: tokens.textPrimary,
                                                ),
                                          ),
                                          Text(
                                            'S/ ${p.price.toStringAsFixed(2)}',
                                            style: AsiaTypography.caption
                                                .copyWith(
                                                  color: tokens.brandCrimson,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(
                                            LucideIcons.minusCircle,
                                            size: 22,
                                            color: qty > 0
                                                ? tokens.brandCrimson
                                                : tokens.border,
                                          ),
                                          onPressed: qty > 0
                                              ? () {
                                                  setDialogState(() {
                                                    if (qty <= 1) {
                                                      cart.remove(p.id);
                                                    } else {
                                                      cart[p.id] = qty - 1;
                                                    }
                                                  });
                                                }
                                              : null,
                                        ),
                                        Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 28,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$qty',
                                            style: AsiaTypography.bodyLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: qty > 0
                                                      ? tokens.brandCrimson
                                                      : tokens.textTertiary,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            LucideIcons.plusCircle,
                                            size: 22,
                                            color: tokens.brandCrimson,
                                          ),
                                          onPressed: () {
                                            setDialogState(() {
                                              cart[p.id] = qty + 1;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
