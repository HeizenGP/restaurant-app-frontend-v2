import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/application/auth_session_controller.dart';
import '../../shared/domain/auth_models.dart';
import '../../shared/presentation/access_widgets.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    required this.authController,
    required this.themeModeController,
    super.key,
  });

  final AuthSessionController authController;
  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: authController,
        builder: (BuildContext context, Widget? child) {
          final AuthState state = authController.state;
          final AuthSession? session = state.session;
          if (session == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return CustomScrollView(
            key: const Key('page-cuenta'),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                sliver: SliverList.list(
                  children: <Widget>[
                    _AccountHeader(themeModeController: themeModeController),
                    const SizedBox(height: 22),
                    _AccountHero(session: session),
                    const SizedBox(height: 12),
                    if (state.noticeMessage != null) ...<Widget>[
                      AccessMessageBanner(message: state.noticeMessage!),
                      const SizedBox(height: 12),
                    ],
                    if (state.errorMessage != null) ...<Widget>[
                      AccessMessageBanner(
                        message: state.errorMessage!,
                        isError: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    const _AccountActions(),
                    const SizedBox(height: 24),
                    const _AccountTabs(),
                    const SizedBox(height: 22),
                    _AccountDataCard(session: session),
                    const SizedBox(height: 9),
                    Text(
                      'Fotos, teléfonos y edición: sin API actual.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    ChifaButton(
                      key: const Key('logout-submit'),
                      label: 'Cerrar sesión',
                      variant: ChifaButtonVariant.secondary,
                      leading: LucideIcons.logOut,
                      isLoading: state.operation == AuthOperation.logout,
                      onPressed: state.isBusy ? null : authController.logout,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.themeModeController});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 51,
      child: Row(
        children: <Widget>[
          Container(width: 38, height: 2, color: palette.accentGold),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'MI CUENTA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.textAccent,
                fontSize: 9,
                letterSpacing: 1.6,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notificaciones no disponibles',
            onPressed: null,
            icon: const Icon(LucideIcons.bell, size: 19),
          ),
          IconButton(
            key: const Key('account-theme-toggle'),
            tooltip: isDark ? 'Activar tema claro' : 'Activar tema oscuro',
            onPressed: themeModeController.toggle,
            icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 19),
          ),
        ],
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final bool useAccessibleLayout =
        MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
        MediaQuery.sizeOf(context).width < 350;
    if (useAccessibleLayout) {
      return _AccessibleAccountHero(session: session);
    }
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final CustomerIdentity? user = session.user;
    final String name = user?.displayName ?? 'Invitado';
    final String detail = user?.email ?? 'Sesión temporal';
    final String suffix = isDark ? 'dark' : 'light';
    final Color heroColor = isDark
        ? const Color(0xFF48252A)
        : const Color(0xFF902B33);

    return SizedBox(
      height: 279,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 196,
            child: Semantics(
              container: true,
              label: 'Tu lugar especial en Chifa ASIA',
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoredBox(
                  color: heroColor,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        right: -28,
                        top: -56,
                        width: 255,
                        height: 255,
                        child: SvgPicture.asset(
                          'assets/images/m01/account_orbit.svg',
                        ),
                      ),
                      Positioned(
                        right: 17,
                        top: -11,
                        width: 166,
                        height: 166,
                        child: SvgPicture.asset(
                          'assets/images/m01/account_orbit_inner.svg',
                        ),
                      ),
                      Positioned(
                        right: 75,
                        top: 43,
                        width: 56,
                        height: 56,
                        child: SvgPicture.asset(
                          'assets/images/m01/account_sun.svg',
                        ),
                      ),
                      Positioned(
                        left: 22,
                        top: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'CHIFA ASIA',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 1.4,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tu lugar\nespecial',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Cormorant Garamond',
                                fontSize: 29,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 139,
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/images/m01/account_avatar_ring_$suffix.svg',
                  width: 112,
                  height: 112,
                ),
                SvgPicture.asset(
                  'assets/images/m01/account_avatar_$suffix.svg',
                  width: 99,
                  height: 99,
                ),
                const Icon(
                  LucideIcons.userRound,
                  color: Colors.white,
                  size: 37,
                ),
              ],
            ),
          ),
          Positioned(
            left: 136,
            right: 8,
            top: 209,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 7),
                _SessionBadge(isGuest: session.isGuest),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessibleAccountHero extends StatelessWidget {
  const _AccessibleAccountHero({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String suffix = isDark ? 'dark' : 'light';
    final CustomerIdentity? user = session.user;
    final Color heroColor = isDark
        ? const Color(0xFF48252A)
        : const Color(0xFF902B33);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 176,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: heroColor,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: -46,
                    top: -64,
                    width: 235,
                    height: 235,
                    child: SvgPicture.asset(
                      'assets/images/m01/account_orbit.svg',
                    ),
                  ),
                  Positioned(
                    right: 11,
                    top: -8,
                    width: 124,
                    height: 124,
                    child: SvgPicture.asset(
                      'assets/images/m01/account_orbit_inner.svg',
                    ),
                  ),
                  Positioned(
                    left: 22,
                    top: 23,
                    right: 116,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'CHIFA ASIA',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 1.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tu lugar especial',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 29,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox.square(
              dimension: 88,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/m01/account_avatar_ring_$suffix.svg',
                    width: 88,
                    height: 88,
                  ),
                  SvgPicture.asset(
                    'assets/images/m01/account_avatar_$suffix.svg',
                    width: 77,
                    height: 77,
                  ),
                  const Icon(
                    LucideIcons.userRound,
                    color: Colors.white,
                    size: 31,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user?.displayName ?? 'Invitado',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.email ?? 'Sesión temporal',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Align(
          alignment: Alignment.centerLeft,
          child: _SessionBadge(isGuest: session.isGuest),
        ),
      ],
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions();

  @override
  Widget build(BuildContext context) {
    final bool stackActions =
        MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
        MediaQuery.sizeOf(context).width < 350;
    final Widget orders = FilledButton.icon(
      key: const Key('account-orders'),
      onPressed: () => context.go('/pedidos'),
      icon: const Icon(LucideIcons.receiptText, size: 18),
      label: const Text('Ver mis pedidos'),
    );
    final Widget edit = Semantics(
      label: 'Editar perfil, API pendiente',
      enabled: false,
      button: true,
      child: OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(LucideIcons.pencil, size: 17),
        label: const Text('Editar perfil'),
      ),
    );

    if (stackActions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: orders,
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: edit,
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        Expanded(child: SizedBox(height: 47, child: orders)),
        const SizedBox(width: 12),
        Expanded(child: SizedBox(height: 47, child: edit)),
      ],
    );
  }
}

class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.isGuest});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: palette.success.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Text(
        '●  ${isGuest ? 'SESIÓN INVITADA' : 'CUENTA REGISTRADA'}',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: palette.success, letterSpacing: 0.5),
      ),
    );
  }
}

class _AccountTabs extends StatelessWidget {
  const _AccountTabs();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool stackTabs =
        MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
        MediaQuery.sizeOf(context).width < 350;
    if (stackTabs) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: palette.surfaceTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                'Información',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/pedidos'),
              child: const Text('Pedidos'),
            ),
            Semantics(
              enabled: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Preferencias',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.surfaceTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(11),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Información',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => context.go('/pedidos'),
              child: const Text('Pedidos'),
            ),
          ),
          Expanded(
            child: Semantics(
              enabled: false,
              child: const Center(child: Text('Preferencias')),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDataCard extends StatelessWidget {
  const _AccountDataCard({required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final CustomerIdentity? user = session.user;
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: <Widget>[
          _AccountDataRow(
            icon: LucideIcons.userRound,
            label: 'Nombre',
            value: user?.displayName ?? 'Invitado',
          ),
          Divider(height: 17, color: palette.border),
          _AccountDataRow(
            icon: LucideIcons.mail,
            label: user == null ? 'Acceso' : 'Correo',
            value: user?.email ?? 'Sesión temporal sin registro',
          ),
        ],
      ),
    );
  }
}

class _AccountDataRow extends StatelessWidget {
  const _AccountDataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: palette.brandRed),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
