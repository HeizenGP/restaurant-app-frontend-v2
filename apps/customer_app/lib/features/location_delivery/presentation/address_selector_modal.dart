import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../../m01_access/profile/domain/profile_models.dart';
import '../application/location_delivery_controller.dart';
import 'map_location_picker_page.dart';

class AddressSelectorModal extends StatelessWidget {
  const AddressSelectorModal({
    required this.controller,
    required this.onAddressSelected,
    this.onAddNewAddress,
    super.key,
  });

  final LocationDeliveryController controller;
  final void Function(CustomerAddress address) onAddressSelected;
  final VoidCallback? onAddNewAddress;

  static Future<void> show(
    BuildContext context, {
    required LocationDeliveryController controller,
    required void Function(CustomerAddress address) onAddressSelected,
    VoidCallback? onAddNewAddress,
  }) {
    final AsiaTheme theme = context.asiaTheme;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) => AddressSelectorModal(
        controller: controller,
        onAddressSelected: (CustomerAddress addr) {
          onAddressSelected(addr);
          Navigator.of(ctx).pop();
        },
        onAddNewAddress: onAddNewAddress != null
            ? () {
                Navigator.of(ctx).pop();
                onAddNewAddress();
              }
            : () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) => MapLocationPickerPage(
                      controller: controller,
                      onAddressSaved: onAddressSelected,
                    ),
                  ),
                );
              },
      ),
    );
  }

  IconData _iconForLabel(String label) {
    final String lower = label.toLowerCase();
    if (lower.contains('casa') || lower.contains('hogar')) {
      return LucideIcons.home;
    } else if (lower.contains('trabajo') || lower.contains('oficina')) {
      return LucideIcons.briefcase;
    }
    return LucideIcons.mapPin;
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        final List<CustomerAddress> addresses = controller.savedAddresses;
        final CustomerAddress? selected = controller.selectedAddress;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Dirección de entrega',
                    style: AsiaTypography.titleMedium.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Selecciona dónde deseas recibir tu pedido de KAIRO',
                style: AsiaTypography.bodySmall.copyWith(color: theme.textSecondary),
              ),
              const SizedBox(height: 16),

              if (addresses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.isDark ? AsiaColors.darkSurface : AsiaColors.white,
                    borderRadius: AsiaRadii.brCard,
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(LucideIcons.mapPinOff, size: 36, color: theme.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        'Aún no tienes direcciones registradas',
                        style: AsiaTypography.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usa el mapa interactivo para seleccionar tu ubicación exacta.',
                        style: AsiaTypography.bodySmall.copyWith(color: theme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: addresses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final CustomerAddress item = addresses[index];
                      final bool isSelected = selected?.id == item.id;

                      return AsiaPressable(
                        onPressed: () => onAddressSelected(item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.brandCrimson.withValues(alpha: 0.08)
                                : (theme.isDark ? AsiaColors.darkSurface : AsiaColors.white),
                            borderRadius: AsiaRadii.brCard,
                            border: Border.all(
                              color: isSelected ? theme.brandCrimson : theme.border,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.brandCrimson.withValues(alpha: 0.15)
                                      : theme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _iconForLabel(item.label),
                                  color: isSelected ? theme.brandCrimson : theme.textSecondary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          item.label,
                                          style: AsiaTypography.labelMedium.copyWith(
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                            color: isSelected ? theme.brandCrimson : theme.textPrimary,
                                          ),
                                        ),
                                        if (item.isDefault) ...<Widget>[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: theme.brandCrimson.withValues(alpha: 0.12),
                                              borderRadius: AsiaRadii.brPill,
                                            ),
                                            child: Text(
                                              'Principal',
                                              style: AsiaTypography.labelSmall.copyWith(
                                                fontSize: 10,
                                                color: theme.brandCrimson,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.fullText,
                                      style: AsiaTypography.bodySmall.copyWith(color: theme.textSecondary),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected) ...<Widget>[
                                const SizedBox(width: 6),
                                Icon(LucideIcons.checkCircle2, color: theme.brandCrimson, size: 20),
                              ],
                              const SizedBox(width: 4),
                              // Edit button
                              IconButton(
                                icon: Icon(LucideIcons.pencil, size: 16, color: theme.textSecondary),
                                tooltip: 'Editar dirección',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext _) => MapLocationPickerPage(
                                        controller: controller,
                                        addressToEdit: item,
                                        onAddressSaved: onAddressSelected,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Delete button
                              IconButton(
                                icon: Icon(LucideIcons.trash2, size: 16, color: theme.textTertiary),
                                tooltip: 'Eliminar dirección',
                                onPressed: () async {
                                  final bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext dCtx) => AlertDialog(
                                      backgroundColor: theme.surface,
                                      title: Text('Eliminar dirección', style: AsiaTypography.titleMedium),
                                      content: Text('¿Deseas eliminar "${item.label}"?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(dCtx).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(dCtx).pop(true),
                                          child: Text('Eliminar', style: TextStyle(color: theme.brandCrimson)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await controller.deleteAddress(item.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // Button: Add new address with map
              AsiaButton(
                label: 'Agregar nueva ubicación en el mapa',
                leading: LucideIcons.mapPin,
                variant: AsiaButtonVariant.secondary,
                onPressed: onAddNewAddress,
              ),
            ],
          ),
        );
      },
    );
  }
}
