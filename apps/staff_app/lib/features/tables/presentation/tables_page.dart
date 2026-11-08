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
import '../application/table_controller.dart';
import '../domain/table_models.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({required this.tableController, super.key});

  final TableController tableController;

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
        final List<RestaurantTable> tables = widget.tableController.filteredTables;
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _buildAreaChip(
                          context,
                          label: 'Todas las áreas (${widget.tableController.tables.length})',
                          isSelected: widget.tableController.selectedArea == null,
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
                            onTap: () => widget.tableController.selectArea(area),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AsiaSpacing.xl),
              ],

              // Tables Grid
              if (isLoading && tables.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AsiaSpacing.xxxl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (tables.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AsiaSpacing.xxxl),
                    child: Text(
                      'No hay mesas configuradas.',
                      style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int cols = constraints.maxWidth > 1100
                        ? 4
                        : (constraints.maxWidth > 700 ? 3 : 2);
                    final double cardWidth =
                        (constraints.maxWidth - (cols - 1) * AsiaSpacing.lg) / cols;

                    return Wrap(
                      spacing: AsiaSpacing.lg,
                      runSpacing: AsiaSpacing.lg,
                      children: tables.map((RestaurantTable table) {
                        return SizedBox(
                          width: cardWidth,
                          child: _buildTableCard(context, table),
                        );
                      }).toList(),
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
                variant: occupied ? AdminBadgeVariant.warning : AdminBadgeVariant.success,
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
          const SizedBox(height: AsiaSpacing.lg),
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
              AdminButton(
                label: occupied ? 'Liberar' : 'Ocupar',
                variant: occupied ? AdminButtonVariant.secondary : AdminButtonVariant.primary,
                size: AdminButtonSize.sm,
                onPressed: () async {
                  final ScaffoldMessengerState messenger =
                      ScaffoldMessenger.of(context);
                  final bool ok = await widget.tableController
                      .toggleOccupancy(table.id, !occupied);
                  if (!ok && context.mounted) {
                    final String msg = widget.tableController.errorMessage ??
                        'No se pudo liberar la mesa.';
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: tokens.error,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  } else if (ok && occupied && context.mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                            'Mesa ${table.code} liberada y disponible.'),
                        backgroundColor: tokens.success,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openCreateTableDialog(BuildContext context) {
    final TextEditingController codeCtrl = TextEditingController();
    final TextEditingController areaCtrl = TextEditingController(text: 'Salón Principal');

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
