import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/design_system/components/admin_badge.dart';
import '../../../core/design_system/components/admin_button.dart';
import '../../../core/design_system/components/admin_card.dart';
import '../../../core/design_system/components/admin_dialog.dart';
import '../../../core/design_system/components/admin_skeleton_loader.dart';
import '../../../core/design_system/components/admin_text_field.dart';
import '../../../core/design_system/components/stat_card.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../../../core/layout/breakpoints.dart';
import '../application/payment_controller.dart';
import '../domain/payment_models.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({
    required this.paymentController,
    super.key,
  });

  final PaymentController paymentController;

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.paymentController.loadPayments();
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        widget.paymentController.loadPayments(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showRecordPaymentDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController orderIdCtrl = TextEditingController();
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController referenceCtrl = TextEditingController();
    String selectedMethod = 'EFECTIVO';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            final AsiaThemeTokens tokens = context.tokens;

            return AdminDialog(
              title: 'Registrar Cobro',
              subtitle: 'Ingreso directo a caja de restaurante',
              maxWidth: 480,
              confirmLabel: 'Registrar',
              isConfirmLoading: widget.paymentController.isSaving,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onConfirm: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                  final NavigatorState nav = Navigator.of(dialogContext);
                  final double amount = double.parse(amountCtrl.text.trim());
                  final bool ok = await widget.paymentController.recordCollection(
                    orderId: orderIdCtrl.text.trim(),
                    amount: amount,
                    methodCode: selectedMethod,
                    referenceCode: referenceCtrl.text.trim().isEmpty ? null : referenceCtrl.text.trim(),
                  );
                  if (ok) {
                    nav.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Cobro registrado exitosamente'),
                        backgroundColor: AsiaPalette.jade,
                      ),
                    );
                  }
                }
              },
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AdminTextField(
                      controller: orderIdCtrl,
                      label: 'ID de Orden',
                      hintText: 'ej. 7c9e6679-7425-40de-944b-e07fc1f90ae7',
                      prefixIcon: LucideIcons.receipt,
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa el ID de la orden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    AdminTextField(
                      controller: amountCtrl,
                      label: 'Monto a Cobrar (S/)',
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: LucideIcons.dollarSign,
                      validator: (String? val) {
                        final double? parsed = double.tryParse(val?.trim() ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Ingresa un monto válido mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    Text(
                      'Método de Pago',
                      style: AsiaTypography.caption.copyWith(
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AsiaSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AsiaSpacing.md,
                        vertical: AsiaSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.cardElevated,
                        borderRadius: AsiaRadii.md,
                        border: Border.all(color: tokens.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMethod,
                          isExpanded: true,
                          dropdownColor: tokens.cardElevated,
                          style: AsiaTypography.bodyMedium.copyWith(color: tokens.textPrimary),
                          items: const <DropdownMenuItem<String>>[
                            DropdownMenuItem(value: 'EFECTIVO', child: Text('Efectivo')),
                            DropdownMenuItem(value: 'YAPE', child: Text('Yape')),
                            DropdownMenuItem(value: 'PLIN', child: Text('Plin')),
                            DropdownMenuItem(value: 'TARJETA', child: Text('Tarjeta de Crédito / Débito')),
                          ],
                          onChanged: (String? val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedMethod = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    AdminTextField(
                      controller: referenceCtrl,
                      label: 'Código de Operación / Ref (opcional)',
                      hintText: 'ej. 128492 o últimos 4 dígitos',
                      prefixIcon: LucideIcons.hash,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDesktop = Breakpoints.isDesktop(context);
    final bool isTablet = Breakpoints.isTablet(context);

    return ListenableBuilder(
      listenable: widget.paymentController,
      builder: (BuildContext context, _) {
        final List<PaymentRecord> payments = widget.paymentController.filteredPayments;
        final bool isLoading = widget.paymentController.isLoading;
        final String? errorMessage = widget.paymentController.errorMessage;
        final double totalCollected = widget.paymentController.totalCollected;
        final NumberFormat currencyFmt = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');
        final DateFormat dateFmt = DateFormat('dd/MM/yyyy HH:mm');

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
                      Text('Pagos y Cobros', style: AsiaTypography.displaySmall.copyWith(color: tokens.textPrimary)),
                      const SizedBox(height: AsiaSpacing.xs),
                      Text('Historial de transacciones, cobros en caja y liquidaciones', style: AsiaTypography.bodyMedium.copyWith(color: tokens.textSecondary)),
                    ],
                  ),
                  Wrap(
                    spacing: AsiaSpacing.sm,
                    children: <Widget>[
                      AdminButton(
                        label: 'Actualizar',
                        icon: LucideIcons.refreshCw,
                        variant: AdminButtonVariant.secondary,
                        onPressed: () => widget.paymentController.loadPayments(),
                      ),
                      AdminButton(
                        label: 'Nuevo Cobro',
                        icon: LucideIcons.plus,
                        onPressed: _showRecordPaymentDialog,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // KPI Row
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double cardWidth = (constraints.maxWidth - (isDesktop ? 2 * AsiaSpacing.md : AsiaSpacing.md)) / (isDesktop ? 3 : (isTablet ? 2 : 1));
                  final int totalTransactions = widget.paymentController.payments.length;
                  final double avgTransaction = totalTransactions > 0 ? (totalCollected / totalTransactions) : 0.0;

                  return Wrap(
                    spacing: AsiaSpacing.md,
                    runSpacing: AsiaSpacing.md,
                    children: <Widget>[
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Total Recaudado',
                          value: currencyFmt.format(totalCollected),
                          subtitle: 'Suma de todos los cobros y anticipos',
                          icon: LucideIcons.wallet,
                          accentColor: AsiaPalette.jade,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Transacciones Totales',
                          value: '$totalTransactions',
                          subtitle: 'Operaciones registradas en sistema',
                          icon: LucideIcons.receipt,
                          accentColor: AsiaPalette.blue,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: StatCard(
                          title: 'Ticket Promedio',
                          value: currencyFmt.format(avgTransaction),
                          subtitle: 'Promedio por operación',
                          icon: LucideIcons.trendingUp,
                          accentColor: AsiaPalette.gold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Filter & Search Bar
              AdminCard(
                padding: const EdgeInsets.all(AsiaSpacing.md),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AdminTextField(
                            controller: _searchCtrl,
                            hintText: 'Buscar por ID de orden o código de referencia...',
                            prefixIcon: LucideIcons.search,
                            onChanged: (String val) => widget.paymentController.setSearchQuery(val),
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(LucideIcons.x),
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _searchCtrl.clear();
                              widget.paymentController.setSearchQuery('');
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _buildFilterChip('Todos', null, widget.paymentController.methodFilter),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip('Efectivo', 'EFECTIVO', widget.paymentController.methodFilter),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip('Yape', 'YAPE', widget.paymentController.methodFilter),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip('Plin', 'PLIN', widget.paymentController.methodFilter),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip('Tarjeta', 'TARJETA', widget.paymentController.methodFilter),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip('Anticipos', 'ADVANCE', widget.paymentController.methodFilter),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AsiaSpacing.lg),

              // Error banner if any
              if (errorMessage != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(AsiaSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.error.withValues(alpha: 0.1),
                    borderRadius: AsiaRadii.md,
                    border: Border.all(color: tokens.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.alertTriangle, color: tokens.error),
                      const SizedBox(width: AsiaSpacing.sm),
                      Expanded(
                        child: Text(errorMessage, style: AsiaTypography.bodyMedium.copyWith(color: tokens.error)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AsiaSpacing.lg),
              ],

              // Main content: Table on desktop / tablet, Cards on mobile
              if (isLoading && payments.isEmpty)
                const AdminTableSkeleton(rows: 8, columns: 6)
              else if (payments.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AsiaSpacing.xxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(LucideIcons.creditCard, size: 64, color: tokens.textTertiary),
                        const SizedBox(height: AsiaSpacing.md),
                        Text('No se encontraron registros de pago', style: AsiaTypography.headingMedium.copyWith(color: tokens.textSecondary)),
                        const SizedBox(height: AsiaSpacing.xs),
                        Text('Los cobros y pagos registrados aparecerán aquí.', style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary)),
                      ],
                    ),
                  ),
                )
              else if (isDesktop || isTablet)
                AdminCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: AsiaRadii.lg,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(tokens.cardElevated),
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 64,
                        columnSpacing: AsiaSpacing.xl,
                        columns: <DataColumn>[
                          DataColumn(label: Text('Fecha y Hora', style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary))),
                          DataColumn(label: Text('Orden ID', style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary))),
                          DataColumn(label: Text('Tipo', style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary))),
                          DataColumn(label: Text('Método', style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary))),
                          DataColumn(label: Text('Monto', style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary))),
                          DataColumn(label: Text('Referencia', style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary))),
                          DataColumn(label: Text('Registrado por', style: AsiaTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary))),
                        ],
                        rows: payments.map((PaymentRecord p) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(Text(dateFmt.format(p.recordedAt), style: AsiaTypography.caption.copyWith(color: tokens.textSecondary))),
                              DataCell(
                                SelectableText(
                                  p.orderId.length > 8 ? '${p.orderId.substring(0, 8)}...' : p.orderId,
                                  style: AsiaTypography.caption.copyWith(fontFamily: 'monospace', color: tokens.brandCrimson),
                                ),
                              ),
                              DataCell(_buildKindBadge(p.kind)),
                              DataCell(_buildMethodBadge(p.methodCode ?? (p.kind == 'ADVANCE' ? 'ANTICIPO' : 'OTRO'))),
                              DataCell(
                                Text(
                                  currencyFmt.format(p.amount),
                                  style: AsiaTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary),
                                ),
                              ),
                              DataCell(Text(p.referenceCode ?? '-', style: AsiaTypography.caption.copyWith(color: tokens.textSecondary))),
                              DataCell(
                                Text(
                                  p.recordedByUserId.length > 8 ? '${p.recordedByUserId.substring(0, 8)}...' : p.recordedByUserId,
                                  style: AsiaTypography.caption.copyWith(color: tokens.textTertiary),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: payments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AsiaSpacing.md),
                  itemBuilder: (BuildContext context, int index) {
                    final PaymentRecord p = payments[index];
                    return AdminCard(
                      padding: const EdgeInsets.all(AsiaSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildKindBadge(p.kind),
                              Text(
                                currencyFmt.format(p.amount),
                                style: AsiaTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: tokens.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: AsiaSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildMethodBadge(p.methodCode ?? (p.kind == 'ADVANCE' ? 'ANTICIPO' : 'OTRO')),
                              Text(dateFmt.format(p.recordedAt), style: AsiaTypography.caption.copyWith(color: tokens.textSecondary)),
                            ],
                          ),
                          const Divider(height: AsiaSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Orden:', style: AsiaTypography.caption.copyWith(color: tokens.textTertiary)),
                              SelectableText(
                                p.orderId.length > 12 ? '${p.orderId.substring(0, 12)}...' : p.orderId,
                                style: AsiaTypography.caption.copyWith(fontFamily: 'monospace', color: tokens.textPrimary),
                              ),
                            ],
                          ),
                          if (p.referenceCode != null) ...<Widget>[
                            const SizedBox(height: AsiaSpacing.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Ref:', style: AsiaTypography.caption.copyWith(color: tokens.textTertiary)),
                                Text(p.referenceCode!, style: AsiaTypography.caption.copyWith(fontWeight: FontWeight.w600, color: tokens.textSecondary)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? value, String? currentFilter) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isSelected = currentFilter == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => widget.paymentController.setMethodFilter(value),
      selectedColor: tokens.brandCrimson,
      backgroundColor: tokens.cardElevated,
      labelStyle: AsiaTypography.caption.copyWith(
        color: isSelected ? Colors.white : tokens.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? tokens.brandCrimson : tokens.border,
      ),
    );
  }

  Widget _buildKindBadge(String kind) {
    if (kind == 'ADVANCE') {
      return const AdminBadge(label: 'ANTICIPO', variant: AdminBadgeVariant.info);
    }
    return const AdminBadge(label: 'COBRO', variant: AdminBadgeVariant.success);
  }

  Widget _buildMethodBadge(String method) {
    switch (method.toUpperCase()) {
      case 'EFECTIVO':
        return const AdminBadge(label: 'EFECTIVO', variant: AdminBadgeVariant.success);
      case 'YAPE':
        return const AdminBadge(label: 'YAPE', variant: AdminBadgeVariant.warning);
      case 'PLIN':
        return const AdminBadge(label: 'PLIN', variant: AdminBadgeVariant.info);
      case 'TARJETA':
        return const AdminBadge(label: 'TARJETA', variant: AdminBadgeVariant.brand);
      default:
        return AdminBadge(label: method, variant: AdminBadgeVariant.neutral);
    }
  }
}
