import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../shared/application/auth_session_controller.dart';
import '../shared/domain/auth_models.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    required this.controller,
    required this.onRegisterTap,
    required this.onGuestTap,
    required this.onForgotPasswordTap,
    required this.onSuccess,
    this.onToggleTheme,
    super.key,
  });

  final AuthSessionController controller;
  final VoidCallback onRegisterTap;
  final VoidCallback onGuestTap;
  final VoidCallback onForgotPasswordTap;
  final VoidCallback onSuccess;
  final VoidCallback? onToggleTheme;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  static const double _wideBreakpoint = 860;
  static const double _formMaxWidth = 460;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode(debugLabel: 'signin-email');
  final FocusNode _passwordFocus = FocusNode(debugLabel: 'signin-password');

  late final AnimationController _entranceController;
  Timer? _slowConnectionTimer;
  String? _emailError;
  String? _passwordError;
  bool _submittedOnce = false;
  bool _motionInitialized = false;
  bool _isTakingLong = false;
  bool _loginSucceeded = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: AsiaMotion.entrance,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionInitialized) return;
    _motionInitialized = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entranceController.value = 1;
    } else {
      _entranceController.forward();
    }
  }

  @override
  void dispose() {
    _slowConnectionTimer?.cancel();
    _entranceController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final String? emailError = AccessValidators.email(_emailController.text);
    final String? passwordError = AccessValidators.loginPassword(
      _passwordController.text,
    );
    setState(() {
      _submittedOnce = true;
      _emailError = emailError;
      _passwordError = passwordError;
    });
    if (emailError != null) {
      _emailFocus.requestFocus();
      return false;
    }
    if (passwordError != null) {
      _passwordFocus.requestFocus();
      return false;
    }
    return true;
  }

  void _onEmailChanged(String value) {
    if (!_submittedOnce && _emailError == null) return;
    final String? nextError = AccessValidators.email(value);
    if (nextError != _emailError) setState(() => _emailError = nextError);
  }

  void _onPasswordChanged(String value) {
    if (!_submittedOnce && _passwordError == null) return;
    final String? nextError = AccessValidators.loginPassword(value);
    if (nextError != _passwordError) {
      setState(() => _passwordError = nextError);
    }
  }

  Future<void> _handleSignIn() async {
    if (widget.controller.state.isBusy) return;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    widget.controller.clearMessages();
    if (!_validate()) {
      unawaited(HapticFeedback.mediumImpact());
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isTakingLong = false;
      _loginSucceeded = false;
    });
    _slowConnectionTimer?.cancel();
    _slowConnectionTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && widget.controller.state.isBusy) {
        setState(() => _isTakingLong = true);
      }
    });

    unawaited(HapticFeedback.selectionClick());
    final bool ok = await widget.controller.login(
      LoginInput(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
    _slowConnectionTimer?.cancel();
    if (!mounted) return;

    if (!ok) {
      setState(() => _isTakingLong = false);
      unawaited(HapticFeedback.mediumImpact());
      if (mounted) _passwordFocus.requestFocus();
      return;
    }

    setState(() {
      _isTakingLong = false;
      _loginSucceeded = true;
    });
    unawaited(HapticFeedback.lightImpact());
    final Duration successPause = reduceMotion
        ? AsiaMotion.instant
        : AsiaMotion.standard;
    await Future<void>.delayed(successPause);
    if (mounted) widget.onSuccess();
  }

  Future<void> _handleGoogleSignIn() async {
    if (widget.controller.state.isBusy ||
        !widget.controller.googleSignInAvailable) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    widget.controller.clearMessages();
    unawaited(HapticFeedback.selectionClick());
    final bool ok = await widget.controller.loginWithGoogle();
    if (!mounted || !ok) return;
    unawaited(HapticFeedback.lightImpact());
    if (!MediaQuery.disableAnimationsOf(context)) {
      await Future<void>.delayed(AsiaMotion.standard);
    }
    if (mounted) widget.onSuccess();
  }

  void _openPasswordRecovery() {
    if (widget.controller.state.isBusy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.controller.clearMessages();
    HapticFeedback.selectionClick();
    widget.onForgotPasswordTap();
  }

  void _openRegistration() {
    if (widget.controller.state.isBusy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.controller.clearMessages();
    HapticFeedback.selectionClick();
    widget.onRegisterTap();
  }

  void _openGuestAccess() {
    if (widget.controller.state.isBusy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.controller.clearMessages();
    HapticFeedback.selectionClick();
    widget.onGuestTap();
  }

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(begin, end, curve: AsiaMotion.entranceCurve),
    );
  }

  Widget _entrance({
    required Widget child,
    required double begin,
    required double end,
    double verticalOffset = 0.06,
  }) {
    final Animation<double> animation = _interval(begin, end);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, verticalOffset),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final Duration feedbackDuration = reduceMotion
        ? AsiaMotion.instant
        : AsiaMotion.standard;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.controller,
        _entranceController,
      ]),
      builder: (BuildContext context, _) {
        final AuthState state = widget.controller.state;
        final bool isBusy = state.isBusy;

        return Scaffold(
          key: const Key('signin-page'),
          resizeToAvoidBottomInset: true,
          backgroundColor: theme.bg,
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.9, -0.95),
                        radius: 1.35,
                        colors: <Color>[
                          theme.brandCrimson.withValues(
                            alpha: theme.isDark ? 0.12 : 0.055,
                          ),
                          theme.brandGold.withValues(
                            alpha: theme.isDark ? 0.045 : 0.025,
                          ),
                          theme.bg,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool isWide = constraints.maxWidth >= _wideBreakpoint;
                    final bool keyboardOpen =
                        MediaQuery.viewInsetsOf(context).bottom > 0 ||
                        constraints.maxHeight < 700;
                    final double horizontalPadding = isWide
                        ? AsiaSpacing.xxxl
                        : AsiaSpacing.lg;
                    final double verticalPadding = keyboardOpen
                        ? AsiaSpacing.md
                        : AsiaSpacing.xl;
                    final double minimumHeight =
                        constraints.maxHeight - (verticalPadding * 2);

                    return SingleChildScrollView(
                      key: const Key('signin-scroll-view'),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        verticalPadding,
                        horizontalPadding,
                        keyboardOpen ? AsiaSpacing.xl : AsiaSpacing.xxxl,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minimumHeight > 0 ? minimumHeight : 0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (widget.onToggleTheme != null)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: _ThemeToggle(
                                      isDark: theme.isDark,
                                      onPressed: isBusy
                                          ? null
                                          : widget.onToggleTheme,
                                    ),
                                  ),
                                if (isWide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: _entrance(
                                          begin: 0,
                                          end: 0.72,
                                          verticalOffset: 0.03,
                                          child: _BrandBlock(
                                            isDark: theme.isDark,
                                            isWide: true,
                                            compact: false,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AsiaSpacing.xxxl),
                                      SizedBox(
                                        width: _formMaxWidth,
                                        child: _entrance(
                                          begin: 0.18,
                                          end: 1,
                                          child: _buildFormPanel(
                                            context,
                                            state: state,
                                            isBusy: isBusy,
                                            feedbackDuration: feedbackDuration,
                                            useSurface: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else ...<Widget>[
                                  _entrance(
                                    begin: 0,
                                    end: 0.65,
                                    verticalOffset: 0.035,
                                    child: _BrandBlock(
                                      isDark: theme.isDark,
                                      isWide: false,
                                      compact: keyboardOpen,
                                    ),
                                  ),
                                  SizedBox(
                                    height: keyboardOpen
                                        ? AsiaSpacing.lg
                                        : AsiaSpacing.xxl,
                                  ),
                                  Align(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: _formMaxWidth,
                                      ),
                                      child: _entrance(
                                        begin: 0.16,
                                        end: 1,
                                        child: _buildFormPanel(
                                          context,
                                          state: state,
                                          isBusy: isBusy,
                                          feedbackDuration: feedbackDuration,
                                          useSurface: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormPanel(
    BuildContext context, {
    required AuthState state,
    required bool isBusy,
    required Duration feedbackDuration,
    required bool useSurface,
  }) {
    final AsiaTheme theme = context.asiaTheme;
    final Widget content = FocusTraversalGroup(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Bienvenido de vuelta',
              style: AsiaTypography.brandDisplay.copyWith(
                color: theme.textPrimary,
                fontSize: useSurface ? 38 : 32,
              ),
            ),
            const SizedBox(height: AsiaSpacing.sm),
            Text(
              'Ingresa para reservar tu próxima experiencia KAIRO.',
              style: AsiaTypography.bodyMedium.copyWith(
                color: theme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AsiaSpacing.xl),
            _StatusArea(
              errorMessage: state.errorMessage,
              noticeMessage: state.noticeMessage,
              duration: feedbackDuration,
            ),
            if (state.errorMessage != null || state.noticeMessage != null)
              const SizedBox(height: AsiaSpacing.base),
            AsiaTextField(
              semanticKey: const Key('signin-email-input'),
              controller: _emailController,
              focusNode: _emailFocus,
              label: 'Correo electrónico',
              hintText: 'tu@correo.com',
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[
                AutofillHints.username,
                AutofillHints.email,
              ],
              autocorrect: false,
              enableSuggestions: false,
              focusColor: theme.brandGold,
              errorText: _emailError,
              enabled: !isBusy,
              onChanged: _onEmailChanged,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AsiaSpacing.base),
            AsiaTextField(
              semanticKey: const Key('signin-password-input'),
              controller: _passwordController,
              focusNode: _passwordFocus,
              label: 'Contraseña',
              hintText: 'Ingresa tu contraseña',
              prefixIcon: LucideIcons.lockKeyhole,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.password],
              autocorrect: false,
              enableSuggestions: false,
              focusColor: theme.brandGold,
              errorText: _passwordError,
              enabled: !isBusy,
              onChanged: _onPasswordChanged,
              onSubmitted: (_) => _handleSignIn(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AsiaPressable(
                key: const Key('signin-forgot-password-link'),
                onPressed: isBusy ? null : _openPasswordRecovery,
                semanticLabel: 'Recuperar contraseña',
                borderRadius: AsiaRadii.brSm,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AsiaSpacing.sm,
                      vertical: AsiaSpacing.md,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: AsiaTypography.bodySmall.copyWith(
                          color: theme.brandCrimson,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AsiaSpacing.md),
            AnimatedScale(
              duration: feedbackDuration,
              curve: AsiaMotion.emphasized,
              scale: _loginSucceeded ? 0.985 : 1,
              child: AsiaButton(
                key: const Key('signin-submit-button'),
                label: _loginSucceeded ? 'Acceso confirmado' : 'Iniciar sesión',
                loadingLabel: 'Verificando acceso…',
                onPressed: _handleSignIn,
                isLoading: isBusy,
                enabled: !isBusy,
                trailing: _loginSucceeded
                    ? LucideIcons.circleCheck
                    : LucideIcons.arrowRight,
                height: 56,
              ),
            ),
            AnimatedSwitcher(
              duration: feedbackDuration,
              child: _isTakingLong
                  ? Padding(
                      key: const ValueKey<String>('slow-connection'),
                      padding: const EdgeInsets.only(top: AsiaSpacing.md),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          'La conexión está tardando un poco. Seguimos intentando de forma segura.',
                          textAlign: TextAlign.center,
                          style: AsiaTypography.bodySmall.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('connection-ready'),
                    ),
            ),
            const SizedBox(height: AsiaSpacing.md),
            _GoogleSignInButton(
              isDark: theme.isDark,
              isLoading: state.operation == AuthOperation.googleSignIn,
              isConfigured: widget.controller.googleSignInAvailable,
              onPressed: isBusy ? null : _handleGoogleSignIn,
            ),
            const SizedBox(height: AsiaSpacing.md),
            AsiaButton(
              key: const Key('signin-guest-button'),
              label: 'Continuar como invitado',
              variant: AsiaButtonVariant.secondary,
              onPressed: isBusy ? null : _openGuestAccess,
              leading: LucideIcons.userRound,
            ),
            const SizedBox(height: AsiaSpacing.xl),
            if (MediaQuery.textScalerOf(context).scale(1) > 1.35)
              Text(
                '¿PRIMERA VEZ EN KAIRO?',
                textAlign: TextAlign.center,
                style: AsiaTypography.labelSmall.copyWith(
                  color: theme.textTertiary,
                  letterSpacing: 1.1,
                ),
              )
            else
              Row(
                children: <Widget>[
                  Expanded(child: Divider(color: theme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AsiaSpacing.md,
                    ),
                    child: Text(
                      '¿PRIMERA VEZ EN KAIRO?',
                      style: AsiaTypography.labelSmall.copyWith(
                        color: theme.textTertiary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.border)),
                ],
              ),
            const SizedBox(height: AsiaSpacing.base),
            AsiaPressable(
              key: const Key('signin-to-register-link'),
              onPressed: isBusy ? null : _openRegistration,
              semanticLabel: 'Crear una cuenta KAIRO',
              borderRadius: AsiaRadii.brMd,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      'Crear una cuenta',
                      style: AsiaTypography.labelLarge.copyWith(
                        color: theme.brandCrimson,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AsiaSpacing.sm),
                    Icon(
                      LucideIcons.arrowUpRight,
                      size: 18,
                      color: theme.brandCrimson,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AsiaSpacing.lg),
            Semantics(
              label: 'Tus credenciales se almacenan de forma segura',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    LucideIcons.shieldCheck,
                    size: 15,
                    color: theme.textTertiary,
                  ),
                  const SizedBox(width: AsiaSpacing.sm),
                  Flexible(
                    child: Text(
                      'Tus credenciales se almacenan de forma segura',
                      textAlign: TextAlign.center,
                      style: AsiaTypography.bodySmall.copyWith(
                        color: theme.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!useSurface) return content;
    return Container(
      padding: const EdgeInsets.all(AsiaSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: theme.isDark ? 0.96 : 0.92),
        borderRadius: AsiaRadii.brLg,
        border: Border.all(color: theme.border, width: 0.8),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.textPrimary.withValues(
              alpha: theme.isDark ? 0.2 : 0.07,
            ),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: content,
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isDark,
    required this.isLoading,
    required this.isConfigured,
    required this.onPressed,
  });

  final bool isDark;
  final bool isLoading;
  final bool isConfigured;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = isConfigured && onPressed != null;
    final Color background = isDark ? const Color(0xFF131314) : Colors.white;
    final Color foreground = isDark
        ? const Color(0xFFE3E3E3)
        : const Color(0xFF1F1F1F);
    return Tooltip(
      message: isConfigured
          ? 'Continuar con Google'
          : 'Configura GOOGLE_WEB_CLIENT_ID para habilitar Google',
      child: AsiaPressable(
        key: const Key('signin-google-button'),
        onPressed: enabled ? onPressed : null,
        semanticLabel: isConfigured
            ? 'Continuar con Google'
            : 'Continuar con Google, no configurado',
        borderRadius: AsiaRadii.brPill,
        child: AnimatedOpacity(
          duration: MediaQuery.disableAnimationsOf(context)
              ? AsiaMotion.instant
              : AsiaMotion.feedback,
          opacity: enabled ? 1 : 0.56,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: AsiaRadii.brPill,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF8E918F)
                    : const Color(0xFF747775),
              ),
            ),
            child: Row(
              children: <Widget>[
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else
                  Image.asset(
                    isDark
                        ? 'assets/images/m01/google_signin_dark_square.png'
                        : 'assets/images/m01/google_signin_light_square.png',
                    width: 24,
                    height: 24,
                    filterQuality: FilterQuality.high,
                  ),
                Expanded(
                  child: Text(
                    isLoading
                        ? 'Conectando con Google…'
                        : 'Continuar con Google',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: foreground),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({
    required this.isDark,
    required this.isWide,
    required this.compact,
  });

  final bool isDark;
  final bool isWide;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    if (compact) {
      return Center(
        child: KairoLogo(
          variant: KairoLogoVariant.horizontal,
          emblemSize: 46,
          isDark: isDark,
          showSubtitle: false,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: <Widget>[
        KairoLogo(
          variant: KairoLogoVariant.vertical,
          emblemSize: isWide ? 116 : 84,
          isDark: isDark,
          showSubtitle: true,
        ),
        if (isWide) ...<Widget>[
          const SizedBox(height: AsiaSpacing.xxl),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              'Sabores precisos. Hospitalidad cálida. Una experiencia que empieza aquí.',
              style: AsiaTypography.brandDisplay.copyWith(
                color: theme.textPrimary,
                fontSize: 36,
                height: 1.08,
              ),
            ),
          ),
          const SizedBox(height: AsiaSpacing.base),
          Container(width: 48, height: 2, color: theme.brandGold),
        ],
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onPressed});

  final bool isDark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final String label = isDark ? 'Usar modo claro' : 'Usar modo oscuro';
    return AsiaPressable(
      key: const Key('signin-theme-toggle'),
      onPressed: onPressed,
      semanticLabel: label,
      borderRadius: AsiaRadii.brPill,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: theme.border, width: 0.8),
        ),
        alignment: Alignment.center,
        child: Icon(
          isDark ? LucideIcons.sun : LucideIcons.moon,
          size: 20,
          color: theme.textSecondary,
        ),
      ),
    );
  }
}

class _StatusArea extends StatelessWidget {
  const _StatusArea({
    required this.errorMessage,
    required this.noticeMessage,
    required this.duration,
  });

  final String? errorMessage;
  final String? noticeMessage;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final String? message = errorMessage ?? noticeMessage;
    final bool isError = errorMessage != null;
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AsiaMotion.emphasized,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(sizeFactor: animation, child: child),
        );
      },
      child: message == null
          ? const SizedBox.shrink(key: ValueKey<String>('status-empty'))
          : _StatusBanner(
              key: ValueKey<String>('${isError ? 'error' : 'notice'}-$message'),
              message: message,
              isError: isError,
            ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.isError,
    super.key,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final Color color = isError ? theme.error : theme.success;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AsiaSpacing.md,
          vertical: AsiaSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: theme.isDark ? 0.14 : 0.08),
          borderRadius: AsiaRadii.brMd,
          border: Border.all(color: color.withValues(alpha: 0.42)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              isError ? LucideIcons.circleAlert : LucideIcons.circleCheck,
              size: 19,
              color: color,
            ),
            const SizedBox(width: AsiaSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AsiaTypography.bodySmall.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
