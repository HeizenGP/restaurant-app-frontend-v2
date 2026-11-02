import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
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
        showBackButton: widget.showBackButton,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/acceso');
          }
        },
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
                            child: InkWell(
                              key: const Key('go-login-tab'),
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/acceso');
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                child: Center(
                                  child: Text(
                                    'Iniciar sesión',
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
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C1318) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
                                      : Colors.transparent,
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
                                  'Crear cuenta',
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFE5C07B)
                                        : palette.brandRed,
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
                      'Únete a KAIRO',
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
                      'Crea tu cuenta para disfrutar de todos nuestros servicios',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
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
