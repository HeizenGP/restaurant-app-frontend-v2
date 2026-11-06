import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/domain/auth_models.dart';
import '../../shared/presentation/access_widgets.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    required this.authController,
    this.showBackButton,
    super.key,
  });

  final AuthSessionController authController;
  final bool? showBackButton;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showValidation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/acceso');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return PopScope(
      canPop: !widget.authController.state.isBusy,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop && widget.authController.state.noticeMessage == null) {
          widget.authController.clearMessages();
        }
      },
      child: KairoAuthScaffold(
        pageKey: const Key('page-registro'),
        scrollKey: const Key('access-scroll'),
        showBackButton: widget.showBackButton,
        onBackPressed: _goToLogin,
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: AnimatedBuilder(
              animation: widget.authController,
              builder: (BuildContext context, Widget? child) {
                final AuthState state = widget.authController.state;
                final bool loading = state.operation == AuthOperation.register;
                final AutovalidateMode autovalidateMode = _showValidation
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const KairoReveal(
                      order: 0,
                      child: KairoAuthTitle(
                        title: 'Crear cuenta',
                        subtitle:
                            'Regístrate para disfrutar de nuestra carta y servicios.',
                      ),
                    ),
                    if (state.errorMessage != null) ...<Widget>[
                      const SizedBox(height: 16),
                      AccessMessageBanner(
                        message: state.errorMessage!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: 20),
                    KairoReveal(
                      order: 2,
                      child: KairoAuthField(
                        key: const Key('registration-name'),
                        controller: _nameController,
                        label: 'Nombre y apellidos',
                        hintText: 'Ingresa tu nombre completo',
                        icon: LucideIcons.user,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.name],
                        enabled: !loading,
                        autovalidateMode: autovalidateMode,
                        validator: AccessValidators.displayName,
                      ),
                    ),
                    const SizedBox(height: 14),
                    KairoReveal(
                      order: 3,
                      child: KairoAuthField(
                        key: const Key('registration-email'),
                        controller: _emailController,
                        label: 'Correo electrónico',
                        hintText: 'cliente@ejemplo.com',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        enabled: !loading,
                        autovalidateMode: autovalidateMode,
                        validator: AccessValidators.email,
                      ),
                    ),
                    const SizedBox(height: 14),
                    KairoReveal(
                      order: 4,
                      child: KairoAuthField(
                        key: const Key('registration-password'),
                        controller: _passwordController,
                        label: 'Contraseña',
                        hintText: 'Mínimo 8 caracteres',
                        icon: LucideIcons.lock,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.newPassword],
                        enabled: !loading,
                        autovalidateMode: autovalidateMode,
                        validator: AccessValidators.registrationPassword,
                        onFieldSubmitted: (_) => _submit(),
                        trailing: IconButton(
                          key: const Key('registration-password-toggle'),
                          tooltip: _obscurePassword
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          onPressed: loading
                              ? null
                              : () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Icon(
                              _obscurePassword
                                  ? LucideIcons.eye
                                  : LucideIcons.eyeOff,
                              key: ValueKey<bool>(_obscurePassword),
                              size: 20,
                              color: palette.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Icon(
                          LucideIcons.info,
                          size: 14,
                          color: palette.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Al registrarte podrás iniciar sesión con tu cuenta.',
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    KairoReveal(
                      order: 5,
                      child: KairoPrimaryButton(
                        key: const Key('registration-submit'),
                        label: 'Crear cuenta',
                        isLoading: loading,
                        onPressed: state.isBusy ? null : _submit,
                      ),
                    ),
                    const SizedBox(height: 18),
                    KairoAuthLinkRow(
                      question: '¿Ya tienes una cuenta?',
                      action: 'Inicia sesión',
                      actionKey: const Key('go-login-link'),
                      onPressed: state.isBusy ? null : _goToLogin,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showValidation = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool registered = await widget.authController.register(
      RegistrationInput(
        displayName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
    if (registered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/acceso');
        }
      });
    }
  }
}
