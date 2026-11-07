import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../shared/application/auth_session_controller.dart';
import '../shared/domain/auth_models.dart';
import 'password_requirements.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({
    required this.controller,
    required this.onBack,
    required this.onCompleted,
    this.initialToken,
    super.key,
  });

  final AuthSessionController controller;
  final VoidCallback onBack;
  final VoidCallback onCompleted;
  final String? initialToken;

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final GlobalKey<FormState> _requestFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _tokenController = TextEditingController(
    text: widget.initialToken ?? '',
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _instructionsRequested = false;

  @override
  void initState() {
    super.initState();
    _instructionsRequested = (widget.initialToken ?? '').isNotEmpty;
    _passwordController.addListener(_refreshRequirements);
  }

  void _refreshRequirements() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_refreshRequirements);
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestInstructions() async {
    widget.controller.clearMessages();
    if (!(_requestFormKey.currentState?.validate() ?? false)) return;
    final bool ok = await widget.controller.requestPasswordReset(
      _emailController.text,
    );
    if (ok && mounted) setState(() => _instructionsRequested = true);
  }

  Future<void> _resetPassword() async {
    widget.controller.clearMessages();
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;
    final bool ok = await widget.controller.resetPassword(
      token: _tokenController.text,
      newPassword: _passwordController.text,
    );
    if (ok && mounted) widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final AuthState state = widget.controller.state;
        final bool isBusy = state.isBusy;
        return AsiaScaffold(
          title: 'Recuperar acceso',
          subtitle: _instructionsRequested
              ? 'Usa el token enviado a tu correo para crear una nueva contraseña.'
              : 'Te enviaremos instrucciones seguras si el correo pertenece a una cuenta.',
          showBack: true,
          onBack: widget.onBack,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: AsiaSpacing.lg),
                    if (state.errorMessage != null ||
                        state.noticeMessage != null) ...<Widget>[
                      _RecoveryNotice(
                        message: state.errorMessage ?? state.noticeMessage!,
                        isError: state.errorMessage != null,
                      ),
                      const SizedBox(height: AsiaSpacing.lg),
                    ],
                    AnimatedSwitcher(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? AsiaMotion.instant
                          : AsiaMotion.standard,
                      child: _instructionsRequested
                          ? Form(
                              key: _resetFormKey,
                              child: Column(
                                key: const ValueKey<String>('reset-step'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  AsiaTextField(
                                    semanticKey: const Key('reset-token-input'),
                                    controller: _tokenController,
                                    label: 'Token de recuperación',
                                    hintText: 'Pega el token recibido',
                                    prefixIcon: LucideIcons.keyRound,
                                    enabled: !isBusy,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    validator: (String? value) =>
                                        (value ?? '').trim().length < 32
                                        ? 'Ingresa el token completo.'
                                        : null,
                                  ),
                                  const SizedBox(height: AsiaSpacing.base),
                                  AsiaTextField(
                                    semanticKey: const Key(
                                      'reset-password-input',
                                    ),
                                    controller: _passwordController,
                                    label: 'Nueva contraseña',
                                    hintText: 'Crea una contraseña segura',
                                    prefixIcon: LucideIcons.lock,
                                    obscureText: true,
                                    enabled: !isBusy,
                                    validator:
                                        AccessValidators.registrationPassword,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    autofillHints: const <String>[
                                      AutofillHints.newPassword,
                                    ],
                                  ),
                                  const SizedBox(height: AsiaSpacing.md),
                                  PasswordRequirements(
                                    password: _passwordController.text,
                                  ),
                                  const SizedBox(height: AsiaSpacing.base),
                                  AsiaTextField(
                                    semanticKey: const Key(
                                      'reset-confirm-password-input',
                                    ),
                                    controller: _confirmController,
                                    label: 'Confirmar contraseña',
                                    hintText: 'Repite la nueva contraseña',
                                    prefixIcon: LucideIcons.lockKeyhole,
                                    obscureText: true,
                                    enabled: !isBusy,
                                    validator: (String? value) =>
                                        AccessValidators.passwordConfirmation(
                                          value,
                                          _passwordController.text,
                                        ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _resetPassword(),
                                  ),
                                  const SizedBox(height: AsiaSpacing.xl),
                                  AsiaButton(
                                    key: const Key('reset-submit-button'),
                                    label: 'Actualizar contraseña',
                                    loadingLabel: 'Actualizando…',
                                    isLoading: isBusy,
                                    enabled: !isBusy,
                                    onPressed: _resetPassword,
                                    trailing: LucideIcons.arrowRight,
                                  ),
                                  const SizedBox(height: AsiaSpacing.md),
                                  AsiaButton(
                                    label: 'Solicitar otro token',
                                    variant: AsiaButtonVariant.secondary,
                                    enabled: !isBusy,
                                    onPressed: () => setState(
                                      () => _instructionsRequested = false,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Form(
                              key: _requestFormKey,
                              child: Column(
                                key: const ValueKey<String>('request-step'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Icon(
                                    LucideIcons.mailCheck,
                                    size: 44,
                                    color: theme.brandGold,
                                  ),
                                  const SizedBox(height: AsiaSpacing.lg),
                                  AsiaTextField(
                                    semanticKey: const Key(
                                      'recovery-email-input',
                                    ),
                                    controller: _emailController,
                                    label: 'Correo electrónico',
                                    hintText: 'tu@correo.com',
                                    prefixIcon: LucideIcons.mail,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const <String>[
                                      AutofillHints.email,
                                    ],
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    enabled: !isBusy,
                                    validator: AccessValidators.email,
                                    onSubmitted: (_) => _requestInstructions(),
                                  ),
                                  const SizedBox(height: AsiaSpacing.xl),
                                  AsiaButton(
                                    key: const Key('recovery-request-button'),
                                    label: 'Enviar instrucciones',
                                    loadingLabel: 'Enviando…',
                                    isLoading: isBusy,
                                    enabled: !isBusy,
                                    onPressed: _requestInstructions,
                                    trailing: LucideIcons.send,
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: AsiaSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecoveryNotice extends StatelessWidget {
  const _RecoveryNotice({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final Color color = isError ? theme.error : theme.success;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AsiaSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AsiaRadii.brMd,
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              isError ? LucideIcons.circleAlert : LucideIcons.circleCheck,
              color: color,
              size: 18,
            ),
            const SizedBox(width: AsiaSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AsiaTypography.bodySmall.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
