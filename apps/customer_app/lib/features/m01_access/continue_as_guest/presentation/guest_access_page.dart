import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/presentation/access_widgets.dart';

class GuestAccessPage extends StatelessWidget {
  const GuestAccessPage({
    required this.authController,
    this.showBackButton,
    super.key,
  });

  final AuthSessionController authController;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !authController.state.isBusy,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) authController.clearMessages();
      },
      child: AccessSimpleScaffold(
        pageKey: const Key('page-invitado'),
        showBackButton: showBackButton,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/acceso');
          }
        },
        child: AnimatedBuilder(
          animation: authController,
          builder: (BuildContext context, Widget? child) {
            final AuthState state = authController.state;
            final bool loading = state.operation == AuthOperation.guest;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const AccessKicker(),
                const SizedBox(height: 30),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 42),
                  child: Text(
                    'Bienvenido, invitado',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displayLarge
                        ?.copyWith(fontSize: 31, height: 42 / 31),
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 37),
                  child: Text(
                    'Explora el catálogo sin crear una cuenta.',
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
                const SizedBox(height: 47),
                const ChifaCard(
                  title: 'Acceso rápido',
                  subtitle: 'El sistema crea una sesión temporal.',
                  icon: LucideIcons.zap,
                  minimumHeight: 77,
                ),
                const SizedBox(height: 21),
                ChifaCard(
                  title: 'Tus pedidos',
                  subtitle: 'Consulta las solicitudes de esta sesión.',
                  icon: LucideIcons.receiptText,
                  trailing: Icon(
                    LucideIcons.chevronRight,
                    color: context.appPalette.textSecondary,
                    size: 17,
                  ),
                  minimumHeight: 77,
                ),
                const SizedBox(height: 21),
                const ChifaCard(
                  title: 'Sin registro',
                  subtitle: 'Puedes crear una cuenta más adelante.',
                  icon: LucideIcons.userRoundPlus,
                  minimumHeight: 77,
                ),
                const SizedBox(height: 84),
                ChifaButton(
                  key: const Key('guest-submit'),
                  label: 'Continuar como invitado',
                  isLoading: loading,
                  onPressed: state.isBusy
                      ? null
                      : authController.continueAsGuest,
                  height: 54,
                  borderRadius: 14,
                  textStyle: const TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
