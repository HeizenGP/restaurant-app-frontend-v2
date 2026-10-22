import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/presentation/access_widgets.dart';

class GuestAccessPage extends StatelessWidget {
  const GuestAccessPage({
    required this.authController,
    required this.themeModeController,
    super.key,
  });

  final AuthSessionController authController;
  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authController,
      builder: (BuildContext context, Widget? child) {
        return PopScope(
          canPop: !authController.state.isBusy,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) authController.clearMessages();
          },
          child: child!,
        );
      },
      child: AccessSimpleScaffold(
        pageKey: const Key('page-invitado'),
        themeModeController: themeModeController,
        child: AnimatedBuilder(
          animation: authController,
          builder: (BuildContext context, Widget? child) {
            final AuthState state = authController.state;
            final bool loading = state.operation == AuthOperation.guest;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Bienvenido, invitado',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 7),
                Text(
                  'Explora Chifa ASIA sin crear una cuenta.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (state.errorMessage != null) ...<Widget>[
                  const SizedBox(height: 18),
                  AccessMessageBanner(
                    message: state.errorMessage!,
                    isError: true,
                  ),
                ],
                const SizedBox(height: 31),
                const AccessFeatureCard(
                  icon: LucideIcons.zap,
                  title: 'Acceso rápido',
                  description: 'El sistema crea una sesión temporal.',
                ),
                const SizedBox(height: 21),
                const AccessFeatureCard(
                  icon: LucideIcons.receiptText,
                  title: 'Tus pedidos',
                  description: 'Consulta las solicitudes de esta sesión.',
                ),
                const SizedBox(height: 21),
                const AccessFeatureCard(
                  icon: LucideIcons.userRoundPlus,
                  title: 'Sin registro',
                  description: 'Puedes crear una cuenta más adelante.',
                ),
                const SizedBox(height: 83),
                ChifaButton(
                  key: const Key('guest-submit'),
                  label: 'Continuar como invitado',
                  trailing: LucideIcons.arrowRight,
                  isLoading: loading,
                  onPressed: state.isBusy
                      ? null
                      : authController.continueAsGuest,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  key: const Key('guest-back'),
                  onPressed: state.isBusy
                      ? null
                      : () {
                          authController.clearMessages();
                          context.pop();
                        },
                  icon: const Icon(LucideIcons.arrowLeft, size: 18),
                  label: const Text('Volver al acceso'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
