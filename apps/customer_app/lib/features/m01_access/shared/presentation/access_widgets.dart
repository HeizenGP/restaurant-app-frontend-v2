import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';

class AccessSimpleScaffold extends StatelessWidget {
  const AccessSimpleScaffold({
    required this.pageKey,
    required this.child,
    this.onBackPressed,
    this.showBackButton,
    super.key,
  });

  final Key pageKey;
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final VoidCallback? effectiveBack = onBackPressed ??
        ((ModalRoute.of(context)?.canPop ?? false)
            ? () => Navigator.of(context).pop()
            : null);
    final bool displayBack =
        (showBackButton ?? (ModalRoute.of(context)?.canPop ?? false)) &&
        effectiveBack != null;

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
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.mobilePageMaxWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 7, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            if (displayBack) ...<Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Semantics(
                                  button: true,
                                  label: 'Volver',
                                  onTap: effectiveBack,
                                  excludeSemantics: true,
                                  child: Tooltip(
                                    message: 'Volver',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        key: const Key('access-back-button'),
                                        onTap: effectiveBack,
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.control,
                                        ),
                                        child: Container(
                                          width: 41,
                                          height: 41,
                                          decoration: BoxDecoration(
                                            color: palette.surfaceTint,
                                            borderRadius:
                                                BorderRadius.circular(
                                                  AppRadii.control,
                                                ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            LucideIcons.arrowLeft,
                                            color: palette.brandRed,
                                            size: 21,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            child,
                          ],
                        ),
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
          'KAIRO  •  ${isDark ? 'NOCHE' : 'DÍA'}',
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
    final Color backgroundTop = isDark
        ? const Color(0xFF0A0708)
        : const Color(0xFF1E0A0E);
    final Color backgroundBottom = isDark
        ? const Color(0xFF190B0E)
        : const Color(0xFF381016);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color goldShimmer = Color(0xFFF6E8B1);

    return Semantics(
      container: true,
      label: 'KAIRO',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth
              .clamp(0.0, 390.0)
              .toDouble();
          final double factor = width / 390;
          double scaled(double value) => value * factor;

          final double heroHeight = scaled(220);

          return SizedBox(
            key: const Key('login-hero'),
            width: double.infinity,
            height: heroHeight,
            child: ClipRect(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[backgroundTop, backgroundBottom],
                  ),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    key: const Key('login-artwork-canvas'),
                    width: width,
                    height: heroHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Ambient radial aura
                        Center(
                          child: Container(
                            width: scaled(150),
                            height: scaled(150),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  const Color(0xFF8B222C).withValues(alpha: 0.30),
                                  goldAccent.withValues(alpha: 0.10),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Logo and Name only
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // KAIRO Seal Logo
                            Container(
                              width: scaled(68),
                              height: scaled(68),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B1A24),
                                borderRadius: BorderRadius.circular(scaled(19)),
                                border: Border.all(
                                  color: goldAccent,
                                  width: 2.2,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(0xFFB52B3A).withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: goldAccent.withValues(alpha: 0.20),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(scaled(4.5)),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(scaled(14)),
                                      border: Border.all(
                                        color: goldAccent.withValues(alpha: 0.50),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '凱',
                                    style: TextStyle(
                                      color: goldShimmer,
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: scaled(35),
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: scaled(12)),
                            // KAIRO Brand Name
                            Text(
                              'KAIRO',
                              style: TextStyle(
                                color: goldShimmer,
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: scaled(27),
                                fontWeight: FontWeight.w800,
                                letterSpacing: scaled(8.5),
                                height: 1.1,
                                shadows: <Shadow>[
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
