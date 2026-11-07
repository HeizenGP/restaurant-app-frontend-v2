import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../../location_delivery/application/location_delivery_controller.dart';
import '../../location_delivery/presentation/address_selector_modal.dart';
import '../../location_delivery/presentation/map_location_picker_page.dart';
import '../../m01_access/profile/domain/profile_models.dart';
import '../choose_fulfillment/application/fulfillment_controller.dart';
import '../choose_fulfillment/domain/fulfillment_models.dart';

// ==============================================================================
// 1. SELECCIÓN DE MODALIDAD (Mesa, Delivery, Pickup)
// ==============================================================================

class FulfillmentModePage extends StatelessWidget {
  const FulfillmentModePage({
    required this.controller,
    required this.onBack,
    required this.onTableSelected,
    required this.onDeliverySelected,
    required this.onPickupSelected,
    super.key,
  });

  final FulfillmentController controller;
  final VoidCallback onBack;
  final VoidCallback onTableSelected;
  final VoidCallback onDeliverySelected;
  final VoidCallback onPickupSelected;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaScaffold(
      title: 'Tipo de entrega',
      subtitle: '¿Cómo deseas disfrutar tu pedido hoy?',
      showBack: true,
      onBack: onBack,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          _ModalityCard(
            key: const Key('modality-dine-in-card'),
            icon: LucideIcons.utensils,
            title: 'Comer en el Restaurante',
            subtitle: 'Elige tu mesa en nuestro salón y te llevamos los platos recién salidos del wok.',
            tagText: 'En Salón',
            onTap: () {
              controller.chooseMode(FulfillmentMode.local);
              onTableSelected();
            },
          ),
          const SizedBox(height: 14),
          _ModalityCard(
            key: const Key('modality-delivery-card'),
            icon: LucideIcons.bike,
            title: 'Envío a Domicilio',
            subtitle: 'Recibe tu pedido caliente y bien empacado directo en tu casa u oficina.',
            tagText: 'Delivery',
            onTap: () {
              controller.chooseMode(FulfillmentMode.delivery);
              onDeliverySelected();
            },
          ),
          const SizedBox(height: 14),
          _ModalityCard(
            key: const Key('modality-pickup-card'),
            icon: LucideIcons.shoppingBag,
            title: 'Recoger para Llevar',
            subtitle: 'Haz tu pedido con anticipación y pasa a recogerlo sin hacer colas.',
            tagText: 'Para Llevar',
            onTap: () {
              controller.chooseMode(FulfillmentMode.pickup);
              onPickupSelected();
            },
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: AsiaRadii.brMd,
              border: Border.all(color: theme.border, width: 0.8),
            ),
            child: Row(
              children: <Widget>[
                Icon(LucideIcons.shieldCheck, size: 20, color: theme.brandGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Aceptamos Yape, Plin y Efectivo. En KAIRO no cobramos ningún anticipo del 50 % para preparar tu pedido.',
                    style: AsiaTypography.bodySmall.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ==============================================================================
// 2. SELECCIÓN DE MESA EN SALÓN
// ==============================================================================

class TableSelectionPage extends StatefulWidget {
  const TableSelectionPage({
    required this.controller,
    required this.onBack,
    required this.onTableConfirmed,
    super.key,
  });

  final FulfillmentController controller;
  final VoidCallback onBack;
  final void Function(FulfillmentDraft draft) onTableConfirmed;

  @override
  State<TableSelectionPage> createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  String? _selectedTableId;

  @override
  void initState() {
    super.initState();
    widget.controller.loadTables();
  }

  void _confirmSelection() {
    if (_selectedTableId != null) {
      RestaurantTable? matched;
      for (final RestaurantTable t in widget.controller.state.tables) {
        if (t.id == _selectedTableId) {
          matched = t;
          break;
        }
      }
      if (matched != null && !matched.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${matched.code} está ocupada. Selecciona una mesa libre.',
            ),
            backgroundColor: context.asiaTheme.brandCrimson,
          ),
        );
        return;
      }
      widget.controller.selectTable(_selectedTableId!);
      final FulfillmentDraft draft = FulfillmentDraft.local(
        tableId: _selectedTableId!,
        tableCode: matched?.code,
      );
      widget.onTableConfirmed(draft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, _) {
        final FulfillmentState state = widget.controller.state;
        final List<RestaurantTable> tables = state.tables;

        return AsiaScaffold(
          title: 'Elige tu mesa',
          subtitle: 'Selecciona una mesa disponible en el restaurante',
          showBack: true,
          onBack: widget.onBack,
          bottomAction: AsiaButton(
            key: const Key('table-confirm-button'),
            label: _selectedTableId != null
                ? 'Confirmar Mesa'
                : 'Selecciona una mesa',
            enabled: _selectedTableId != null,
            onPressed: _selectedTableId != null ? _confirmSelection : null,
          ),
          body: state.tablesStatus == TablesStatus.loading
              ? const AsiaStateView(
                  kind: AsiaStateKind.loading,
                  title: 'Consultando mesas disponibles...',
                )
              : state.tablesFailure != null
              ? AsiaStateView(
                  kind: AsiaStateKind.error,
                  title: 'Error al consultar mesas',
                  message: state.tablesFailure?.message,
                  actionLabel: 'Reintentar',
                  onAction: widget.controller.retryTables,
                )
              : tables.isEmpty
              ? const AsiaStateView(
                  kind: AsiaStateKind.empty,
                  title: 'No hay mesas registradas en este momento',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: tables.length,
                      itemBuilder: (BuildContext context, int index) {
                        final RestaurantTable table = tables[index];
                        final bool isSelected = _selectedTableId == table.id;
                        final bool isAvailable = table.isAvailable;

                        return AsiaPressable(
                          onPressed: isAvailable
                              ? () =>
                                    setState(() => _selectedTableId = table.id)
                              : () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: <Widget>[
                                          const Icon(
                                            LucideIcons.circleAlert,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${table.code} se encuentra ocupada. Por favor, elige una mesa libre.',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: theme.brandCrimson,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                          borderRadius: AsiaRadii.brMd,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.brandCrimson
                                  : (isAvailable
                                        ? theme.surface
                                        : theme.surfaceSubtle),
                              borderRadius: AsiaRadii.brMd,
                              border: Border.all(
                                color: isSelected
                                    ? theme.brandCrimson
                                    : (isAvailable
                                          ? theme.border
                                          : theme.border.withValues(
                                              alpha: 0.4,
                                            )),
                                width: isSelected ? 1.5 : 0.8,
                              ),
                              boxShadow: isSelected && !theme.isDark
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: theme.brandCrimson.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  LucideIcons.utensils,
                                  size: 20,
                                  color: isSelected
                                      ? Colors.white
                                      : (isAvailable
                                            ? theme.brandGold
                                            : theme.textTertiary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  table.code,
                                  style: AsiaTypography.labelLarge.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : (isAvailable
                                              ? theme.textPrimary
                                              : theme.textTertiary),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  isAvailable ? 'Libre' : 'Ocupada',
                                  style: AsiaTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : (isAvailable
                                              ? theme.success
                                              : theme.textTertiary),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
        );
      },
    );
  }
}

// ==============================================================================
// 3. DETALLES DE ENTREGA (DELIVERY)
// ==============================================================================

class DeliveryDetailsPage extends StatefulWidget {
  const DeliveryDetailsPage({
    required this.onBack,
    required this.onDeliveryConfirmed,
    this.initialAddress,
    this.initialName,
    this.initialPhone,
    this.locationDeliveryController,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(FulfillmentDraft draft) onDeliveryConfirmed;
  final String? initialAddress;
  final String? initialName;
  final String? initialPhone;
  final LocationDeliveryController? locationDeliveryController;

  @override
  State<DeliveryDetailsPage> createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final String initialAddr =
        widget.initialAddress ??
        widget.locationDeliveryController?.selectedAddress?.fullText ??
        '';
    final String initialPh =
        widget.initialPhone ??
        widget.locationDeliveryController?.selectedAddress?.recipientPhone ??
        '';

    _addressCtrl = TextEditingController(text: initialAddr);
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _phoneCtrl = TextEditingController(text: initialPh);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final String address = _addressCtrl.text.trim();
    final String name = _nameCtrl.text.trim();
    final String phone = _phoneCtrl.text.trim();

    if (address.isEmpty || name.isEmpty || phone.isEmpty) return;

    final FulfillmentDraft draft = FulfillmentDraft.delivery(
      deliveryAddress: address,
      contactName: name,
      contactPhone: phone,
    );
    widget.onDeliveryConfirmed(draft);
  }

  void _changeAddress(BuildContext context) {
    if (widget.locationDeliveryController == null) return;
    AddressSelectorModal.show(
      context,
      controller: widget.locationDeliveryController!,
      onAddressSelected: (CustomerAddress addr) {
        setState(() {
          _addressCtrl.text = addr.fullText;
          if (addr.recipientPhone != null && addr.recipientPhone!.isNotEmpty) {
            _phoneCtrl.text = addr.recipientPhone!;
          }
        });
        widget.locationDeliveryController!.selectAddress(addr);
      },
      onAddNewAddress: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext _) => MapLocationPickerPage(
              controller: widget.locationDeliveryController!,
              onAddressSaved: (CustomerAddress saved) {
                setState(() {
                  _addressCtrl.text = saved.fullText;
                  if (saved.recipientPhone != null &&
                      saved.recipientPhone!.isNotEmpty) {
                    _phoneCtrl.text = saved.recipientPhone!;
                  }
                });
                widget.locationDeliveryController!.selectAddress(saved);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaScaffold(
      title: 'Datos de envío',
      subtitle: '¿A dónde enviamos tu comida?',
      showBack: true,
      onBack: widget.onBack,
      bottomAction: AsiaButton(
        key: const Key('delivery-confirm-button'),
        label: 'Continuar a Revisión',
        onPressed: _confirm,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (widget.locationDeliveryController != null) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.isDark ? AsiaColors.darkSurface : AsiaColors.white,
                borderRadius: AsiaRadii.brCard,
                border: Border.all(color: theme.border),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.brandCrimson.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.mapPin,
                      color: theme.brandCrimson,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'DIRECCIÓN GUARDADA',
                          style: AsiaTypography.labelSmall.copyWith(
                            color: theme.brandCrimson,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _addressCtrl.text.isNotEmpty
                              ? _addressCtrl.text
                              : 'No has seleccionado una dirección',
                          style: AsiaTypography.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _changeAddress(context),
                    child: Text(
                      'Cambiar',
                      style: AsiaTypography.labelMedium.copyWith(
                        color: theme.brandCrimson,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          AsiaTextField(
            semanticKey: const Key('delivery-address-input'),
            controller: _addressCtrl,
            label: 'Dirección de entrega completa',
            hintText: 'Ej. Av. Javier Prado Este 2450, Dpto 402',
            prefixIcon: LucideIcons.mapPin,
          ),
          const SizedBox(height: 14),
          AsiaTextField(
            semanticKey: const Key('delivery-name-input'),
            controller: _nameCtrl,
            label: 'Nombre de quien recibe',
            hintText: 'Ej. Heizen Guevara',
            prefixIcon: LucideIcons.user,
          ),
          const SizedBox(height: 14),
          AsiaTextField(
            semanticKey: const Key('delivery-phone-input'),
            controller: _phoneCtrl,
            label: 'Teléfono de contacto',
            hintText: 'Ej. 987654321',
            prefixIcon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ==============================================================================
// 4. DETALLES DE RECOJO (PICKUP)
// ==============================================================================

class PickupDetailsPage extends StatefulWidget {
  const PickupDetailsPage({
    required this.onBack,
    required this.onPickupConfirmed,
    this.initialName,
    this.initialPhone,
    super.key,
  });

  final VoidCallback onBack;
  final void Function(FulfillmentDraft draft) onPickupConfirmed;
  final String? initialName;
  final String? initialPhone;

  @override
  State<PickupDetailsPage> createState() => _PickupDetailsPageState();
}

class _PickupDetailsPageState extends State<PickupDetailsPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final String name = _nameCtrl.text.trim();
    final String phone = _phoneCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) return;

    final FulfillmentDraft draft = FulfillmentDraft.pickup(
      contactName: name,
      contactPhone: phone,
    );
    widget.onPickupConfirmed(draft);
  }

  @override
  Widget build(BuildContext context) {
    return AsiaScaffold(
      title: 'Datos de recojo',
      subtitle: '¿A nombre de quién preparamos el pedido?',
      showBack: true,
      onBack: widget.onBack,
      bottomAction: AsiaButton(
        key: const Key('pickup-confirm-button'),
        label: 'Continuar a Revisión',
        onPressed: _confirm,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          AsiaTextField(
            semanticKey: const Key('pickup-name-input'),
            controller: _nameCtrl,
            label: 'Nombre completo para entrega',
            hintText: 'Ej. Heizen Guevara',
            prefixIcon: LucideIcons.user,
          ),
          const SizedBox(height: 14),
          AsiaTextField(
            semanticKey: const Key('pickup-phone-input'),
            controller: _phoneCtrl,
            label: 'Teléfono de contacto',
            hintText: 'Ej. 987654321',
            prefixIcon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ==============================================================================
// COMPONENTE AUXILIAR: MODALITY CARD
// ==============================================================================

class _ModalityCard extends StatelessWidget {
  const _ModalityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tagText,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tagText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.brandCrimson.withValues(alpha: 0.1),
              borderRadius: AsiaRadii.brMd,
            ),
            child: Icon(icon, color: theme.brandCrimson, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      title,
                      style: AsiaTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surfaceSubtle,
                        borderRadius: AsiaRadii.brPill,
                        border: Border.all(color: theme.border, width: 0.8),
                      ),
                      child: Text(
                        tagText,
                        style: AsiaTypography.labelSmall.copyWith(
                          color: theme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AsiaTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 20, color: theme.textTertiary),
        ],
      ),
    );
  }
}
