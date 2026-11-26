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
import '../../auth/application/auth_controller.dart';
import '../application/payment_controller.dart';
import '../domain/payment_models.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({
    required this.paymentController,
    this.authController,
    super.key,
  });

  final PaymentController paymentController;
  final AuthController? authController;

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

  void _showOpenRegisterDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController amountCtrl = TextEditingController(
      text: '100.00',
    );
    final TextEditingController cashierCtrl = TextEditingController(
      text:
          widget.authController?.currentUser?.displayName ?? 'Cajero Principal',
    );
    final TextEditingController notesCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AdminDialog(
          title: 'Apertura de Caja',
          subtitle:
              'Ingresa el fondo inicial en efectivo para iniciar el turno',
          maxWidth: 480,
          confirmLabel: 'Abrir Caja',
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            if (formKey.currentState?.validate() ?? false) {
              final double initialAmount = double.parse(amountCtrl.text.trim());
              final String cashierName = cashierCtrl.text.trim();
              final String? notes = notesCtrl.text.trim().isEmpty
                  ? null
                  : notesCtrl.text.trim();

              widget.paymentController.openCashRegister(
                initialAmount: initialAmount,
                userName: cashierName,
                notes: notes,
              );
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Caja abierta exitosamente con fondo de S/ ${initialAmount.toStringAsFixed(2)}',
                  ),
                  backgroundColor: AsiaPalette.jade,
                ),
              );
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
                  label: 'Nombre del Cajero / Responsable',
                  prefixIcon: LucideIcons.user,
                  validator: (String? val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa el nombre del responsable';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: amountCtrl,
                  label: 'Fondo Inicial de Caja (Efectivo en S/)',
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: LucideIcons.wallet,
                  validator: (String? val) {
                    final double? parsed = double.tryParse(val?.trim() ?? '');
                    if (parsed == null || parsed < 0) {
                      return 'Ingresa un fondo inicial válido (0 o mayor)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: notesCtrl,
                  label: 'Notas de Apertura (opcional)',
                  hintText:
                      'ej. Monedas y billetes de cambio para comenzar el día',
                  prefixIcon: LucideIcons.fileText,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCloseRegisterDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final double expected = widget.paymentController.sessionTotalExpectedCash;
    final TextEditingController realAmountCtrl = TextEditingController(
      text: expected.toStringAsFixed(2),
    );
    final TextEditingController notesCtrl = TextEditingController();
    final String cashierName =
        widget.authController?.currentUser?.displayName ??
        (widget.paymentController.currentSession?.openedByUserName ??
            'Cajero Principal');

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            final AsiaThemeTokens tokens = ctx.tokens;
            final double realAmount =
                double.tryParse(realAmountCtrl.text.trim()) ?? 0.0;
            final double diff = realAmount - expected;

            return AdminDialog(
              title: 'Cierre de Caja y Arqueo',
              subtitle: 'Verifica y cuenta el efectivo real en gaveta para cerrar el turno',
              maxWidth: 520,
              confirmLabel: 'Finalizar y Cerrar Turno',
              isDanger: true,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onConfirm: () {
                if (formKey.currentState?.validate() ?? false) {
                  final double real = double.parse(realAmountCtrl.text.trim());
                  final String? notes = notesCtrl.text.trim().isEmpty
                      ? null
                      : notesCtrl.text.trim();

                  widget.paymentController.closeCashRegister(
                    realAmount: real,
                    userName: cashierName,
                    notes: notes,
                  );
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Caja cerrada exitosamente. Arqueo guardado en el historial.',
                      ),
                      backgroundColor: AsiaPalette.jade,
                    ),
                  );
                }
              },
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(AsiaSpacing.md),
                      decoration: BoxDecoration(
                        color: tokens.cardElevated,
                        borderRadius: AsiaRadii.md,
                        border: Border.all(color: tokens.border),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Fondo Inicial de Apertura:',
                                style: AsiaTypography.caption.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                              Text(
                                'S/ ${widget.paymentController.sessionInitialAmount.toStringAsFixed(2)}',
                                style: AsiaTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: tokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AsiaSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Cobros en Efectivo del Turno:',
                                style: AsiaTypography.caption.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                              Text(
                                '+ S/ ${widget.paymentController.sessionCashCollected.toStringAsFixed(2)}',
                                style: AsiaTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AsiaPalette.jade,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: AsiaSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Total Efectivo Esperado:',
                                style: AsiaTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: tokens.textPrimary,
                                ),
                              ),
                              Text(
                                'S/ ${expected.toStringAsFixed(2)}',
                                style: AsiaTypography.headingMedium.copyWith(
                                  color: tokens.brandCrimson,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    AdminTextField(
                      controller: realAmountCtrl,
                      label: 'Efectivo Real Contado en Gaveta (S/)',
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixIcon: LucideIcons.banknote,
                      onChanged: (_) => setModalState(() {}),
                      validator: (String? val) {
                        final double? parsed = double.tryParse(
                          val?.trim() ?? '',
                        );
                        if (parsed == null || parsed < 0) {
                          return 'Ingresa el monto contado en gaveta';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AsiaSpacing.sm),
                    // Indicador dinámico de Arqueo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AsiaSpacing.md,
                        vertical: AsiaSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: diff.abs() < 0.001
                            ? AsiaPalette.jade.withValues(alpha: 0.1)
                            : (diff > 0
                                  ? AsiaPalette.blue.withValues(alpha: 0.1)
                                  : tokens.error.withValues(alpha: 0.1)),
                        borderRadius: AsiaRadii.sm,
                        border: Border.all(
                          color: diff.abs() < 0.001
                              ? AsiaPalette.jade.withValues(alpha: 0.3)
                              : (diff > 0
                                    ? AsiaPalette.blue.withValues(alpha: 0.3)
                                    : tokens.error.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            diff.abs() < 0.001
                                ? LucideIcons.checkCircle
                                : (diff > 0
                                      ? LucideIcons.arrowUpRight
                                      : LucideIcons.alertTriangle),
                            size: 16,
                            color: diff.abs() < 0.001
                                ? AsiaPalette.jade
                                : (diff > 0 ? AsiaPalette.blue : tokens.error),
                          ),
                          const SizedBox(width: AsiaSpacing.xs),
                          Expanded(
                            child: Text(
                              diff.abs() < 0.001
                                  ? 'Caja cuadrada exactamente (Diferencia: S/ 0.00)'
                                  : (diff > 0
                                        ? 'Sobrante en caja: +S/ ${diff.toStringAsFixed(2)}'
                                        : 'Faltante en caja: -S/ ${(-diff).toStringAsFixed(2)}'),
                              style: AsiaTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: diff.abs() < 0.001
                                    ? AsiaPalette.jade
                                    : (diff > 0
                                          ? AsiaPalette.blue
                                          : tokens.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    AdminTextField(
                      controller: notesCtrl,
                      label: 'Observaciones de Cierre (opcional)',
                      hintText: 'ej. Turno cerrado sin incidencias / Detalle de billetes',
                      prefixIcon: LucideIcons.fileText,
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
              title: 'Registrar Cobro Directo',
              subtitle: 'Ingreso directo a caja de restaurante',
              maxWidth: 480,
              confirmLabel: 'Registrar',
              isConfirmLoading: widget.paymentController.isSaving,
              onCancel: () => Navigator.of(dialogContext).pop(),
              onConfirm: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                    context,
                  );
                  final NavigatorState nav = Navigator.of(dialogContext);
                  final double amount = double.parse(amountCtrl.text.trim());
                  final bool ok = await widget.paymentController
                      .recordCollection(
                        orderId: orderIdCtrl.text.trim(),
                        amount: amount,
                        methodCode: selectedMethod,
                        referenceCode: selectedMethod == 'EFECTIVO'
                            ? null
                            : referenceCtrl.text.trim(),
                      );
                  if (ok) {
                    nav.pop();
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Cobro registrado exitosamente'),
                        backgroundColor: AsiaPalette.jade,
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          widget.paymentController.errorMessage ??
                              'Error al registrar cobro.',
                        ),
                        backgroundColor: tokens.error,
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
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.textPrimary,
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
                              setDialogState(() {
                                selectedMethod = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (selectedMethod != 'EFECTIVO') ...<Widget>[
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
                                  'Control de Voucher · $selectedMethod',
                                  style: AsiaTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: tokens.brandCrimson,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ingresa el código o número de operación del voucher para el registro y arqueo de caja.',
                              style: AsiaTypography.caption.copyWith(
                                color: tokens.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: AsiaSpacing.sm),
                            AdminTextField(
                              controller: referenceCtrl,
                              label: 'Código de Operación (Voucher)',
                              hintText: (selectedMethod == 'YAPE' ||
                                      selectedMethod == 'PLIN')
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
        final bool isRegisterOpen = widget.paymentController.isCashRegisterOpen;

        if (!isRegisterOpen) {
          return _buildCashClosedView(context, tokens, isDesktop, isTablet);
        }

        final List<PaymentRecord> payments =
            widget.paymentController.filteredPayments;
        final bool isLoading = widget.paymentController.isLoading;
        final String? errorMessage = widget.paymentController.errorMessage;
        final double totalCollected = widget.paymentController.totalCollected;
        final NumberFormat currencyFmt = NumberFormat.currency(
          locale: 'es_PE',
          symbol: 'S/ ',
        );
        final DateFormat dateFmt = DateFormat('dd/MM/yyyy HH:mm');
        final CashRegisterSession? session =
            widget.paymentController.currentSession;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Shift active banner
              if (session != null) ...<Widget>[
                _buildActiveShiftBanner(
                  context,
                  tokens,
                  session,
                  isDesktop,
                  isTablet,
                ),
                const SizedBox(height: AsiaSpacing.xl),
              ],

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Pagos y Cobros',
                        style: AsiaTypography.displaySmall.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AsiaSpacing.xs),
                      Text(
                        'Historial de transacciones, cobros en caja y liquidaciones',
                        style: AsiaTypography.bodyMedium.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: AsiaSpacing.sm,
                    children: <Widget>[
                      AdminButton(
                        label: 'Actualizar',
                        icon: LucideIcons.refreshCw,
                        variant: AdminButtonVariant.secondary,
                        onPressed: () =>
                            widget.paymentController.loadPayments(),
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
                  final double cardWidth =
                      (constraints.maxWidth -
                          (isDesktop ? 2 * AsiaSpacing.md : AsiaSpacing.md)) /
                      (isDesktop ? 3 : (isTablet ? 2 : 1));
                  final int totalTransactions =
                      widget.paymentController.payments.length;
                  final double avgTransaction = totalTransactions > 0
                      ? (totalCollected / totalTransactions)
                      : 0.0;

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
                            onChanged: (String val) =>
                                widget.paymentController.setSearchQuery(val),
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
                          _buildFilterChip(
                            'Todos',
                            null,
                            widget.paymentController.methodFilter,
                          ),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip(
                            'Efectivo',
                            'EFECTIVO',
                            widget.paymentController.methodFilter,
                          ),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip(
                            'Yape',
                            'YAPE',
                            widget.paymentController.methodFilter,
                          ),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip(
                            'Plin',
                            'PLIN',
                            widget.paymentController.methodFilter,
                          ),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip(
                            'Tarjeta',
                            'TARJETA',
                            widget.paymentController.methodFilter,
                          ),
                          const SizedBox(width: AsiaSpacing.sm),
                          _buildFilterChip(
                            'Anticipos',
                            'ADVANCE',
                            widget.paymentController.methodFilter,
                          ),
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
                    border: Border.all(
                      color: tokens.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(LucideIcons.alertTriangle, color: tokens.error),
                      const SizedBox(width: AsiaSpacing.sm),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.error,
                          ),
                        ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: AsiaSpacing.xxxl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          LucideIcons.creditCard,
                          size: 64,
                          color: tokens.textTertiary,
                        ),
                        const SizedBox(height: AsiaSpacing.md),
                        Text(
                          'No se encontraron registros de pago',
                          style: AsiaTypography.headingMedium.copyWith(
                            color: tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AsiaSpacing.xs),
                        Text(
                          'Los cobros y pagos registrados aparecerán aquí.',
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: tokens.textTertiary,
                          ),
                        ),
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
                        headingRowColor: WidgetStateProperty.all(
                          tokens.cardElevated,
                        ),
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: 64,
                        columnSpacing: AsiaSpacing.xl,
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Fecha y Hora',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Orden ID',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Tipo',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Método',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Monto',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Referencia',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Registrado por',
                              style: AsiaTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: tokens.textPrimary,
                              ),
                            ),
                          ),
                        ],
                        rows: payments.map((PaymentRecord p) {
                          return DataRow(
                            cells: <DataCell>[
                              DataCell(
                                Text(
                                  dateFmt.format(p.recordedAt),
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  p.orderId.length > 8
                                      ? '${p.orderId.substring(0, 8)}...'
                                      : p.orderId,
                                  style: AsiaTypography.caption.copyWith(
                                    fontFamily: 'monospace',
                                    color: tokens.brandCrimson,
                                  ),
                                ),
                              ),
                              DataCell(_buildKindBadge(p.kind)),
                              DataCell(
                                _buildMethodBadge(
                                  p.methodCode ??
                                      (p.kind == 'ADVANCE'
                                          ? 'ANTICIPO'
                                          : 'OTRO'),
                                ),
                              ),
                              DataCell(
                                Text(
                                  currencyFmt.format(p.amount),
                                  style: AsiaTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.referenceCode ?? '-',
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  p.recordedByUserId.length > 8
                                      ? '${p.recordedByUserId.substring(0, 8)}...'
                                      : p.recordedByUserId,
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textTertiary,
                                  ),
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
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AsiaSpacing.md),
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
                                style: AsiaTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: tokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AsiaSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildMethodBadge(
                                p.methodCode ??
                                    (p.kind == 'ADVANCE' ? 'ANTICIPO' : 'OTRO'),
                              ),
                              Text(
                                dateFmt.format(p.recordedAt),
                                style: AsiaTypography.caption.copyWith(
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: AsiaSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Orden:',
                                style: AsiaTypography.caption.copyWith(
                                  color: tokens.textTertiary,
                                ),
                              ),
                              SelectableText(
                                p.orderId.length > 12
                                    ? '${p.orderId.substring(0, 12)}...'
                                    : p.orderId,
                                style: AsiaTypography.caption.copyWith(
                                  fontFamily: 'monospace',
                                  color: tokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (p.referenceCode != null) ...<Widget>[
                            const SizedBox(height: AsiaSpacing.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Ref:',
                                  style: AsiaTypography.caption.copyWith(
                                    color: tokens.textTertiary,
                                  ),
                                ),
                                Text(
                                  p.referenceCode!,
                                  style: AsiaTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: tokens.textSecondary,
                                  ),
                                ),
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

  Widget _buildActiveShiftBanner(
    BuildContext context,
    AsiaThemeTokens tokens,
    CashRegisterSession session,
    bool isDesktop,
    bool isTablet,
  ) {
    final DateFormat dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final double initial = session.initialAmount;
    final double cashCollected = widget.paymentController.sessionCashCollected;
    final double digitalCollected =
        widget.paymentController.sessionDigitalCollected;
    final double totalExpected =
        widget.paymentController.sessionTotalExpectedCash;

    return Container(
      padding: const EdgeInsets.all(AsiaSpacing.lg),
      decoration: BoxDecoration(
        color: AsiaPalette.jade.withValues(alpha: 0.08),
        borderRadius: AsiaRadii.lg,
        border: Border.all(color: AsiaPalette.jade.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AsiaSpacing.sm,
                children: <Widget>[
                  const AdminBadge(
                    label: 'CAJA ABIERTA',
                    variant: AdminBadgeVariant.success,
                  ),
                  Text(
                    'Turno de ${session.openedByUserName}',
                    style: AsiaTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                  Text(
                    '• Iniciado el ${dateFmt.format(session.openedAt)}',
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
              AdminButton(
                label: 'Cerrar Caja / Arqueo',
                icon: LucideIcons.lock,
                variant: AdminButtonVariant.danger,
                size: AdminButtonSize.sm,
                onPressed: _showCloseRegisterDialog,
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.md),
          LayoutBuilder(
            builder: (BuildContext ctx, BoxConstraints constraints) {
              final double colWidth =
                  (constraints.maxWidth -
                      (isDesktop ? 3 * AsiaSpacing.md : AsiaSpacing.md)) /
                  (isDesktop ? 4 : (isTablet ? 2 : 1));

              return Wrap(
                spacing: AsiaSpacing.md,
                runSpacing: AsiaSpacing.md,
                children: <Widget>[
                  _buildShiftMetricCard(
                    'Fondo Inicial',
                    'S/ ${initial.toStringAsFixed(2)}',
                    LucideIcons.wallet,
                    tokens.textPrimary,
                    colWidth,
                  ),
                  _buildShiftMetricCard(
                    'Efectivo Recaudado',
                    '+ S/ ${cashCollected.toStringAsFixed(2)}',
                    LucideIcons.banknote,
                    AsiaPalette.jade,
                    colWidth,
                  ),
                  _buildShiftMetricCard(
                    'Digital (Yape/Plin/Tarjeta)',
                    'S/ ${digitalCollected.toStringAsFixed(2)}',
                    LucideIcons.smartphone,
                    AsiaPalette.blue,
                    colWidth,
                  ),
                  _buildShiftMetricCard(
                    'Total Esperado en Gaveta',
                    'S/ ${totalExpected.toStringAsFixed(2)}',
                    LucideIcons.vault,
                    tokens.brandCrimson,
                    colWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShiftMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double width,
  ) {
    final AsiaThemeTokens tokens = context.tokens;
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: AsiaSpacing.md,
        vertical: AsiaSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AsiaRadii.md,
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AsiaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: AsiaTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashClosedView(
    BuildContext context,
    AsiaThemeTokens tokens,
    bool isDesktop,
    bool isTablet,
  ) {
    final DateFormat dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final List<CashRegisterSession> history =
        widget.paymentController.sessionHistory;

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
                    'Caja y Operaciones',
                    style: AsiaTypography.displaySmall.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AsiaSpacing.xs),
                  Text(
                    'Control de turnos, apertura, arqueo y liquidaciones',
                    style: AsiaTypography.bodyMedium.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
              const AdminBadge(
                label: 'CAJA CERRADA',
                variant: AdminBadgeVariant.neutral,
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.xxl),

          // Closed Hero Card
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: AdminCard(
                padding: const EdgeInsets.all(AsiaSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: tokens.cardElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.border, width: 2),
                      ),
                      child: Icon(
                        LucideIcons.lockKeyhole,
                        size: 40,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AsiaSpacing.lg),
                    Text(
                      'La Caja se encuentra Cerrada',
                      style: AsiaTypography.headingLarge.copyWith(
                        color: tokens.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AsiaSpacing.sm),
                    Text(
                      'Para comenzar a registrar ventas, cobrar mesas de comensales y procesar transacciones, debes realizar la apertura del turno de caja e ingresar el fondo inicial en efectivo.',
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: tokens.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AsiaSpacing.xl),
                    AdminButton(
                      label: 'Abrir Turno de Caja',
                      icon: LucideIcons.keyRound,
                      size: AdminButtonSize.lg,
                      onPressed: _showOpenRegisterDialog,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AsiaSpacing.xxl),

          // Session History
          if (history.isNotEmpty) ...<Widget>[
            Text(
              'Historial de Turnos y Arqueos Anteriores',
              style: AsiaTypography.headingMedium.copyWith(
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AsiaSpacing.md),
            AdminCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: AsiaRadii.lg,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      tokens.cardElevated,
                    ),
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Apertura',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Cierre',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Cajero',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Fondo Inicial',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total Esperado',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Efectivo Real',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Diferencia',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Notas',
                          style: AsiaTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    rows: history.map((CashRegisterSession s) {
                      final double diff = s.difference ?? 0.0;
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Text(
                              dateFmt.format(s.openedAt),
                              style: AsiaTypography.caption,
                            ),
                          ),
                          DataCell(
                            Text(
                              s.closedAt != null
                                  ? dateFmt.format(s.closedAt!)
                                  : '-',
                              style: AsiaTypography.caption,
                            ),
                          ),
                          DataCell(
                            Text(
                              s.openedByUserName,
                              style: AsiaTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              'S/ ${s.initialAmount.toStringAsFixed(2)}',
                              style: AsiaTypography.caption,
                            ),
                          ),
                          DataCell(
                            Text(
                              'S/ ${(s.finalAmount ?? 0.0).toStringAsFixed(2)}',
                              style: AsiaTypography.caption,
                            ),
                          ),
                          DataCell(
                            Text(
                              'S/ ${(s.realAmount ?? 0.0).toStringAsFixed(2)}',
                              style: AsiaTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: diff.abs() < 0.001
                                    ? AsiaPalette.jade.withValues(alpha: 0.1)
                                    : (diff > 0
                                          ? AsiaPalette.blue.withValues(
                                              alpha: 0.1,
                                            )
                                          : tokens.error.withValues(
                                              alpha: 0.1,
                                            )),
                                borderRadius: AsiaRadii.sm,
                              ),
                              child: Text(
                                diff.abs() < 0.001
                                    ? 'S/ 0.00'
                                    : (diff > 0
                                          ? '+S/ ${diff.toStringAsFixed(2)}'
                                          : '-S/ ${(-diff).toStringAsFixed(2)}'),
                                style: AsiaTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: diff.abs() < 0.001
                                      ? AsiaPalette.jade
                                      : (diff > 0
                                            ? AsiaPalette.blue
                                            : tokens.error),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              s.closingNotes ?? s.openingNotes ?? '-',
                              style: AsiaTypography.caption.copyWith(
                                color: tokens.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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
      side: BorderSide(color: isSelected ? tokens.brandCrimson : tokens.border),
    );
  }

  Widget _buildKindBadge(String kind) {
    if (kind == 'ADVANCE') {
      return const AdminBadge(
        label: 'ANTICIPO',
        variant: AdminBadgeVariant.info,
      );
    }
    return const AdminBadge(label: 'COBRO', variant: AdminBadgeVariant.success);
  }

  Widget _buildMethodBadge(String method) {
    switch (method.toUpperCase()) {
      case 'EFECTIVO':
        return const AdminBadge(
          label: 'EFECTIVO',
          variant: AdminBadgeVariant.success,
        );
      case 'YAPE':
        return const AdminBadge(
          label: 'YAPE',
          variant: AdminBadgeVariant.warning,
        );
      case 'PLIN':
        return const AdminBadge(label: 'PLIN', variant: AdminBadgeVariant.info);
      case 'TARJETA':
        return const AdminBadge(
          label: 'TARJETA',
          variant: AdminBadgeVariant.brand,
        );
      default:
        return AdminBadge(label: method, variant: AdminBadgeVariant.neutral);
    }
  }
}
