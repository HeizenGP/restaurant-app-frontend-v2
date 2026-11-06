import 'package:flutter/material.dart';
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
    return KairoAuthScaffold(
      pageKey: const Key('page-acceso'),
      scrollKey: const Key('login-scroll'),
      contentKey: const Key('login-sheet'),
      heroKey: const Key('login-hero'),
      canvasKey: const Key('login-artwork-canvas'),
      compactHeader: false,
      showBackButton: false,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: AnimatedBuilder(
            animation: widget.authController,
            builder: (BuildContext context, Widget? child) {
              final AuthState state = widget.authController.state;
              final bool loading = state.operation == AuthOperation.signIn;
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
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onSubmit: _submit,
                onGuest: _openGuest,
                onRegister: _openRegistration,
              );
            },
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
    final Color accent = kairoAccent(context);

    final bool isValidEmail = emailController.text.trim().isNotEmpty &&
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            .hasMatch(emailController.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const KairoReveal(
          order: 0,
          child: KairoAuthTitle(
            title: 'Bienvenido de nuevo',
            subtitle: 'Ingresa tus credenciales para acceder a tu cuenta.',
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.errorMessage != null) ...<Widget>[
                const SizedBox(height: 16),
                AccessMessageBanner(message: state.errorMessage!, isError: true),
              ],
              if (state.noticeMessage != null) ...<Widget>[
                const SizedBox(height: 16),
                AccessMessageBanner(message: state.noticeMessage!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        KairoReveal(
          order: 2,
          child: KairoAuthField(
            key: const Key('login-email'),
            controller: emailController,
            label: 'Correo electrónico',
            hintText: 'cliente@ejemplo.com',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const <String>[
              AutofillHints.email,
              AutofillHints.username,
            ],
            enabled: !loading,
            autovalidateMode: autovalidateMode,
            validator: AccessValidators.email,
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> a) =>
                  ScaleTransition(scale: a, child: child),
              child: isValidEmail
                  ? Icon(
                      LucideIcons.circleCheck,
                      key: const ValueKey<bool>(true),
                      color: palette.success,
                      size: 19,
                    )
                  : const SizedBox.shrink(key: ValueKey<bool>(false)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        KairoReveal(
          order: 3,
          child: KairoAuthField(
            key: const Key('login-password'),
            controller: passwordController,
            label: 'Contraseña',
            hintText: 'Ingresa tu contraseña',
            icon: LucideIcons.lock,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const <String>[AutofillHints.password],
            enabled: !loading,
            autovalidateMode: autovalidateMode,
            validator: AccessValidators.loginPassword,
            onFieldSubmitted: (_) => onSubmit(),
            trailing: IconButton(
              key: const Key('login-password-toggle'),
              tooltip:
                  obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
              onPressed: loading ? null : onTogglePassword,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  key: ValueKey<bool>(obscurePassword),
                  size: 20,
                  color: palette.textSecondary,
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: passwordController.text.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                  child: _PasswordStrengthIndicator(
                    password: passwordController.text,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Semantics(
            enabled: false,
            label: 'Recuperación de contraseña no disponible',
            child: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4, right: 4),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: accent,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        KairoReveal(
          order: 4,
          child: KairoPrimaryButton(
            key: const Key('login-submit'),
            label: 'Iniciar sesión',
            isLoading: loading,
            onPressed: state.isBusy ? null : onSubmit,
          ),
        ),
        const SizedBox(height: 22),
        KairoReveal(
          order: 5,
          child: Row(
            children: <Widget>[
              Expanded(child: Divider(height: 1, color: palette.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'o',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(child: Divider(height: 1, color: palette.border)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        KairoReveal(
          order: 6,
          child: KairoSecondaryButton(
            key: const Key('go-guest'),
            label: 'Explorar como invitado',
            icon: LucideIcons.compass,
            onPressed: state.isBusy ? null : onGuest,
          ),
        ),
        const SizedBox(height: 18),
        KairoAuthLinkRow(
          question: '¿No tienes una cuenta?',
          action: 'Crear cuenta',
          actionKey: const Key('go-register'),
          onPressed: state.isBusy ? null : onRegister,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          children: <Widget>[
            Icon(LucideIcons.shieldCheck, size: 14, color: palette.success),
            Text(
              'Conexión segura cifrada de punto a punto',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12,
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
    final int filled;

    if (score <= 1) {
      label = 'Contraseña corta';
      barColor = palette.brandRed;
      filled = 1;
    } else if (score == 2) {
      label = 'Contraseña media';
      barColor = palette.accentGold;
      filled = 2;
    } else {
      label = 'Contraseña segura';
      barColor = palette.success;
      filled = 3;
    }

    return Row(
      children: <Widget>[
        for (int i = 1; i <= 3; i++) ...<Widget>[
          if (i > 1) const SizedBox(width: 5),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              height: 4,
              decoration: BoxDecoration(
                color: i <= filled ? barColor : palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: barColor,
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
