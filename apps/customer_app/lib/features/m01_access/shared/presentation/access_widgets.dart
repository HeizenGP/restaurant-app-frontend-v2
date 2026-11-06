import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';

// ---------------------------------------------------------------------------
// KAIRO / Chifa ASIA — Minimalist Premium Access Design System
// Minimalist white aesthetic with corporate red accents, clear typography,
// and smooth native mobile interactions.
// ---------------------------------------------------------------------------

/// Corporate accent used for actions, links and focus highlights.
Color kairoAccent(BuildContext context) {
  return context.appPalette.brandRed;
}

/// The KAIRO wordmark.
class KairoWordmark extends StatelessWidget {
  const KairoWordmark({this.fontSize = 22, super.key});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Text(
      'KAIRO',
      textScaler: TextScaler.noScaling,
      style: TextStyle(
        color: palette.textPrimary,
        fontFamily: AppTypography.displayFontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 7,
        height: 1.0,
        decoration: TextDecoration.none,
      ),
    );
  }
}

/// Minimalist header showing KAIRO brand seal and title on a pure white background.
class KairoAuthHeader extends StatelessWidget {
  const KairoAuthHeader({
    this.compact = false,
    this.onBack,
    this.heroKey,
    this.canvasKey,
    super.key,
  });

  final bool compact;
  final VoidCallback? onBack;
  final Key? heroKey;
  final Key? canvasKey;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double topInset = MediaQuery.paddingOf(context).top;
    final double headerHeight = topInset + (compact ? 72.0 : 98.0);
    final Color pageBg = isDark ? palette.background : Colors.white;

    return Semantics(
      container: true,
      label: 'KAIRO',
      excludeSemantics: true,
      child: SizedBox(
        key: heroKey,
        width: double.infinity,
        height: headerHeight,
        child: Material(
          color: pageBg,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double canvasWidth = math.min(constraints.maxWidth, 390.0);
              return Stack(
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      key: canvasKey,
                      width: canvasWidth,
                      height: headerHeight,
                      child: Padding(
                        padding: EdgeInsets.only(top: topInset + 8, left: 16, right: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: onBack == null
                              ? Hero(
                                  tag: 'kairo-brand-seal',
                                  child: KairoBrandSeal(size: compact ? 38 : 46),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (onBack != null)
                    Positioned(
                      left: 16,
                      top: topInset + 6,
                      child: _HeaderBackButton(onPressed: onBack!),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: 'Volver',
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: 'Volver',
        child: Material(
          color: isDark ? palette.surface : const Color(0xFFF7F5F2),
          shape: CircleBorder(
            side: BorderSide(
              color: isDark ? palette.border : const Color(0xFFE8E0D5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('access-back-button'),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: 40,
              child: Icon(
                LucideIcons.arrowLeft,
                color: palette.brandRed,
                size: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimalist Page Scaffold for access screens: uniform white background,
/// clean responsive scroll view and consistent layout.
class KairoAuthScaffold extends StatelessWidget {
  const KairoAuthScaffold({
    required this.pageKey,
    required this.child,
    this.scrollKey,
    this.contentKey,
    this.heroKey,
    this.canvasKey,
    this.compactHeader = true,
    this.onBackPressed,
    this.showBackButton,
    this.footer,
    super.key,
  });

  final Key pageKey;
  final Widget child;
  final Key? scrollKey;
  final Key? contentKey;
  final Key? heroKey;
  final Key? canvasKey;
  final bool compactHeader;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color pageBg = isDark ? palette.background : Colors.white;
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;
    final VoidCallback? effectiveBack =
        onBackPressed ?? (canPop ? () => Navigator.of(context).pop() : null);
    final bool displayBack =
        (showBackButton ?? canPop) && effectiveBack != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: pageBg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        key: pageKey,
        backgroundColor: pageBg,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              key: scrollKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  KairoAuthHeader(
                    compact: compactHeader,
                    onBack: displayBack ? effectiveBack : null,
                    heroKey: heroKey,
                    canvasKey: canvasKey,
                  ),
                  SizedBox(
                    key: contentKey,
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.mobilePageMaxWidth,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            MediaQuery.paddingOf(context).bottom + 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              child,
                              if (footer != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 18),
                                  child: footer!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


/// Modern filled input with floating label, animated focus ring and icon tile.
class KairoAuthField extends StatefulWidget {
  const KairoAuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.onFieldSubmitted,
    this.trailing,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? trailing;
  final TextCapitalization textCapitalization;

  @override
  State<KairoAuthField> createState() => _KairoAuthFieldState();
}

class _KairoAuthFieldState extends State<KairoAuthField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focused != _focusNode.hasFocus) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = kairoAccent(context);
    final Color error = Theme.of(context).colorScheme.error;
    final Color idleFill = isDark ? const Color(0xFF1E2129) : const Color(0xFFF9FAFB);
    final Color focusFill = isDark ? const Color(0xFF262A34) : Colors.white;
    final Color idleBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE5E7EB);

    OutlineInputBorder border(Color color, [double width = 1.2]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              color: palette.textPrimary,
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              if (_focused)
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.20 : 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            onFieldSubmitted: widget.onFieldSubmitted,
            textCapitalization: widget.textCapitalization,
            cursorColor: accent,
            style: TextStyle(
              color: palette.textPrimary,
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              filled: true,
              fillColor: _focused ? focusFill : idleFill,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              hintStyle: TextStyle(
                color: palette.textSecondary.withValues(alpha: 0.6),
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 15,
              ),
              errorStyle: TextStyle(
                color: error,
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              errorMaxLines: 2,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 18, right: 14),
                child: Icon(
                  widget.icon,
                  size: 21,
                  color: _focused ? accent : palette.textSecondary.withValues(alpha: 0.8),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 52,
                minHeight: 52,
              ),
              suffixIcon: widget.trailing,
              enabledBorder: border(idleBorder),
              disabledBorder: border(idleBorder.withValues(alpha: 0.5)),
              focusedBorder: border(accent, 1.8),
              errorBorder: border(error.withValues(alpha: 0.7)),
              focusedErrorBorder: border(error, 1.6),
              border: border(idleBorder),
            ),
          ),
        ),
      ],
    );
  }
}

/// Primary call-to-action in corporate Chifa ASIA red.
class KairoPrimaryButton extends StatefulWidget {
  const KairoPrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon = LucideIcons.arrowRight,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  State<KairoPrimaryButton> createState() => _KairoPrimaryButtonState();
}

class _KairoPrimaryButtonState extends State<KairoPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool enabled = widget.onPressed != null && !widget.isLoading;
    const Color foreground = Colors.white;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: widget.onPressed == null && !widget.isLoading ? 0.45 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: palette.brandRed,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.brandRed.withValues(
                    alpha: _pressed ? 0.12 : 0.22,
                  ),
                  blurRadius: _pressed ? 6 : 14,
                  offset: Offset(0, _pressed ? 2 : 4),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: enabled ? widget.onPressed : null,
                onHighlightChanged: (bool value) =>
                    setState(() => _pressed = value && enabled),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 54),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: widget.isLoading
                          ? const SizedBox.square(
                              key: ValueKey<String>('loading'),
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: foreground,
                              ),
                            )
                          : Row(
                              key: const ValueKey<String>('label'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    widget.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: foreground,
                                      fontFamily: AppTypography.bodyFontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                if (widget.icon != null) ...<Widget>[
                                  const SizedBox(width: 8),
                                  Icon(
                                    widget.icon,
                                    size: 18,
                                    color: foreground,
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary action (e.g. explore as guest).
class KairoSecondaryButton extends StatelessWidget {
  const KairoSecondaryButton({
    required this.label,
    required this.icon,
    this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = kairoAccent(context);

    return Material(
      color: isDark ? const Color(0xFF1A1416) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E4E9),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 18, color: palette.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Title + subtitle block used at the top of each form.
class KairoAuthTitle extends StatelessWidget {
  const KairoAuthTitle({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: palette.textPrimary,
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: palette.textSecondary,
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Inline "question + link" row (wraps on narrow screens).
class KairoAuthLinkRow extends StatelessWidget {
  const KairoAuthLinkRow({
    required this.question,
    required this.action,
    this.onPressed,
    this.actionKey,
    super.key,
  });

  final String question;
  final String action;
  final VoidCallback? onPressed;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          question,
          style: TextStyle(
            color: palette.textSecondary,
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 13.5,
          ),
        ),
        TextButton(
          key: actionKey,
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: const Size(48, 40),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            foregroundColor: kairoAccent(context),
          ),
          child: Text(
            action,
            style: const TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fades and slides its child in on first build; [order] staggers siblings.
class KairoReveal extends StatelessWidget {
  const KairoReveal({required this.order, required this.child, super.key});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + order * 70),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (BuildContext context, double t, Widget? child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: child,
          ),
        );
      },
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: foreground.withValues(alpha: 0.30)),
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
                    ?.copyWith(color: foreground, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
