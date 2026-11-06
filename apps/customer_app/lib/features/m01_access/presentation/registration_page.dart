import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../shared/application/auth_session_controller.dart';
import '../shared/domain/auth_models.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    required this.controller,
    required this.onBackToSignIn,
    required this.onSuccess,
    super.key,
  });

  final AuthSessionController controller;
  final VoidCallback onBackToSignIn;
  final VoidCallback onSuccess;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    widget.controller.clearMessages();
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) return;

    final bool ok = await widget.controller.register(
      RegistrationInput(
        displayName: name,
        email: email,
        password: password,
      ),
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
          title: 'Crear cuenta',
          subtitle: 'Únete a Chifa ASIA y disfruta de pedidos rápidos',
          showBack: true,
          onBack: widget.onBackToSignIn,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 12),
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
                semanticKey: const Key('register-name-input'),
                controller: _nameController,
                label: 'Nombre completo',
                hintText: 'Ej. Heizen Guevara',
                prefixIcon: LucideIcons.user,
                textInputAction: TextInputAction.next,
                enabled: !isBusy,
              ),
              const SizedBox(height: 14),
              AsiaTextField(
                semanticKey: const Key('register-email-input'),
                controller: _emailController,
                label: 'Correo electrónico',
                hintText: 'ejemplo@correo.com',
                prefixIcon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isBusy,
              ),
              const SizedBox(height: 14),
              AsiaTextField(
                semanticKey: const Key('register-phone-input'),
                controller: _phoneController,
                label: 'Teléfono celular (opcional)',
                hintText: 'Ej. 987654321',
                prefixIcon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !isBusy,
              ),
              const SizedBox(height: 14),
              AsiaTextField(
                semanticKey: const Key('register-password-input'),
                controller: _passwordController,
                label: 'Contraseña',
                hintText: 'Mínimo 8 caracteres',
                prefixIcon: LucideIcons.lock,
                obscureText: true,
                textInputAction: TextInputAction.done,
                enabled: !isBusy,
                onSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 28),
              AsiaButton(
                key: const Key('register-submit-button'),
                label: 'Registrarme y Continuar',
                onPressed: _handleRegister,
                isLoading: isBusy,
                trailing: LucideIcons.arrowRight,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: AsiaTypography.bodyMedium.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                  AsiaPressable(
                    key: const Key('register-to-signin-link'),
                    onPressed: isBusy ? null : widget.onBackToSignIn,
                    semanticLabel: 'Iniciar sesión',
                    child: Text(
                      'Inicia sesión',
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
        );
      },
    );
  }
}
