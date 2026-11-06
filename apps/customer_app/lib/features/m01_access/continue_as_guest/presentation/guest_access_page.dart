import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/presentation/access_widgets.dart';

class GuestAccessPage extends StatelessWidget {
  const GuestAccessPage({
    required this.authController,
    this.showBackButton,
    super.key,
  });

  final AuthSessionController authController;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    void goToLogin() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/acceso');
      }
    }

    return PopScope(
      canPop: !authController.state.isBusy,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) authController.clearMessages();
      },
      child: KairoAuthScaffold(
        pageKey: const Key('page-invitado'),
        scrollKey: const Key('access-scroll'),
        showBackButton: showBackButton,
        onBackPressed: goToLogin,
        child: AnimatedBuilder(
          animation: authController,
          builder: (BuildContext context, Widget? child) {
            final AuthState state = authController.state;
            final bool loading = state.operation == AuthOperation.guest;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const KairoReveal(order: 0, child: _GuestBadge()),
                const SizedBox(height: 14),
                const KairoReveal(
                  order: 1,
                  child: KairoAuthTitle(
                    title: 'Explora nuestra carta',
                    subtitle:
                        'Disfruta de todas las especialidades sin registrarte previamente.',
                  ),
                ),
                if (state.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 16),
                  AccessMessageBanner(
                    message: state.errorMessage!,
                    isError: true,
                  ),
                ],
                const SizedBox(height: 20),
                const KairoReveal(order: 2, child: _GuestBenefitsCard()),
                const SizedBox(height: 24),
                KairoReveal(
                  order: 3,
                  child: KairoPrimaryButton(
                    key: const Key('guest-submit'),
                    label: 'Continuar como invitado',
                    isLoading: loading,
                    onPressed:
                        state.isBusy ? null : authController.continueAsGuest,
                  ),
                ),
                const SizedBox(height: 18),
                KairoAuthLinkRow(
                  question: '¿Prefieres acceder a tu cuenta?',
                  action: 'Inicia sesión',
                  actionKey: const Key('go-login-from-guest'),
                  onPressed: state.isBusy ? null : goToLogin,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GuestBadge extends StatelessWidget {
  const _GuestBadge();

  @override
  Widget build(BuildContext context) {
    final Color accent = kairoAccent(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(LucideIcons.compass, size: 14, color: accent),
            const SizedBox(width: 6),
            Text(
              'MODO INVITADO',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestBenefitsCard extends StatelessWidget {
  const _GuestBenefitsCard();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color divider = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF0E7DE);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1416) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEADFD5),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const _BenefitRow(
            icon: LucideIcons.utensilsCrossed,
            title: 'Carta gastronómica completa',
            subtitle: 'Revisa platos de autor, bebidas y especialidades.',
          ),
          Divider(height: 1, thickness: 1, color: divider, indent: 66),
          const _BenefitRow(
            icon: LucideIcons.receiptText,
            title: 'Pedidos en mesa o delivery',
            subtitle: 'Ordena al instante; tus pedidos se gestionan en esta sesión.',
          ),
          Divider(height: 1, thickness: 1, color: divider, indent: 66),
          _BenefitRow(
            icon: LucideIcons.sparkles,
            title: 'Sin contraseñas ni demoras',
            subtitle: 'Navega de inmediato; crea tu cuenta cuando lo desees.',
            textColor: palette.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Color accent = kairoAccent(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: textColor ?? palette.textPrimary,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
