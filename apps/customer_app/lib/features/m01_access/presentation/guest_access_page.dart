import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../shared/application/auth_session_controller.dart';

class GuestAccessPage extends StatefulWidget {
  const GuestAccessPage({
    required this.controller,
    required this.onBackToSignIn,
    required this.onSuccess,
    super.key,
  });

  final AuthSessionController controller;
  final VoidCallback onBackToSignIn;
  final VoidCallback onSuccess;

  @override
  State<GuestAccessPage> createState() => _GuestAccessPageState();
}

class _GuestAccessPageState extends State<GuestAccessPage> {
  Future<void> _handleContinue() async {
    widget.controller.clearMessages();
    final bool ok = await widget.controller.continueAsGuest();
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
          title: 'Acceso como invitado',
          subtitle: 'Explora nuestra carta y pide sin necesidad de registrarte',
          showBack: true,
          onBack: widget.onBackToSignIn,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.surfaceSubtle,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.border, width: 0.8),
                  ),
                  child: Icon(
                    LucideIcons.userCheck,
                    size: 32,
                    color: theme.brandGold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AsiaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(LucideIcons.sparkles, size: 18, color: theme.brandGold),
                        const SizedBox(width: 8),
                        Text(
                          'Beneficios como invitado',
                          style: AsiaTypography.titleSmall.copyWith(
                            color: theme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Visualiza todo el catálogo y precios actualizados.\n'
                      '• Haz pedidos en mesa o para llevar de forma inmediata.\n'
                      '• Podrás crear una cuenta más adelante para guardar tus pedidos y tarjetas.',
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: theme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AsiaButton(
                key: const Key('guest-continue-button'),
                label: 'Entrar al Menú Ahora',
                onPressed: _handleContinue,
                isLoading: isBusy,
                trailing: LucideIcons.arrowRight,
              ),
              const SizedBox(height: 14),
              AsiaButton(
                label: 'Prefiero Iniciar Sesión',
                variant: AsiaButtonVariant.secondary,
                onPressed: isBusy ? null : widget.onBackToSignIn,
              ),
            ],
          ),
        );
      },
    );
  }
}

