import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../app/theme/theme_mode_controller.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../m01_access/profile/domain/profile_models.dart';
import '../application/fulfillment_contracts.dart';
import '../application/fulfillment_controller.dart';
import '../domain/fulfillment_models.dart';

class FulfillmentModePage extends StatelessWidget {
  const FulfillmentModePage({
    required this.themeModeController,
    required this.controller,
    required this.onModeSelected,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentMode> onModeSelected;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return _FulfillmentFrame(
      child: AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) {
          final String localSubtitle = controller.state.hasAssignedTable
              ? 'Mesa ${controller.state.assignedTable?.code ?? ""} (en uso)'
              : 'Selecciona una mesa y espera validación';

          return ChifaPageScaffold(
            pageKey: const Key('page-fulfillment-mode'),
            title: '¿Cómo disfrutarás?',
            subtitle: 'Elige una modalidad para tu pedido.',
            contentGap: 37,
            themeModeController: themeModeController,
            onBackPressed: onBackPressed,
            showBackButton: showBackButton,
            initials: initials,
            avatarPath: avatarPath,
            onAvatarPressed: onAvatarPressed,
            onCartPressed: onCartPressed,
            cartItemCount: cartItemCount,
            tableLabel: controller.state.hasAssignedTable
                ? 'Mesa ${controller.state.assignedTable?.code ?? ""}'
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ChifaCard(
                  key: const Key('fulfillment-mode-local'),
                  icon: LucideIcons.store,
                  title: 'Consumo en local',
                  subtitle: localSubtitle,
                  minimumHeight: 116,
                  onTap: () => _choose(FulfillmentMode.local),
                ),
                const SizedBox(height: 10),
                ChifaCard(
                  key: const Key('fulfillment-mode-pickup'),
                  icon: LucideIcons.store,
                  title: 'Recojo en tienda',
                  subtitle: 'Anticipo del 50 % antes de cocina',
                  minimumHeight: 116,
                  onTap: () => _choose(FulfillmentMode.pickup),
                ),
                const SizedBox(height: 10),
                ChifaCard(
                  key: const Key('fulfillment-mode-delivery'),
                  icon: LucideIcons.truck,
                  title: 'Delivery',
                  subtitle: 'Dirección y anticipo del 50 %',
                  minimumHeight: 116,
                  onTap: () => _choose(FulfillmentMode.delivery),
                ),
                const SizedBox(height: 80),
                SizedBox(
                  height: 54,
                  child: Center(
                    child: Text(
                      'Selecciona una modalidad para continuar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.appPalette.textSecondary,
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _choose(FulfillmentMode mode) {
    controller.chooseMode(mode);
    onModeSelected(mode);
  }
}

class TableSelectionPage extends StatefulWidget {
  const TableSelectionPage({
    required this.themeModeController,
    required this.controller,
    required this.onFinished,
    this.onBackPressed,
    this.showBackButton,
    this.useGrid = false,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentDraft> onFinished;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final bool useGrid;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  State<TableSelectionPage> createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.state.tablesStatus == TablesStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            widget.controller.state.tablesStatus == TablesStatus.initial) {
          unawaited(widget.controller.loadTables());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FulfillmentFrame(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          final FulfillmentState state = widget.controller.state;
          return ChifaPageScaffold(
            pageKey: const Key('page-table-selection'),
            title: 'Elige tu mesa',
            subtitle: 'El mozo verificará tu presencia.',
            contentGap: 44,
            themeModeController: widget.themeModeController,
            onBackPressed: widget.onBackPressed,
            showBackButton: widget.showBackButton,
            initials: widget.initials,
            avatarPath: widget.avatarPath,
            onAvatarPressed: widget.onAvatarPressed,
            onCartPressed: widget.onCartPressed,
            cartItemCount: widget.cartItemCount,
            tableLabel: state.hasAssignedTable
                ? 'Mesa ${state.assignedTable?.code ?? ""}'
                : null,
            child: _buildContent(state),
          );
        },
      ),
    );
  }

  Widget _buildContent(FulfillmentState state) {
    return switch (state.tablesStatus) {
      TablesStatus.initial || TablesStatus.loading => const ChifaStateView(
        key: Key('tables-loading-state'),
        kind: ChifaStateKind.loading,
        title: 'Cargando mesas',
        message: 'Consultando disponibilidad en el restaurante.',
      ),
      TablesStatus.failure => ChifaStateView(
        key: const Key('tables-error-state'),
        kind: ChifaStateKind.error,
        title: 'No pudimos cargar las mesas',
        message:
            state.tablesFailure?.message ??
            'Inténtalo nuevamente en unos momentos.',
        actionLabel: 'Reintentar',
        onAction: widget.controller.retryTables,
      ),
      TablesStatus.success when state.tables.isEmpty => const ChifaStateView(
        key: Key('tables-empty-state'),
        kind: ChifaStateKind.empty,
        title: 'No hay mesas disponibles',
        message: 'Consulta nuevamente antes de enviar tu pedido.',
      ),
      TablesStatus.success => _TableList(
        state: state,
        useGrid: widget.useGrid,
        onSelect: widget.controller.selectTable,
        onFinish: _finish,
      ),
    };
  }

  void _finish() {
    final FulfillmentDraft? draft = widget.controller.completeLocal();
    if (draft != null) widget.onFinished(draft);
  }
}

class _TableList extends StatelessWidget {
  const _TableList({
    required this.state,
    required this.onSelect,
    required this.onFinish,
    this.useGrid = false,
  });

  final FulfillmentState state;
  final ValueChanged<String> onSelect;
  final VoidCallback onFinish;
  final bool useGrid;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final String? assignedId = state.assignedTableId;
    final bool hasAssigned = state.hasAssignedTable;
    final RestaurantTable? currentTable =
        state.assignedTable ?? state.selectedTable;

    final Widget tablesWidget = useGrid
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.tables.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              final RestaurantTable table = state.tables[index];
              return _SquareTableCard(
                table: table,
                selected: table.id == (state.selectedTableId ?? assignedId),
                isAssignedToUser: hasAssigned && table.id == assignedId,
                lockedToOtherTable: hasAssigned && table.id != assignedId,
                onSelect: onSelect,
              );
            },
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int index = 0; index < state.tables.length; index++) ...<Widget>[
                _TableCard(
                  table: state.tables[index],
                  selected:
                      state.tables[index].id ==
                      (state.selectedTableId ?? assignedId),
                  isAssignedToUser:
                      hasAssigned && state.tables[index].id == assignedId,
                  lockedToOtherTable:
                      hasAssigned && state.tables[index].id != assignedId,
                  onSelect: onSelect,
                ),
                if (index != state.tables.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (hasAssigned && currentTable != null) ...<Widget>[
          ChifaCard(
            key: const Key('assigned-table-card'),
            icon: LucideIcons.mapPin,
            iconColor: palette.brandRed,
            title: 'Mesa en uso: ${currentTable.code}',
            subtitle:
                'Estás usando esta mesa. No se permite seleccionar otra mesa.',
            minimumHeight: 77,
          ),
          const SizedBox(height: 14),
        ],
        tablesWidget,
        const SizedBox(height: 42),
        const ChifaCard(
          key: Key('table-verification-card'),
          icon: LucideIcons.mapPin,
          title: 'Verificación presencial',
          subtitle: 'Tu solicitud requiere aprobación del personal.',
          minimumHeight: 77,
        ),
        const SizedBox(height: 25),
        ChifaButton(
          key: const Key('table-finish'),
          label: hasAssigned && currentTable != null
              ? 'Continuar con Mesa ${currentTable.code}'
              : 'Usar esta mesa',
          height: 54,
          borderRadius: 14,
          onPressed:
              (state.selectedTable == null && !hasAssigned) ? null : onFinish,
        ),
      ],
    );
  }
}

class _SquareTableCard extends StatelessWidget {
  const _SquareTableCard({
    required this.table,
    required this.selected,
    required this.onSelect,
    this.isAssignedToUser = false,
    this.lockedToOtherTable = false,
  });

  final RestaurantTable table;
  final bool selected;
  final ValueChanged<String> onSelect;
  final bool isAssignedToUser;
  final bool lockedToOtherTable;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isOccupied = table.isOccupied && !isAssignedToUser;
    final bool isDisabled = isOccupied || lockedToOtherTable;
    final bool canTap =
        (table.isAvailable && !lockedToOtherTable) || isAssignedToUser;

    final IconData icon = isAssignedToUser
        ? LucideIcons.check
        : isOccupied
            ? LucideIcons.ban
            : lockedToOtherTable
                ? LucideIcons.lock
                : LucideIcons.armchair;

    final Color iconColor = isAssignedToUser
        ? palette.accentGold
        : isOccupied
            ? palette.brandRed
            : lockedToOtherTable
                ? palette.textSecondary
                : selected
                    ? palette.accentGold
                    : palette.brandRed;

    final Color borderColor = isAssignedToUser
        ? palette.accentGold
        : selected
            ? palette.accentGold
            : isOccupied
                ? palette.brandRed.withValues(alpha: 0.35)
                : palette.border;

    final Color backgroundColor = isAssignedToUser
        ? palette.accentGold.withValues(alpha: isDark ? 0.16 : 0.08)
        : selected
            ? palette.accentGold.withValues(alpha: isDark ? 0.12 : 0.06)
            : isDisabled
                ? (isDark
                    ? palette.surfaceTint.withValues(alpha: 0.5)
                    : palette.surfaceTint)
                : palette.surface;

    final String statusText;
    final Color statusColor;
    if (isAssignedToUser) {
      statusText = 'EN USO POR TI';
      statusColor = palette.accentGold;
    } else if (isOccupied) {
      statusText = 'OCUPADA';
      statusColor = palette.brandRed;
    } else if (lockedToOtherTable) {
      statusText = 'NO DISPONIBLE';
      statusColor = palette.textSecondary;
    } else if (selected) {
      statusText = 'SELECCIONADA';
      statusColor = palette.accentGold;
    } else {
      statusText = 'DISPONIBLE';
      statusColor = isDark
          ? const Color(0xFF68D391)
          : const Color(0xFF276749);
    }

    final String title = table.code.toLowerCase().startsWith('mesa ')
        ? table.code
        : 'Mesa ${table.code}';

    return AspectRatio(
      aspectRatio: 1.0,
      child: Semantics(
        button: canTap,
        selected: selected,
        enabled: canTap,
        label: '$title. $statusText',
        child: Material(
          key: ValueKey<String>('table-${table.id}'),
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: borderColor,
              width: (selected || isAssignedToUser) ? 2.0 : 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: canTap ? () => onSelect(table.id) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: isDark ? 0.16 : 0.08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? palette.textSecondary
                          : palette.textPrimary,
                    ),
                  ),
                  if (table.areaLabel != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      table.areaLabel!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.selected,
    required this.onSelect,
    this.isAssignedToUser = false,
    this.lockedToOtherTable = false,
  });

  final RestaurantTable table;
  final bool selected;
  final ValueChanged<String> onSelect;
  final bool isAssignedToUser;
  final bool lockedToOtherTable;

  @override
  Widget build(BuildContext context) {
    final String title = table.code.toLowerCase().startsWith('mesa ')
        ? table.code
        : 'Mesa ${table.code}';
    final String availability;
    if (isAssignedToUser) {
      availability = 'en uso por ti';
    } else if (lockedToOtherTable) {
      availability = 'no disponible (tienes otra mesa asignada)';
    } else {
      availability = table.isOccupied ? 'ocupada' : 'disponible';
    }
    final String subtitle = table.areaLabel == null
        ? availability[0].toUpperCase() + availability.substring(1)
        : '${table.areaLabel} · $availability';
    final String selectedLabel =
        selected && (table.isAvailable || isAssignedToUser)
            ? ', seleccionada'
            : '';
    final Widget? unavailableTrailing;
    if (isAssignedToUser) {
      unavailableTrailing = Icon(
        LucideIcons.check,
        color: context.appPalette.accentGold,
        size: 20,
      );
    } else if (!table.isAvailable || lockedToOtherTable) {
      unavailableTrailing = Icon(
        LucideIcons.chevronRight,
        color: context.appPalette.textSecondary,
        size: 17,
      );
    } else {
      unavailableTrailing = null;
    }

    final bool canTap =
        (table.isAvailable && !lockedToOtherTable) || isAssignedToUser;

    return ChifaCard(
      key: ValueKey<String>('table-${table.id}'),
      icon: LucideIcons.mapPin,
      title: title,
      subtitle: subtitle,
      minimumHeight: 95,
      trailing: unavailableTrailing,
      onTap: canTap ? () => onSelect(table.id) : null,
      semanticLabel: '$title. $subtitle$selectedLabel',
    );
  }
}

class PickupDetailsPage extends StatefulWidget {
  const PickupDetailsPage({
    required this.themeModeController,
    required this.controller,
    required this.onFinished,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentDraft> onFinished;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  State<PickupDetailsPage> createState() => _PickupDetailsPageState();
}

class _PickupDetailsPageState extends State<PickupDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    final FulfillmentDraft? draft = widget.controller.state.draft;
    _nameController = TextEditingController(
      text: draft?.mode == FulfillmentMode.pickup ? draft?.contactName : null,
    );
    _phoneController = TextEditingController(
      text: draft?.mode == FulfillmentMode.pickup ? draft?.contactPhone : null,
    );
    _nameController.addListener(() {
      if (!_showValidation && _nameController.text.isNotEmpty) {
        setState(() => _showValidation = true);
      }
    });
    _phoneController.addListener(() {
      if (!_showValidation && _phoneController.text.isNotEmpty) {
        setState(() => _showValidation = true);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FulfillmentFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-pickup-details'),
        title: 'Recoge tu pedido',
        subtitle: 'Retiro en el restaurante KAIRO.',
        contentGap: 54,
        themeModeController: widget.themeModeController,
        onBackPressed: widget.onBackPressed,
        showBackButton: widget.showBackButton,
        initials: widget.initials,
        avatarPath: widget.avatarPath,
        onAvatarPressed: widget.onAvatarPressed,
        onCartPressed: widget.onCartPressed,
        cartItemCount: widget.cartItemCount,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ChifaTextField(
                key: const Key('pickup-contact-name'),
                controller: _nameController,
                label: 'Nombre de contacto',
                hintText: 'Nombre de quien recoge',
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.name],
                validator: FulfillmentValidators.contactName,
                autovalidateMode: _autovalidateMode,
                isValid: _showValidation &&
                    _nameController.text.trim().isNotEmpty &&
                    FulfillmentValidators.contactName(_nameController.text) == null,
                labelHeight: 16,
                labelGap: 8,
                fieldHeight: 53,
                borderRadius: 12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                hintStyle: _hintStyle(context),
                inputStyle: _inputStyle(context),
                fillColor: _fieldFill(context),
              ),
              const SizedBox(height: 26),
              ChifaTextField(
                key: const Key('pickup-contact-phone'),
                controller: _phoneController,
                label: 'Celular de contacto',
                hintText: 'Número de contacto',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.telephoneNumber],
                validator: FulfillmentValidators.contactPhone,
                autovalidateMode: _autovalidateMode,
                isValid: _showValidation &&
                    _phoneController.text.trim().isNotEmpty &&
                    FulfillmentValidators.contactPhone(_phoneController.text) == null,
                onFieldSubmitted: (_) => _submit(),
                labelHeight: 16,
                labelGap: 8,
                fieldHeight: 53,
                borderRadius: 12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                hintStyle: _hintStyle(context),
                inputStyle: _inputStyle(context),
                fillColor: _fieldFill(context),
              ),
              const SizedBox(height: 45),
              const ChifaCard(
                key: Key('pickup-deposit-card'),
                icon: LucideIcons.wallet,
                title: 'Anticipo obligatorio',
                subtitle: '50 % verificado por administración.',
                minimumHeight: 77,
              ),
              const SizedBox(height: 16),
              const ChifaCard(
                key: Key('pickup-restaurant-card'),
                icon: LucideIcons.store,
                title: 'Sin sucursales',
                subtitle: 'Un único restaurante y punto de recojo.',
                minimumHeight: 77,
              ),
              const SizedBox(height: 40),
              ChifaButton(
                key: const Key('pickup-finish'),
                label: 'Continuar',
                height: 54,
                borderRadius: 14,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AutovalidateMode get _autovalidateMode {
    return _showValidation
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showValidation = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final FulfillmentDraft? draft = widget.controller.completePickup(
      contactName: _nameController.text,
      contactPhone: _phoneController.text,
    );
    if (draft != null) widget.onFinished(draft);
  }
}

class DeliveryDetailsPage extends StatefulWidget {
  const DeliveryDetailsPage({
    required this.themeModeController,
    required this.controller,
    required this.onFinished,
    this.savedAddresses,
    this.onBackPressed,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentDraft> onFinished;
  final List<CustomerAddress>? savedAddresses;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  @override
  State<DeliveryDetailsPage> createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    final FulfillmentDraft? draft = widget.controller.state.draft;
    final bool isDelivery = draft?.mode == FulfillmentMode.delivery;
    _addressController = TextEditingController(
      text: isDelivery ? draft?.deliveryAddress : null,
    );
    _nameController = TextEditingController(
      text: isDelivery ? draft?.contactName : null,
    );
    _phoneController = TextEditingController(
      text: isDelivery ? draft?.contactPhone : null,
    );
    _addressController.addListener(() {
      if (!_showValidation && _addressController.text.isNotEmpty) {
        setState(() => _showValidation = true);
      }
    });
    _nameController.addListener(() {
      if (!_showValidation && _nameController.text.isNotEmpty) {
        setState(() => _showValidation = true);
      }
    });
    _phoneController.addListener(() {
      if (!_showValidation && _phoneController.text.isNotEmpty) {
        setState(() => _showValidation = true);
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FulfillmentFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-delivery-details'),
        title: 'Lo llevamos a ti',
        subtitle: 'Registra tu dirección y contacto.',
        contentGap: 39,
        themeModeController: widget.themeModeController,
        onBackPressed: widget.onBackPressed,
        showBackButton: widget.showBackButton,
        initials: widget.initials,
        avatarPath: widget.avatarPath,
        onAvatarPressed: widget.onAvatarPressed,
        onCartPressed: widget.onCartPressed,
        cartItemCount: widget.cartItemCount,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ChifaTextField(
                key: const Key('delivery-address'),
                controller: _addressController,
                label: 'Dirección de entrega',
                hintText: 'Calle, número y referencia',
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.fullStreetAddress],
                validator: FulfillmentValidators.deliveryAddress,
                autovalidateMode: _autovalidateMode,
                isValid: _showValidation &&
                    _addressController.text.trim().isNotEmpty &&
                    FulfillmentValidators.deliveryAddress(_addressController.text) == null,
                labelHeight: 16,
                labelGap: 8,
                fieldHeight: 53,
                borderRadius: 12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                hintStyle: _hintStyle(context),
                inputStyle: _inputStyle(context),
                fillColor: _fieldFill(context),
              ),
              if (widget.savedAddresses != null &&
                  widget.savedAddresses!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  'Direcciones guardadas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFD1D5DB)
                        : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.savedAddresses!.map((CustomerAddress addr) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          key: Key('saved-address-chip-${addr.id}'),
                          avatar: const Icon(LucideIcons.mapPin, size: 14),
                          label: Text(addr.label),
                          tooltip: addr.fullText,
                          onPressed: () {
                            setState(() {
                              _addressController.text = addr.fullText;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 31),
              ChifaTextField(
                key: const Key('delivery-contact-name'),
                controller: _nameController,
                label: 'Nombre de contacto',
                hintText: 'Persona que recibirá',
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.name],
                validator: FulfillmentValidators.contactName,
                autovalidateMode: _autovalidateMode,
                isValid: _showValidation &&
                    _nameController.text.trim().isNotEmpty &&
                    FulfillmentValidators.contactName(_nameController.text) == null,
                labelHeight: 16,
                labelGap: 8,
                fieldHeight: 53,
                borderRadius: 12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                hintStyle: _hintStyle(context),
                inputStyle: _inputStyle(context),
                fillColor: _fieldFill(context),
              ),
              const SizedBox(height: 31),
              ChifaTextField(
                key: const Key('delivery-contact-phone'),
                controller: _phoneController,
                label: 'Celular de contacto',
                hintText: 'Número de contacto',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const <String>[AutofillHints.telephoneNumber],
                validator: FulfillmentValidators.contactPhone,
                autovalidateMode: _autovalidateMode,
                isValid: _showValidation &&
                    _phoneController.text.trim().isNotEmpty &&
                    FulfillmentValidators.contactPhone(_phoneController.text) == null,
                onFieldSubmitted: (_) => _submit(),
                labelHeight: 16,
                labelGap: 8,
                fieldHeight: 53,
                borderRadius: 12,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                hintStyle: _hintStyle(context),
                inputStyle: _inputStyle(context),
                fillColor: _fieldFill(context),
              ),
              const SizedBox(height: 46),
              const ChifaCard(
                key: Key('delivery-deposit-card'),
                icon: LucideIcons.info,
                title: 'Antes de cocina',
                subtitle: 'Anticipo del 50 % pendiente de verificar.',
                minimumHeight: 77,
              ),
              const SizedBox(height: 34),
              ChifaButton(
                key: const Key('delivery-finish'),
                label: 'Continuar',
                height: 54,
                borderRadius: 14,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AutovalidateMode get _autovalidateMode {
    return _showValidation
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showValidation = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final FulfillmentDraft? draft = widget.controller.completeDelivery(
      deliveryAddress: _addressController.text,
      contactName: _nameController.text,
      contactPhone: _phoneController.text,
    );
    if (draft != null) widget.onFinished(draft);
  }
}

class _FulfillmentFrame extends StatelessWidget {
  const _FulfillmentFrame({required this.child});

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
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(body: child),
    );
  }
}

TextStyle _hintStyle(BuildContext context) {
  return TextStyle(
    color: context.appPalette.textSecondary,
    fontFamily: AppTypography.bodyFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
}

TextStyle _inputStyle(BuildContext context) {
  return _hintStyle(context).copyWith(color: context.appPalette.textPrimary);
}

Color? _fieldFill(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF222425)
      : null;
}
