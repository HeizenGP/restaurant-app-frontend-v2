import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';

class AccessSimpleScaffold extends StatelessWidget {
  const AccessSimpleScaffold({
    required this.pageKey,
    required this.themeModeController,
    required this.child,
    super.key,
  });

  final Key pageKey;
  final ThemeModeController themeModeController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AccessKicker(themeModeController: themeModeController),
                  const SizedBox(height: 38),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AccessKicker extends StatelessWidget {
  const AccessKicker({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: <Widget>[
        Container(width: 36, height: 2, color: palette.accentGold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'CHIFA ASIA  •  ${isDark ? 'NOCHE' : 'DÍA'}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.textAccent,
              letterSpacing: 1.4,
              fontSize: 9,
            ),
          ),
        ),
        IconButton(
          key: const Key('access-theme-toggle'),
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          tooltip: isDark ? 'Activar tema claro' : 'Activar tema oscuro',
          onPressed: themeModeController.toggle,
          icon: Icon(
            isDark ? LucideIcons.sun : LucideIcons.moon,
            size: 19,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class LoginBrandHero extends StatelessWidget {
  const LoginBrandHero({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String suffix = isDark ? 'dark' : 'light';
    final Color background = isDark
        ? const Color(0xFF3D2024)
        : const Color(0xFF8A262D);
    final Color gold = isDark
        ? const Color(0xFFF1CB82)
        : const Color(0xFFF3CA83);

    return Semantics(
      container: true,
      label:
          'Chifa ASIA, cocina chifa contemporánea. Una tradición que enamora.',
      excludeSemantics: true,
      child: SizedBox(
        height: 308,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(color: background),
          child: ClipRect(
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: -84,
                  top: -82,
                  width: 235,
                  height: 235,
                  child: SvgPicture.asset(
                    'assets/images/m01/login_halo_$suffix.svg',
                  ),
                ),
                Positioned(
                  left: 124,
                  top: 39,
                  width: 151,
                  height: 151,
                  child: SvgPicture.asset(
                    'assets/images/m01/login_center_$suffix.svg',
                  ),
                ),
                Positioned(
                  left: 45,
                  top: 83,
                  width: 72,
                  height: 72,
                  child: SvgPicture.asset(
                    'assets/images/m01/login_detail_$suffix.svg',
                  ),
                ),
                Positioned(
                  left: 28,
                  top: 61,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(width: 48, height: 2, color: gold),
                      const SizedBox(height: 8),
                      const Text(
                        'CHIFA ASIA',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'COCINA CHIFA CONTEMPORÁNEA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          fontFamily: 'DM Sans',
                          fontSize: 7.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 99,
                  top: 103,
                  width: 192,
                  height: 144,
                  child: SvgPicture.asset(
                    'assets/images/m01/login_bowl_$suffix.svg',
                  ),
                ),
                const Positioned(
                  left: 28,
                  right: 28,
                  bottom: 26,
                  child: Text(
                    'Una tradición que enamora',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccessMessageBanner extends StatelessWidget {
  const AccessMessageBanner({
    required this.message,
    this.isError = false,
    super.key,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Color foreground = isError
        ? Theme.of(context).colorScheme.error
        : palette.success;
    final Color background = foreground.withValues(alpha: 0.10);

    return Semantics(
      liveRegion: true,
      label: '${isError ? 'Error' : 'Aviso'}: $message',
      child: Container(
        key: Key(isError ? 'auth-error' : 'auth-notice'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.control),
          border: Border.all(color: foreground.withValues(alpha: 0.34)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              isError ? LucideIcons.circleAlert : LucideIcons.circleCheck,
              color: foreground,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccessFeatureCard extends StatelessWidget {
  const AccessFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Container(
      constraints: const BoxConstraints(minHeight: 77),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.iconTile,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: palette.brandRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
