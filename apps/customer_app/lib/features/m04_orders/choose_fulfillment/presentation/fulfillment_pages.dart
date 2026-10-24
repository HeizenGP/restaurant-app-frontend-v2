import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../app/theme/theme_mode_controller.dart';
import '../../../../../core/design_system/design_system.dart';
import '../application/fulfillment_contracts.dart';
import '../application/fulfillment_controller.dart';
import '../domain/fulfillment_models.dart';

class FulfillmentModePage extends StatelessWidget {
  const FulfillmentModePage({
    required this.themeModeController,
    required this.controller,
    required this.onModeSelected,
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentMode> onModeSelected;

  @override
  Widget build(BuildContext context) {
    return _FulfillmentFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-fulfillment-mode'),
        title: '¿Cómo disfrutarás?',
        subtitle: 'Elige una modalidad para tu pedido.',
        contentGap: 37,
        themeModeController: themeModeController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ChifaCard(
              key: const Key('fulfillment-mode-local'),
              icon: LucideIcons.store,
              title: 'Consumo en local',
              subtitle: 'Selecciona una mesa y espera validación',
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
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentDraft> onFinished;

  @override
  State<TableSelectionPage> createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.state.tablesStatus == TablesStatus.initial) {
      widget.controller.loadTables();
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
  });

  final FulfillmentState state;
  final ValueChanged<String> onSelect;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < state.tables.length; index++) ...<Widget>[
          _TableCard(
            table: state.tables[index],
            selected: state.tables[index].id == state.selectedTableId,
            onSelect: onSelect,
          ),
          if (index != state.tables.length - 1) const SizedBox(height: 10),
        ],
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
          label: 'Usar esta mesa',
          height: 54,
          borderRadius: 14,
          onPressed: state.selectedTable == null ? null : onFinish,
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.selected,
    required this.onSelect,
  });

  final RestaurantTable table;
  final bool selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final String title = table.code.toLowerCase().startsWith('mesa ')
        ? table.code
        : 'Mesa ${table.code}';
    final String availability = table.isOccupied ? 'ocupada' : 'disponible';
    final String subtitle = table.areaLabel == null
        ? availability[0].toUpperCase() + availability.substring(1)
        : '${table.areaLabel} · $availability';
    final String selectedLabel = selected && table.isAvailable
        ? ', seleccionada'
        : '';
    final Widget? unavailableTrailing = table.isAvailable
        ? null
        : Icon(
            LucideIcons.chevronRight,
            color: context.appPalette.textSecondary,
            size: 17,
          );
    return ChifaCard(
      key: ValueKey<String>('table-${table.id}'),
      icon: LucideIcons.mapPin,
      title: title,
      subtitle: subtitle,
      minimumHeight: 95,
      trailing: unavailableTrailing,
      onTap: table.isAvailable ? () => onSelect(table.id) : null,
      semanticLabel: '$title. $subtitle$selectedLabel',
    );
  }
}

class PickupDetailsPage extends StatefulWidget {
  const PickupDetailsPage({
    required this.themeModeController,
    required this.controller,
    required this.onFinished,
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentDraft> onFinished;

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
        subtitle: 'Retiro en el restaurante Chifa ASIA.',
        contentGap: 54,
        themeModeController: widget.themeModeController,
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
    super.key,
  });

  final ThemeModeController themeModeController;
  final FulfillmentController controller;
  final ValueChanged<FulfillmentDraft> onFinished;

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
                key: const Key('delivery-contact-name'),
                controller: _nameController,
                label: 'Nombre de contacto',
                hintText: 'Persona que recibirá',
                textInputAction: TextInputAction.next,
                autofillHints: const <String>[AutofillHints.name],
                validator: FulfillmentValidators.contactName,
                autovalidateMode: _autovalidateMode,
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
