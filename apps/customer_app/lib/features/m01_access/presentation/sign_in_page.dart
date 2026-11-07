import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../shared/application/auth_session_controller.dart';
import '../shared/domain/auth_models.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    required this.controller,
    required this.onRegisterTap,
    required this.onGuestTap,
    required this.onSuccess,
    super.key,
  });

  final AuthSessionController controller;
  final VoidCallback onRegisterTap;
  final VoidCallback onGuestTap;
  final VoidCallback onSuccess;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    widget.controller.clearMessages();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    final bool ok = await widget.controller.login(
      LoginInput(email: email, password: password),
    );

    if (ok && mounted) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, _) {
        final AuthState state = widget.controller.state;
        final bool isBusy = state.isBusy;

        return AsiaScaffold(
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24),
                Center(
                  child: KairoLogo(
                    variant: KairoLogoVariant.vertical,
                    emblemSize: 76,
                    isDark: theme.isDark,
                    showSubtitle: true,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Fusión nikkei, tradición al wok y gastronomía asiática de autor',
                  textAlign: TextAlign.center,
                  style: AsiaTypography.bodyMedium.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                if (state.errorMessage != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.error.withValues(alpha: 0.12),
                      borderRadius: AsiaRadii.brMd,
                      border: Border.all(
                        color: theme.error.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(LucideIcons.circleAlert, size: 18, color: theme.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: AsiaTypography.bodySmall.copyWith(
                              color: theme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                AsiaTextField(
                  semanticKey: const Key('signin-email-input'),
                  controller: _emailController,
                  label: 'Correo electrónico',
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isBusy,
                ),
                const SizedBox(height: 16),
                AsiaTextField(
                  semanticKey: const Key('signin-password-input'),
                  controller: _passwordController,
                  label: 'Contraseña',
                  hintText: 'Ingresa tu contraseña',
                  prefixIcon: LucideIcons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  enabled: !isBusy,
                  onSubmitted: (_) => _handleSignIn(),
                ),
                const SizedBox(height: 24),
                AsiaButton(
                  key: const Key('signin-submit-button'),
                  label: 'Ingresar a mi cuenta',
                  onPressed: _handleSignIn,
                  isLoading: isBusy,
                  trailing: LucideIcons.arrowRight,
                ),
                const SizedBox(height: 14),
                AsiaButton(
                  key: const Key('signin-guest-button'),
                  label: 'Continuar como invitado',
                  variant: AsiaButtonVariant.secondary,
                  onPressed: isBusy ? null : widget.onGuestTap,
                  leading: LucideIcons.userX,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '¿No tienes una cuenta? ',
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    AsiaPressable(
                      key: const Key('signin-to-register-link'),
                      onPressed: isBusy ? null : widget.onRegisterTap,
                      semanticLabel: 'Crear cuenta',
                      child: Text(
                        'Regístrate aquí',
                        style: AsiaTypography.bodyMedium.copyWith(
                          color: theme.brandCrimson,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
