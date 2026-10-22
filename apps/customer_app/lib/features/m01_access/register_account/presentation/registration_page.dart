import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/domain/auth_models.dart';
import '../../shared/presentation/access_widgets.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({
    required this.authController,
    required this.themeModeController,
    super.key,
  });

  final AuthSessionController authController;
  final ThemeModeController themeModeController;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showValidation = false;
  bool _obscurePassword = true;
  bool _createdSuccessfully = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.authController,
      builder: (BuildContext context, Widget? child) {
        return PopScope(
          canPop: !widget.authController.state.isBusy,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop && !_createdSuccessfully) {
              widget.authController.clearMessages();
            }
          },
          child: child!,
        );
      },
      child: AccessSimpleScaffold(
        pageKey: const Key('page-registro'),
        themeModeController: widget.themeModeController,
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: AnimatedBuilder(
              animation: widget.authController,
              builder: (BuildContext context, Widget? child) {
                final AuthState state = widget.authController.state;
                final bool loading = state.operation == AuthOperation.register;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Crea tu cuenta',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Tus pedidos, en un solo lugar.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (state.errorMessage != null) ...<Widget>[
                      const SizedBox(height: 18),
                      AccessMessageBanner(
                        message: state.errorMessage!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: 29),
                    ChifaTextField(
                      key: const Key('register-name'),
                      controller: _nameController,
                      label: 'Nombre completo',
                      hintText: '¿Cómo te llamamos?',
                      leadingIcon: LucideIcons.userRound,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.name],
                      enabled: !loading,
                      validator: AccessValidators.displayName,
                      autovalidateMode: _autovalidateMode,
                    ),
                    const SizedBox(height: 18),
                    ChifaTextField(
                      key: const Key('register-email'),
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hintText: 'tu@correo.com',
                      leadingIcon: LucideIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[
                        AutofillHints.email,
                        AutofillHints.newUsername,
                      ],
                      enabled: !loading,
                      validator: AccessValidators.email,
                      autovalidateMode: _autovalidateMode,
                    ),
                    const SizedBox(height: 18),
                    ChifaTextField(
                      key: const Key('register-password'),
                      controller: _passwordController,
                      label: 'Contraseña',
                      hintText: 'Mínimo 8 caracteres',
                      leadingIcon: LucideIcons.lock,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      enabled: !loading,
                      validator: AccessValidators.registrationPassword,
                      autovalidateMode: _autovalidateMode,
                      onFieldSubmitted: (_) => _submit(),
                      trailing: IconButton(
                        key: const Key('register-password-toggle'),
                        tooltip: _obscurePassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: loading
                            ? null
                            : () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                        icon: Icon(
                          _obscurePassword
                              ? LucideIcons.eye
                              : LucideIcons.eyeOff,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(height: 31),
                    ChifaButton(
                      key: const Key('register-submit'),
                      label: 'Crear cuenta',
                      trailing: LucideIcons.arrowRight,
                      isLoading: loading,
                      onPressed: state.isBusy ? null : _submit,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Al registrarte podrás iniciar sesión.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 18),
                    TextButton.icon(
                      key: const Key('register-back'),
                      onPressed: state.isBusy
                          ? null
                          : () {
                              widget.authController.clearMessages();
                              context.pop();
                            },
                      icon: const Icon(LucideIcons.arrowLeft, size: 18),
                      label: const Text('Ya tengo una cuenta'),
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

  AutovalidateMode get _autovalidateMode => _showValidation
      ? AutovalidateMode.onUserInteraction
      : AutovalidateMode.disabled;

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showValidation = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bool created = await widget.authController.register(
      RegistrationInput(
        displayName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
    if (created && mounted) {
      _createdSuccessfully = true;
      context.go('/acceso');
    }
  }
}
