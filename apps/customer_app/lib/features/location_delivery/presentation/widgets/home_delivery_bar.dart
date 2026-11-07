import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../m01_access/profile/domain/profile_models.dart';
import '../../application/location_delivery_controller.dart';
import '../../domain/location_models.dart';
import '../address_selector_modal.dart';
import '../map_location_picker_page.dart';

class HomeDeliveryBar extends StatelessWidget {
  const HomeDeliveryBar({
    required this.controller,
    super.key,
  });

  final LocationDeliveryController controller;

  IconData _iconForLabel(String? label) {
    if (label == null) return LucideIcons.mapPin;
    final String lower = label.toLowerCase();
    if (lower.contains('casa') || lower.contains('hogar')) {
      return LucideIcons.home;
    } else if (lower.contains('trabajo') || lower.contains('oficina')) {
      return LucideIcons.briefcase;
    }
    return LucideIcons.mapPin;
  }

  void _openAddressSelector(BuildContext context) {
    AddressSelectorModal.show(
      context,
      controller: controller,
      onAddressSelected: (CustomerAddress addr) {
        controller.selectAddress(addr);
      },
      onAddNewAddress: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext _) => MapLocationPickerPage(
              controller: controller,
              onAddressSaved: (CustomerAddress saved) {
                controller.selectAddress(saved);
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

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        final CustomerAddress? address = controller.selectedAddress;
        final DeliveryZoneQuote? zone = controller.currentZoneQuote;

        return AsiaPressable(
          onPressed: () => _openAddressSelector(context),
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.isDark ? AsiaColors.darkSurface : AsiaColors.white,
              borderRadius: AsiaRadii.brCard,
              border: Border.all(color: theme.border),
              boxShadow: !theme.isDark
                  ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
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
                    _iconForLabel(address?.label),
                    color: theme.brandCrimson,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'ENTREGAR EN',
                            style: AsiaTypography.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.brandCrimson,
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (zone != null && zone.isCovered) ...<Widget>[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                                borderRadius: AsiaRadii.brPill,
                              ),
                              child: Text(
                                zone.formattedFee,
                                style: AsiaTypography.labelSmall.copyWith(
                                  fontSize: 9,
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address != null
                            ? '${address.label}: ${address.address}'
                            : 'Seleccionar dirección de entrega...',
                        style: AsiaTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronDown,
                  color: theme.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
