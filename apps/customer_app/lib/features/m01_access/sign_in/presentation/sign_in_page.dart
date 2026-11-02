import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/domain/auth_models.dart';
import '../../shared/presentation/access_widgets.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({required this.authController, super.key});

  final AuthSessionController authController;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: palette.background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        key: const Key('page-acceso'),
        body: SingleChildScrollView(
          key: const Key('login-scroll'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const LoginBrandHero(),
              Transform.translate(
                offset: const Offset(0, -20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 556),
                  child: DecoratedBox(
                    key: const Key('login-sheet'),
                    decoration: BoxDecoration(
                      color: palette.background,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSpacing.mobilePageMaxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 25, 28, 22),
                          child: AutofillGroup(
                            child: Form(
                              key: _formKey,
                              child: AnimatedBuilder(
                                animation: widget.authController,
                                builder: (BuildContext context, Widget? child) {
                                  final AuthState state =
                                      widget.authController.state;
                                  final bool loading =
                                      state.operation == AuthOperation.signIn;
                                  return _LoginFormContent(
                                    state: state,
                                    loading: loading,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    autovalidateMode: _showValidation
                                        ? AutovalidateMode.onUserInteraction
                                        : AutovalidateMode.disabled,
                                    onTogglePassword: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    onSubmit: _submit,
                                    onGuest: _openGuest,
                                    onRegister: _openRegistration,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGuest() {
    widget.authController.clearMessages();
    context.push('/invitado');
  }

  void _openRegistration() {
    widget.authController.clearMessages();
    context.push('/registro');
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showValidation = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.authController.login(
      LoginInput(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}

class _LoginFormContent extends StatelessWidget {
  const _LoginFormContent({
    required this.state,
    required this.loading,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.autovalidateMode,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onGuest,
    required this.onRegister,
  });

  final AuthState state;
  final bool loading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final AutovalidateMode autovalidateMode;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onGuest;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextStyle hintStyle = TextStyle(
      color: palette.textSecondary,
      fontFamily: AppTypography.bodyFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );

    final bool isValidEmail = emailController.text.trim().isNotEmpty &&
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(emailController.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Modern Segmented Navigation Switcher
        Container(
          decoration: BoxDecoration(
            color: palette.surfaceTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.controlBorder, width: 1.0),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C1318) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFFD4AF37).withValues(alpha: 0.4) : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE5C07B) : palette.brandRed,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  key: const Key('go-register-tab'),
                  onTap: onRegister,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Center(
                      child: Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Bienvenido de nuevo',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ingresa tus credenciales para acceder a tu cuenta',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.textSecondary,
            fontSize: 12.5,
            height: 1.35,
          ),
        ),
        if (state.errorMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          AccessMessageBanner(message: state.errorMessage!, isError: true),
        ],
        if (state.noticeMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          AccessMessageBanner(message: state.noticeMessage!),
        ],
        const SizedBox(height: 16),
        ChifaTextField(
          key: const Key('login-email'),
          controller: emailController,
          label: 'Correo electrónico',
          hintText: 'cliente@ejemplo.com',
          leadingIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[
            AutofillHints.email,
            AutofillHints.username,
          ],
          enabled: !loading,
          autovalidateMode: autovalidateMode,
          validator: AccessValidators.email,
          trailing: isValidEmail
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    LucideIcons.checkCircle2,
                    color: palette.success,
                    size: 18,
                  ),
                )
              : null,
          labelHeight: 18,
          labelGap: 5,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          hintStyle: hintStyle,
          inputStyle: hintStyle.copyWith(color: palette.textPrimary),
          fieldHeight: 52,
        ),
        const SizedBox(height: 16),
        ChifaTextField(
          key: const Key('login-password'),
          controller: passwordController,
          label: 'Contraseña',
          hintText: 'Ingresa tu contraseña',
          leadingIcon: LucideIcons.lock,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.password],
          enabled: !loading,
          autovalidateMode: autovalidateMode,
          validator: AccessValidators.loginPassword,
          onFieldSubmitted: (_) => onSubmit(),
          labelHeight: 18,
          labelGap: 5,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          hintStyle: hintStyle,
          inputStyle: hintStyle.copyWith(color: palette.textPrimary),
          fieldHeight: 52,
          trailing: IconButton(
            key: const Key('login-password-toggle'),
            tooltip: obscurePassword
                ? 'Mostrar contraseña'
                : 'Ocultar contraseña',
            onPressed: loading ? null : onTogglePassword,
            icon: Icon(
              obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
              size: 20,
              color: palette.textSecondary,
            ),
          ),
        ),
        if (passwordController.text.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          _PasswordStrengthIndicator(password: passwordController.text),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Semantics(
            enabled: false,
            label: 'Recuperación de contraseña no disponible',
            child: ExcludeSemantics(
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: palette.brandSurface,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 21 / 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 19),
        ChifaButton(
          key: const Key('login-submit'),
          label: 'Iniciar sesión',
          trailing: LucideIcons.arrowRight,
          trailingAtEdge: true,
          isLoading: loading,
          onPressed: state.isBusy ? null : onSubmit,
          borderRadius: 13,
          textStyle: const TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(child: Divider(height: 1, color: palette.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'o continúa como',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 11),
              ),
            ),
            Expanded(child: Divider(height: 1, color: palette.border)),
          ],
        ),
        const SizedBox(height: 13),
        ChifaButton(
          key: const Key('go-guest'),
          label: 'Explorar como invitado',
          variant: ChifaButtonVariant.secondary,
          trailing: LucideIcons.chevronRight,
          trailingAtEdge: true,
          iconSize: 17,
          onPressed: state.isBusy ? null : onGuest,
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              '¿Eres nuevo aquí?',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
            TextButton(
              key: const Key('go-register'),
              onPressed: state.isBusy ? null : onRegister,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 40),
                padding: const EdgeInsets.only(left: 7, right: 7),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Crea tu cuenta',
                style: TextStyle(
                  color: palette.brandSurface,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          children: <Widget>[
            Icon(
              LucideIcons.shieldCheck,
              size: 13,
              color: palette.success,
            ),
            Text(
              'Conexión segura cifrada de punto a punto',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 10.5,
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final int score = _calculateScore(password);

    final String label;
    final Color barColor;
    final double percent;

    if (score <= 1) {
      label = 'Contraseña corta';
      barColor = palette.brandRed;
      percent = 0.33;
    } else if (score == 2) {
      label = 'Contraseña media';
      barColor = palette.accentGold;
      percent = 0.66;
    } else {
      label = 'Contraseña segura';
      barColor = palette.success;
      percent = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            for (int i = 1; i <= 3; i++) ...<Widget>[
              if (i > 1) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: (i == 1 && percent >= 0.33) ||
                            (i == 2 && percent >= 0.66) ||
                            (i == 3 && percent >= 1.0)
                        ? barColor
                        : palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: barColor,
            ),
          ),
        ),
      ],
    );
  }

  int _calculateScore(String val) {
    if (val.length < 6) return 0;
    int s = 1;
    if (val.length >= 8) s++;
    if (RegExp(r'\d').hasMatch(val) && RegExp(r'[a-zA-Z]').hasMatch(val)) s++;
    return s;
  }
}
