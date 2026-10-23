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
                        constraints: const BoxConstraints(maxWidth: 432),
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
    final TextStyle hintStyle = TextStyle(
      color: palette.textSecondary,
      fontFamily: AppTypography.bodyFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: palette.accentGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'TU MESA TE ESPERA',
                maxLines: 1,
                style: TextStyle(
                  color: palette.textAccent,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 20 / 10,
                  letterSpacing: 1.7,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 43),
          child: Text(
            'Bienvenido de nuevo',
            style: Theme.of(context).textTheme.displayLarge
                ?.copyWith(fontSize: 30, height: 43 / 30),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 22),
          child: Text(
            'Inicia sesión y disfruta tus platos favoritos.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontSize: 12.5, height: 22 / 12.5),
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
        const SizedBox(height: 18),
        ChifaTextField(
          key: const Key('login-email'),
          controller: emailController,
          label: 'Correo electrónico',
          hintText: 'ejemplo@correo.com',
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
        SizedBox(
          height: 18,
          child: Row(
            children: <Widget>[
              Expanded(child: Divider(height: 1, color: palette.border)),
              SizedBox(
                width: 92,
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
      ],
    );
  }
}
