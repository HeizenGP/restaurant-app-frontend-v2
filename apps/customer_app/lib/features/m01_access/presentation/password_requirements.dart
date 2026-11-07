import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({required this.password, super.key});

  final String password;

  @override
  Widget build(BuildContext context) {
    final List<(String, bool)> requirements = <(String, bool)>[
      ('8 caracteres como mínimo', password.length >= 8),
      (
        'Una letra mayúscula y una minúscula',
        RegExp('[A-Z]').hasMatch(password) &&
            RegExp('[a-z]').hasMatch(password),
      ),
      ('Al menos un número', RegExp('[0-9]').hasMatch(password)),
    ];
    final AsiaTheme theme = context.asiaTheme;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      container: true,
      label: 'Requisitos de contraseña',
      child: Wrap(
        spacing: AsiaSpacing.md,
        runSpacing: AsiaSpacing.sm,
        children: requirements
            .map(((String, bool) requirement) {
              final (String label, bool met) = requirement;
              return AnimatedContainer(
                duration: reduceMotion
                    ? AsiaMotion.instant
                    : AsiaMotion.feedback,
                curve: AsiaMotion.emphasized,
                padding: const EdgeInsets.symmetric(
                  horizontal: AsiaSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (met ? theme.success : theme.surface).withValues(
                    alpha: met ? 0.1 : 0.65,
                  ),
                  borderRadius: AsiaRadii.brPill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      met ? LucideIcons.circleCheck : LucideIcons.circle,
                      size: 14,
                      color: met ? theme.success : theme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AsiaTypography.bodySmall.copyWith(
                        color: met ? theme.success : theme.textSecondary,
                        fontWeight: met ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
