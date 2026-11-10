import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/auth_models.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.authController,
    required this.isDarkMode,
    required this.onToggleTheme,
    super.key,
  });

  final AuthController authController;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final StaffUser? user = authController.currentUser;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AsiaSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Configuración',
              style: AsiaTypography.headingLarge.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ajustes del sistema, visualización y parámetros operativos de KAIRO.',
              style: AsiaTypography.bodyMedium.copyWith(
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: AsiaSpacing.xl),

            // Card 1: Preferencias de Pantalla / Tema
            _buildSettingsCard(
              context: context,
              title: 'Apariencia y Visualización',
              icon: LucideIcons.palette,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                    color: tokens.brandCrimson,
                  ),
                  title: Text(
                    'Modo Oscuro',
                    style: AsiaTypography.bodyMedium.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isDarkMode
                        ? 'Activado actualmente (ideal para entornos de baja luz)'
                        : 'Desactivado actualmente (modo claro tradicional)',
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  trailing: Switch.adaptive(
                    value: isDarkMode,
                    activeTrackColor: tokens.brandCrimson,
                    onChanged: (_) => onToggleTheme(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AsiaSpacing.lg),

            // Card 2: Información del Negocio
            _buildSettingsCard(
              context: context,
              title: 'Información del Restaurante',
              icon: LucideIcons.store,
              children: <Widget>[
                _buildInfoRow(
                  tokens,
                  label: 'Nombre comercial',
                  value: 'KAIRO · Alta Cocina Asiática',
                ),
                const Divider(),
                _buildInfoRow(
                  tokens,
                  label: 'Razón Social',
                  value: 'KAIRO RESTAURANTE S.A.C.',
                ),
                const Divider(),
                _buildInfoRow(
                  tokens,
                  label: 'Versión del Panel',
                  value: 'KAIRO Staff Portal v2.0.0 (Build 2026)',
                ),
              ],
            ),
            const SizedBox(height: AsiaSpacing.lg),

            // Card 3: Sesión y Colaborador
            if (user != null)
              _buildSettingsCard(
                context: context,
                title: 'Sesión Actual',
                icon: LucideIcons.shieldCheck,
                children: <Widget>[
                  _buildInfoRow(
                    tokens,
                    label: 'Nombre de usuario',
                    value: user.displayName,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    tokens,
                    label: 'Correo de acceso',
                    value: user.email,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    tokens,
                    label: 'Rol en el sistema',
                    value: user.roles.isNotEmpty
                        ? user.roles
                              .map((RoleCode r) => r.displayName)
                              .join(', ')
                        : 'Colaborador',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final AsiaThemeTokens tokens = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AsiaSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AsiaRadii.lg,
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 20, color: tokens.brandCrimson),
              const SizedBox(width: 10),
              Text(
                title,
                style: AsiaTypography.headingMedium.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    AsiaThemeTokens tokens, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: AsiaTypography.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: AsiaTypography.bodyMedium.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
