import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';

class AccessSimpleScaffold extends StatelessWidget {
  const AccessSimpleScaffold({
    required this.pageKey,
    required this.child,
    super.key,
  });

  final Key pageKey;
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
      child: Scaffold(
        key: pageKey,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                key: const Key('access-scroll'),
                padding: const EdgeInsets.only(bottom: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 7, 24, 24),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AccessKicker extends StatelessWidget {
  const AccessKicker({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'CHIFA ASIA  •  ${isDark ? 'NOCHE' : 'DÍA'}',
          maxLines: 1,
          style: TextStyle(
            color: context.appPalette.accentGold,
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 20 / 11,
          ),
        ),
      ),
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
        ? const Color(0xFFE3BD73)
        : const Color(0xFFF3CA83);

    return Semantics(
      container: true,
      label:
          'Chifa ASIA, cocina chifa contemporánea. Una tradición que enamora.',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth
              .clamp(0.0, 390.0)
              .toDouble();
          final double factor = width / 390;
          double scaled(double value) => value * factor;

          return SizedBox(
            key: const Key('login-hero'),
            width: double.infinity,
            height: scaled(308),
            child: ClipRect(
              child: ColoredBox(
                color: background,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    key: const Key('login-artwork-canvas'),
                    width: width,
                    height: scaled(308),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: scaled(239),
                          top: scaled(-82),
                          width: scaled(235),
                          height: scaled(235),
                          child: SvgPicture.asset(
                            'assets/images/m01/login_halo_$suffix.svg',
                          ),
                        ),
                        Positioned(
                          left: scaled(124),
                          top: scaled(39),
                          width: scaled(151),
                          height: scaled(151),
                          child: SvgPicture.asset(
                            'assets/images/m01/login_center_$suffix.svg',
                          ),
                        ),
                        Positioned(
                          left: scaled(45),
                          top: scaled(83),
                          width: scaled(72),
                          height: scaled(72),
                          child: SvgPicture.asset(
                            'assets/images/m01/login_detail_$suffix.svg',
                          ),
                        ),
                        Positioned(
                          left: scaled(28),
                          top: scaled(61),
                          width: scaled(48),
                          height: scaled(2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: gold.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: scaled(83),
                          top: scaled(50),
                          width: scaled(224),
                          height: scaled(35),
                          child: Text(
                            'CHIFA ASIA',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: gold,
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: scaled(18),
                              fontWeight: FontWeight.w700,
                              letterSpacing: scaled(3.2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: scaled(49),
                          top: scaled(81),
                          width: scaled(292),
                          height: scaled(12),
                          child: Text(
                            'COCINA CHIFA CONTEMPORÁNEA',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFD6B9AE)
                                  : const Color(0xFFFFE2CC),
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: scaled(9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: scaled(2),
                            ),
                          ),
                        ),
                        Positioned(
                          left: scaled(99),
                          top: scaled(103),
                          width: scaled(192),
                          height: scaled(144),
                          child: SvgPicture.asset(
                            'assets/images/m01/login_bowl_$suffix.svg',
                          ),
                        ),
                        Positioned(
                          left: scaled(35),
                          top: scaled(256),
                          width: scaled(320),
                          height: scaled(34),
                          child: Text(
                            'Una tradición que enamora',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: const Color(0xFFFFF8EC),
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: scaled(28),
                              fontWeight: FontWeight.w600,
                              height: 34 / 28,
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
        },
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

    return Semantics(
      liveRegion: true,
      label: '${isError ? 'Error' : 'Aviso'}: $message',
      child: Container(
        key: Key(isError ? 'auth-error' : 'auth-notice'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.10),
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
