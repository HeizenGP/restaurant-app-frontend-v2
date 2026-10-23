import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/domain/auth_models.dart';
import '../../shared/presentation/access_widgets.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({required this.authController, super.key});

  final AuthSessionController authController;

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showValidation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final TextStyle hintStyle = TextStyle(
      color: palette.textSecondary,
      fontFamily: AppTypography.bodyFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );

    return PopScope(
      canPop: !widget.authController.state.isBusy,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop && widget.authController.state.noticeMessage == null) {
          widget.authController.clearMessages();
        }
      },
      child: AccessSimpleScaffold(
        pageKey: const Key('page-registro'),
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
                    const AccessKicker(),
                    const SizedBox(height: 30),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 42),
                      child: Text(
                        'Crea tu cuenta',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontSize: 31, height: 42 / 31),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 37),
                      child: Text(
                        'Tus pedidos, en un solo lugar.',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 12, height: 20 / 12),
                      ),
                    ),
                    if (state.errorMessage != null) ...<Widget>[
                      const SizedBox(height: 12),
                      AccessMessageBanner(
                        message: state.errorMessage!,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: 32),
                    ChifaTextField(
                      key: const Key('registration-name'),
                      controller: _nameController,
                      label: 'Nombre completo',
                      hintText: '¿Cómo debemos llamarte?',
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.name],
                      enabled: !loading,
                      autovalidateMode: autovalidateMode,
                      validator: AccessValidators.displayName,
                      labelHeight: 18,
                      labelGap: 6,
                      borderRadius: 12,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      hintStyle: hintStyle,
                      inputStyle: hintStyle.copyWith(
                        color: palette.textPrimary,
                      ),
                      fieldHeight: 53,
                    ),
                    const SizedBox(height: 21),
                    ChifaTextField(
                      key: const Key('registration-email'),
                      controller: _emailController,
                      label: 'Correo electrónico',
                      hintText: 'correo@ejemplo.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.email],
                      enabled: !loading,
                      autovalidateMode: autovalidateMode,
                      validator: AccessValidators.email,
                      labelHeight: 18,
                      labelGap: 6,
                      borderRadius: 12,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      hintStyle: hintStyle,
                      inputStyle: hintStyle.copyWith(
                        color: palette.textPrimary,
                      ),
                      fieldHeight: 53,
                    ),
                    const SizedBox(height: 21),
                    ChifaTextField(
                      key: const Key('registration-password'),
                      controller: _passwordController,
                      label: 'Contraseña',
                      hintText: 'Mínimo 8 caracteres',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      enabled: !loading,
                      autovalidateMode: autovalidateMode,
                      validator: AccessValidators.registrationPassword,
                      onFieldSubmitted: (_) => _submit(),
                      labelHeight: 18,
                      labelGap: 6,
                      borderRadius: 12,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      hintStyle: hintStyle,
                      inputStyle: hintStyle.copyWith(
                        color: palette.textPrimary,
                      ),
                      fieldHeight: 53,
                    ),
                    const SizedBox(height: 63),
                    ChifaButton(
                      key: const Key('registration-submit'),
                      label: 'Crear cuenta',
                      isLoading: loading,
                      onPressed: state.isBusy ? null : _submit,
                      height: 54,
                      borderRadius: 14,
                      textStyle: const TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(
                        height: 35,
                        child: Text(
                          'Al registrarte podrás iniciar sesión.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 12, height: 20 / 12),
                        ),
                      ),
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
