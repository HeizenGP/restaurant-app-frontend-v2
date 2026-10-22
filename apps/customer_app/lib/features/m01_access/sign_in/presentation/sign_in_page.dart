import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/domain/auth_models.dart';
import '../../shared/presentation/access_widgets.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    required this.authController,
    required this.themeModeController,
    super.key,
  });

  final AuthSessionController authController;
  final ThemeModeController themeModeController;

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: const Key('page-acceso'),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const LoginBrandHero(),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(28, 21, 28, 30),
                        decoration: BoxDecoration(
                          color: palette.background,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
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
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    AccessKicker(
                                      themeModeController:
                                          widget.themeModeController,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Bienvenido de nuevo',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Ingresa para continuar disfrutando Chifa ASIA.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    if (state.errorMessage != null) ...<Widget>[
                                      const SizedBox(height: 14),
                                      AccessMessageBanner(
                                        message: state.errorMessage!,
                                        isError: true,
                                      ),
                                    ],
                                    if (state.noticeMessage !=
                                        null) ...<Widget>[
                                      const SizedBox(height: 14),
                                      AccessMessageBanner(
                                        message: state.noticeMessage!,
                                      ),
                                    ],
                                    const SizedBox(height: 18),
                                    ChifaTextField(
                                      key: const Key('login-email'),
                                      controller: _emailController,
                                      label: 'Correo electrónico',
                                      hintText: 'tu@correo.com',
                                      leadingIcon: LucideIcons.mail,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.email,
                                        AutofillHints.username,
                                      ],
                                      enabled: !loading,
                                      autovalidateMode: _showValidation
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: AccessValidators.email,
                                    ),
                                    const SizedBox(height: 13),
                                    ChifaTextField(
                                      key: const Key('login-password'),
                                      controller: _passwordController,
                                      label: 'Contraseña',
                                      hintText: '••••••••',
                                      leadingIcon: LucideIcons.lock,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const <String>[
                                        AutofillHints.password,
                                      ],
                                      enabled: !loading,
                                      autovalidateMode: _showValidation
                                          ? AutovalidateMode.onUserInteraction
                                          : AutovalidateMode.disabled,
                                      validator: AccessValidators.loginPassword,
                                      onFieldSubmitted: (_) => _submit(),
                                      trailing: IconButton(
                                        key: const Key('login-password-toggle'),
                                        tooltip: _obscurePassword
                                            ? 'Mostrar contraseña'
                                            : 'Ocultar contraseña',
                                        onPressed: loading
                                            ? null
                                            : () => setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              }),
                                        icon: Icon(
                                          _obscurePassword
                                              ? LucideIcons.eye
                                              : LucideIcons.eyeOff,
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Semantics(
                                        enabled: false,
                                        label: 'Recuperación de contraseña no disponible',
                                        child: ExcludeSemantics(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 7,
                                            ),
                                            child: Text(
                                              '¿Olvidaste tu contraseña?',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        palette.textSecondary,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ChifaButton(
                                      key: const Key('login-submit'),
                                      label: 'Iniciar sesión',
                                      trailing: LucideIcons.arrowRight,
                                      isLoading: loading,
                                      onPressed: state.isBusy ? null : _submit,
                                    ),
                                    const SizedBox(height: 12),
                                    ChifaButton(
                                      key: const Key('go-guest'),
                                      label: 'Explorar como invitado',
                                      variant: ChifaButtonVariant.secondary,
                                      leading: LucideIcons.zap,
                                      onPressed: state.isBusy
                                          ? null
                                          : () {
                                              widget.authController
                                                  .clearMessages();
                                              context.push('/invitado');
                                            },
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      key: const Key('go-register'),
                                      onPressed: state.isBusy
                                          ? null
                                          : () {
                                              widget.authController
                                                  .clearMessages();
                                              context.push('/registro');
                                            },
                                      child: const Text('Crea tu cuenta'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    await widget.authController.login(
      LoginInput(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
