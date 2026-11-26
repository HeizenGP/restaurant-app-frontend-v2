import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/components/admin_badge.dart';
import '../../../core/design_system/components/admin_button.dart';
import '../../../core/design_system/components/admin_card.dart';
import '../../../core/design_system/components/admin_dialog.dart';
import '../../../core/design_system/components/admin_text_field.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../../auth/domain/auth_models.dart';
import '../application/staff_controller.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({required this.staffController, super.key});

  final StaffController staffController;

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.staffController.loadStaff();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return ListenableBuilder(
      listenable: widget.staffController,
      builder: (BuildContext context, _) {
        final List<StaffUser> staff = widget.staffController.filteredStaff;
        final bool isLoading = widget.staffController.isLoading;

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
                        'Administración de Empleados',
                        style: AsiaTypography.displayMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${staff.length} colaboradores y permisos del restaurante',
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      AdminButton(
                        label: 'Registrar Empleado',
                        icon: LucideIcons.userPlus,
                        size: AdminButtonSize.sm,
                        onPressed: () => _openCreateStaffDialog(context),
                      ),
                      const SizedBox(width: AsiaSpacing.md),
                      AdminButton(
                        label: 'Actualizar',
                        icon: LucideIcons.refreshCw,
                        variant: AdminButtonVariant.secondary,
                        size: AdminButtonSize.sm,
                        isLoading: isLoading,
                        onPressed: () => widget.staffController.loadStaff(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Search & Role Filters
              AdminCard(
                padding: const EdgeInsets.all(AsiaSpacing.md),
                child: Column(
                  children: <Widget>[
                    AdminTextField(
                      hintText: 'Buscar por nombre, correo o teléfono...',
                      prefixIcon: LucideIcons.search,
                      onChanged: (String val) =>
                          widget.staffController.setSearchQuery(val),
                    ),
                    const SizedBox(height: AsiaSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _buildRoleChip(
                            label: 'TODOS',
                            isSelected:
                                widget.staffController.roleFilter == null,
                            onTap: () =>
                                widget.staffController.setRoleFilter(null),
                          ),
                          _buildRoleChip(
                            label: 'ADMINISTRADORES',
                            isSelected:
                                widget.staffController.roleFilter ==
                                RoleCode.admin,
                            onTap: () => widget.staffController.setRoleFilter(
                              RoleCode.admin,
                            ),
                          ),
                          _buildRoleChip(
                            label: 'MOZOS',
                            isSelected:
                                widget.staffController.roleFilter ==
                                RoleCode.waiter,
                            onTap: () => widget.staffController.setRoleFilter(
                              RoleCode.waiter,
                            ),
                          ),
                          _buildRoleChip(
                            label: 'CAJEROS',
                            isSelected:
                                widget.staffController.roleFilter ==
                                RoleCode.cashier,
                            onTap: () => widget.staffController.setRoleFilter(
                              RoleCode.cashier,
                            ),
                          ),
                          _buildRoleChip(
                            label: 'COCINA',
                            isSelected:
                                widget.staffController.roleFilter ==
                                RoleCode.kitchen,
                            onTap: () => widget.staffController.setRoleFilter(
                              RoleCode.kitchen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AsiaSpacing.xl),

              // Staff Data Table
              if (isLoading && staff.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AsiaSpacing.xxxl),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (staff.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AsiaSpacing.xxxl),
                    child: Text(
                      'No se encontraron empleados con los filtros aplicados.',
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: tokens.textTertiary,
                      ),
                    ),
                  ),
                )
              else
                AdminCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        tokens.cardElevated,
                      ),
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Colaborador')),
                        DataColumn(label: Text('Correo')),
                        DataColumn(label: Text('Teléfono')),
                        DataColumn(label: Text('Roles')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: staff.map((StaffUser user) {
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: tokens.brandCrimson
                                        .withValues(alpha: 0.15),
                                    child: Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName[0].toUpperCase()
                                          : 'U',
                                      style: AsiaTypography.caption.copyWith(
                                        color: tokens.brandCrimson,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    user.displayName,
                                    style: AsiaTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.phone ?? '-')),
                            DataCell(
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: user.roles.map((RoleCode r) {
                                  return AdminBadge(
                                    label: r.displayName,
                                    variant:
                                        r == RoleCode.admin ||
                                            r == RoleCode.superAdmin
                                        ? AdminBadgeVariant.brand
                                        : (r == RoleCode.cashier
                                              ? AdminBadgeVariant.warning
                                              : AdminBadgeVariant.neutral),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(
                              user.isSuperAdmin
                                  ? Tooltip(
                                      message:
                                          'El Super Admin no puede desactivarse',
                                      child: Switch(
                                        value: true,
                                        activeThumbColor: tokens.brandJade,
                                        onChanged: null,
                                      ),
                                    )
                                  : Switch(
                                      value: user.isActive,
                                      activeThumbColor: tokens.brandJade,
                                      onChanged: (bool val) =>
                                          widget.staffController.toggleUserStatus(
                                            user.id,
                                            val,
                                          ),
                                    ),
                            ),
                            DataCell(
                              AdminButton(
                                label: 'Asignar Rol',
                                icon: LucideIcons.shieldAlert,
                                variant: AdminButtonVariant.secondary,
                                size: AdminButtonSize.sm,
                                onPressed: () =>
                                    _openAssignRoleDialog(context, user),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleChip({
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

  void _openCreateStaffDialog(BuildContext context) {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController passCtrl = TextEditingController();
    final TextEditingController phoneCtrl = TextEditingController();
    RoleCode selectedRole = RoleCode.waiter;

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return AdminDialog(
            title: 'Registrar Colaborador',
            subtitle: 'Crea una cuenta de acceso para personal operativo o administrativo.',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AdminTextField(
                  controller: nameCtrl,
                  label: 'Nombre Completo',
                  hintText: 'Ej. Carlos Ramos',
                  autofocus: true,
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: emailCtrl,
                  label: 'Correo Electrónico',
                  hintText: 'carlos@kairo.pe',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: passCtrl,
                  label: 'Contraseña Temporal (Min 8 caracteres, mayúscula y número)',
                  hintText: 'Kairo2026!',
                  isPassword: true,
                ),
                const SizedBox(height: AsiaSpacing.md),
                DropdownButtonFormField<RoleCode>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rol Principal Asignado',
                  ),
                  items: const <DropdownMenuItem<RoleCode>>[
                    DropdownMenuItem<RoleCode>(
                      value: RoleCode.waiter,
                      child: Text('Mozo / Atención de Mesas'),
                    ),
                    DropdownMenuItem<RoleCode>(
                      value: RoleCode.cashier,
                      child: Text('Cajero / Cobros'),
                    ),
                    DropdownMenuItem<RoleCode>(
                      value: RoleCode.kitchen,
                      child: Text('Cocina / Despacho'),
                    ),
                    DropdownMenuItem<RoleCode>(
                      value: RoleCode.admin,
                      child: Text('Administrador de Tienda'),
                    ),
                  ],
                  onChanged: (RoleCode? val) {
                    if (val != null) setStateDialog(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: AsiaSpacing.md),
                AdminTextField(
                  controller: phoneCtrl,
                  label: 'Teléfono Móvil (Opcional)',
                  hintText: '987654321',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            confirmLabel: 'Crear Cuenta',
            onConfirm: () async {
              if (nameCtrl.text.trim().isEmpty ||
                  emailCtrl.text.trim().isEmpty ||
                  passCtrl.text.isEmpty) {
                return;
              }
              final bool ok = await widget.staffController.createStaff(
                displayName: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                password: passCtrl.text,
                role: selectedRole,
                phone: phoneCtrl.text.trim(),
              );
              if (ok && ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
          );
        },
      ),
    );
  }

  void _openAssignRoleDialog(BuildContext context, StaffUser user) {
    RoleCode selectedRole = RoleCode.cashier;

    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return AdminDialog(
            title: 'Asignar Rol a ${user.displayName}',
            subtitle: 'Agrega un rol acumulativo para habilitar permisos adicionales.',
            content: DropdownButtonFormField<RoleCode>(
              initialValue: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Nuevo Rol a Conceder',
              ),
              items: const <DropdownMenuItem<RoleCode>>[
                DropdownMenuItem<RoleCode>(
                  value: RoleCode.waiter,
                  child: Text('Mozo'),
                ),
                DropdownMenuItem<RoleCode>(
                  value: RoleCode.cashier,
                  child: Text('Cajero'),
                ),
                DropdownMenuItem<RoleCode>(
                  value: RoleCode.kitchen,
                  child: Text('Cocina'),
                ),
                DropdownMenuItem<RoleCode>(
                  value: RoleCode.admin,
                  child: Text('Administrador'),
                ),
              ],
              onChanged: (RoleCode? val) {
                if (val != null) setStateDialog(() => selectedRole = val);
              },
            ),
            confirmLabel: 'Asignar Rol',
            onConfirm: () async {
              final bool ok = await widget.staffController.assignRole(
                user.id,
                selectedRole,
              );
              if (ok && ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
          );
        },
      ),
    );
  }
}
