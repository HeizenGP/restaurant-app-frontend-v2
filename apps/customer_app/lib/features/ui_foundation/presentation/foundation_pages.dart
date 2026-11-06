import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/design_system/design_system.dart';
import '../../m01_access/profile/application/user_profile_controller.dart';
import '../../m01_access/profile/presentation/profile_pages.dart';

class FoundationHomePage extends StatelessWidget {
  const FoundationHomePage({
    required this.themeModeController,
    this.content,
    this.onBackPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.onNotificationPressed,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.tableLabel,
    this.showBackButton,
    super.key,
  });

  final ThemeModeController themeModeController;
  final Widget? content;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final VoidCallback? onNotificationPressed;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final String? tableLabel;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-inicio'),
      title: 'KAIRO · Sabores del Oriente',
      subtitle: 'Una experiencia gastronómica contemporánea y exótica.',
      contentGap: 15,
      themeModeController: themeModeController,
      onBackPressed: onBackPressed,
      onCartPressed: onCartPressed,
      cartItemCount: cartItemCount,
      onNotificationPressed: onNotificationPressed,
      initials: initials,
      avatarPath: avatarPath,
      onAvatarPressed: onAvatarPressed,
      tableLabel: tableLabel,
      showBackButton: showBackButton,
      child: content ??
          const ChifaStateView(
            key: Key('home-empty-catalog'),
            kind: ChifaStateKind.empty,
            title: 'Sin categorías disponibles',
            message: 'No hay datos del catálogo para mostrar por ahora',
          ),
    );
  }
}

class FoundationCatalogPage extends StatelessWidget {
  const FoundationCatalogPage({
    required this.themeModeController,
    this.content,
    this.onBackPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.onNotificationPressed,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.tableLabel,
    this.showBackButton,
    super.key,
  });

  final ThemeModeController themeModeController;
  final Widget? content;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final VoidCallback? onNotificationPressed;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final String? tableLabel;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-menu'),
      title: 'Carta KAIRO',
      subtitle: 'Elige una categoría y descubre creaciones asiáticas únicas.',
      contentGap: 14,
      themeModeController: themeModeController,
      onBackPressed: onBackPressed,
      onCartPressed: onCartPressed,
      cartItemCount: cartItemCount,
      onNotificationPressed: onNotificationPressed,
      initials: initials,
      avatarPath: avatarPath,
      onAvatarPressed: onAvatarPressed,
      tableLabel: tableLabel,
      showBackButton: showBackButton,
      child:
          content ??
          const ChifaStateView(
            key: Key('catalog-empty-state'),
            kind: ChifaStateKind.empty,
            title: 'Sin productos disponibles',
            message: 'No hay datos reales del catálogo para mostrar',
          ),
    );
  }
}

class FoundationOrdersPage extends StatelessWidget {
  const FoundationOrdersPage({
    required this.themeModeController,
    this.content,
    this.onBackPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.onNotificationPressed,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.tableLabel,
    this.showBackButton,
    super.key,
  });

  final ThemeModeController themeModeController;
  final Widget? content;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final VoidCallback? onNotificationPressed;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final String? tableLabel;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-pedidos'),
      title: 'Mis pedidos',
      subtitle: 'Solicitudes e historial de esta cuenta.',
      contentGap: 13,
      themeModeController: themeModeController,
      onBackPressed: onBackPressed,
      onCartPressed: onCartPressed,
      cartItemCount: cartItemCount,
      onNotificationPressed: onNotificationPressed,
      initials: initials,
      avatarPath: avatarPath,
      onAvatarPressed: onAvatarPressed,
      tableLabel: tableLabel,
      showBackButton: showBackButton,
      child:
          content ??
          const ChifaStateView(
            key: Key('orders-empty-state'),
            kind: ChifaStateKind.empty,
            title: 'Sin pedidos',
            message: 'Aún no hay pedidos reales para mostrar',
          ),
    );
  }
}

class FoundationInterfaceStatesPage extends StatelessWidget {
  const FoundationInterfaceStatesPage({
    required this.themeModeController,
    super.key,
  });

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-estados'),
      title: 'Estados de interfaz',
      subtitle: 'Variantes comunes para pantallas móviles.',
      contentGap: 20,
      themeModeController: themeModeController,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ChifaStateView(
            kind: ChifaStateKind.loading,
            title: 'Cargando…',
            message: 'Indicador de espera y contenido reservado',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.empty,
            title: 'Sin resultados',
            message: 'No hay elementos disponibles',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.error,
            title: 'No disponible',
            message: 'Producto agotado o deshabilitado',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.error,
            title: 'No autorizado',
            message: 'Sesión caducada o acceso denegado',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.success,
            title: 'Solicitud realizada',
            message: 'Éxito tras respuesta real del backend',
          ),
        ],
      ),
    );
  }
}

class FoundationAccountPage extends StatelessWidget {
  const FoundationAccountPage({
    required this.themeModeController,
    required this.isGuest,
    required this.displayName,
    required this.email,
    this.avatarInitials,
    this.accountCardName,
    this.accountCardEmail,
    this.onOpenOrders,
    this.onLogout,
    this.onBackPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.tableLabel,
    this.showBackButton,
    this.profileController,
    super.key,
  }) : assert(
         isGuest || (displayName != null && email != null),
         'A registered profile requires its real name and email.',
       );

  final ThemeModeController themeModeController;
  final bool isGuest;
  final String? displayName;
  final String? email;
  final String? avatarInitials;
  final String? accountCardName;
  final String? accountCardEmail;
  final VoidCallback? onOpenOrders;
  final Future<void> Function()? onLogout;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final String? tableLabel;
  final bool? showBackButton;
  final UserProfileController? profileController;

  @override
  Widget build(BuildContext context) {
    if (profileController != null) {
      return AnimatedBuilder(
        animation: profileController!,
        builder: (BuildContext context, Widget? _) {
          return _buildContent(context);
        },
      );
    }
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String identityName = isGuest
        ? 'Invitado'
        : (profileController?.displayName ?? displayName!.trim());
    final String identityDetail = isGuest
        ? 'Sesión temporal sin cuenta registrada'
        : email!.trim();
    final String? effectiveAvatarPath = isGuest ? null : profileController?.avatarPath;
    final String initials = switch (effectiveAvatarPath ?? avatarInitials?.trim()) {
      final String value when value.isNotEmpty =>
        value.characters.first,
      _ when identityName.isEmpty => isGuest ? 'I' : 'C',
      _ => identityName.characters.first.toUpperCase(),
    };

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const Key('page-cuenta'),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Center(
          child: ConstrainedBox(
            key: const Key('account-content-frame'),
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.mobilePageMaxWidth - 36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ChifaAppHeader(
                  isDarkMode: isDark,
                  onToggleTheme: themeModeController.toggle,
                  initials: initials,
                  avatarPath: effectiveAvatarPath,
                  onAvatarPressed: onLogout == null
                      ? null
                      : () => _confirmLogout(context),
                  onBackPressed: onBackPressed,
                  showBackButton: showBackButton,
                  onCartPressed: onCartPressed,
                  cartItemCount: cartItemCount,
                  tableLabel: tableLabel,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mi cuenta',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Horizontal Profile Card (Image 1 style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    key: const Key('account-data-card'),
                    padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? palette.border : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      _ProfileVisual(
                        dimension: 58,
                        palette: palette,
                        isDark: isDark,
                        initials: initials,
                        avatarPath: effectiveAvatarPath,
                        onTapAvatar: (profileController != null && !isGuest)
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ProfilePhotoViewerPage(
                                      themeModeController: themeModeController,
                                      avatarPath: effectiveAvatarPath,
                                      displayName: profileController?.displayName ??
                                          identityName,
                                      onEditProfile: !isGuest
                                          ? () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (_) => EditProfilePage(
                                                    themeModeController:
                                                        themeModeController,
                                                    controller: profileController!,
                                                    currentDisplayName: identityName,
                                                    currentEmail: identityDetail,
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    identityName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.textPrimary,
                                      fontFamily: AppTypography.bodyFontFamily,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (profileController != null && !isGuest) ...<Widget>[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    key: const Key('account-name-edit-icon'),
                                    icon: Icon(
                                      LucideIcons.pencil,
                                      size: 14,
                                      color: isDark ? const Color(0xFFD4AF37) : palette.brandRed,
                                    ),
                                    tooltip: 'Editar nombre',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => EditProfilePage(
                                            themeModeController: themeModeController,
                                            controller: profileController!,
                                            currentDisplayName: identityName,
                                            currentEmail: identityDetail,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              identityDetail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 13,
                                fontFamily: AppTypography.bodyFontFamily,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _AccountStatusBadge(
                              isGuest: isGuest,
                              palette: palette,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
                // Section 1: Mi perfil
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mi perfil',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? palette.border : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildMenuTile(
                        context: context,
                        key: const Key('account-edit-profile-action'),
                        icon: LucideIcons.user,
                        title: 'Información personal',
                        subtitle: isGuest
                            ? 'Sesión de invitado'
                            : 'Nombre, teléfono, email',
                        onTap: (profileController != null && !isGuest)
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => EditProfilePage(
                                      themeModeController: themeModeController,
                                      controller: profileController!,
                                      currentDisplayName: identityName,
                                      currentEmail: identityDetail,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                      _buildTileDivider(context, palette),
                      _buildMenuTile(
                        context: context,
                        key: const Key('profile-tab-1'),
                        icon: LucideIcons.mapPin,
                        title: 'Direcciones de entrega',
                        subtitle: isGuest
                            ? 'No disponible en modo invitado'
                            : (profileController != null
                                ? '${profileController!.addresses.length} guardadas'
                                : 'Casa, oficina, guardadas'),
                        onTap: (profileController != null && !isGuest)
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CustomerAddressesPage(
                                      themeModeController: themeModeController,
                                      controller: profileController!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                      _buildTileDivider(context, palette),
                      _buildMenuTile(
                        context: context,
                        key: const Key('profile-tab-2'),
                        icon: LucideIcons.creditCard,
                        title: 'Métodos de pago',
                        subtitle: isGuest
                            ? 'No disponible en modo invitado'
                            : (profileController != null
                                ? '${profileController!.cards.length} guardadas'
                                : 'Tarjetas y billeteras'),
                        onTap: (profileController != null && !isGuest)
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CustomerPaymentMethodsPage(
                                      themeModeController: themeModeController,
                                      controller: profileController!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                if (isGuest) ...<Widget>[
                  const SizedBox(height: 12),
                  const ChifaStateView(
                    key: Key('guest-account-empty-state'),
                    kind: ChifaStateKind.empty,
                    title: 'Sin datos personales',
                    message: 'La sesión de invitado no guarda datos de cuenta',
                  ),
                ],
                const SizedBox(height: 16),
                // Section 2: Mis pedidos
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mis pedidos',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? palette.border : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMenuTile(
                    context: context,
                    key: const Key('account-orders-action'),
                    icon: LucideIcons.receiptText,
                    title: 'Historial de pedidos',
                    subtitle: 'Revisa y sigue tus órdenes',
                    onTap: onOpenOrders,
                  ),
                ),
                const SizedBox(height: 16),
                // Section 3: Soporte y legal
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Soporte y legal',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? palette.border : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildMenuTile(
                        context: context,
                        icon: LucideIcons.headset,
                        title: 'Centro de ayuda',
                        subtitle: 'Preguntas frecuentes y soporte',
                        onTap: () {},
                      ),
                      _buildTileDivider(context, palette),
                      _buildMenuTile(
                        context: context,
                        icon: LucideIcons.fileText,
                        title: 'Términos y condiciones',
                        subtitle: 'Políticas de uso',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                if (onLogout != null) ...<Widget>[
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    key: const Key('account-logout-button'),
                    icon: const Icon(LucideIcons.logOut, size: 16),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTileDivider(BuildContext context, AppPalette palette) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 68,
      endIndent: 16,
      color: isDark ? palette.border : const Color(0xFFF0F1F3),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isExpanded = false,
  }) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: isDark ? const Color(0xFFD4AF37) : palette.brandRed,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                  size: 18,
                  color: palette.textSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Quieres cerrar tu sesión en este dispositivo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('logout-confirm'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) await onLogout?.call();
  }
}

class _ProfileVisual extends StatelessWidget {
  const _ProfileVisual({
    required this.palette,
    required this.isDark,
    required this.initials,
    this.avatarPath,
    this.onTapAvatar,
    this.dimension = 96.0,
  });

  final AppPalette palette;
  final bool isDark;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onTapAvatar;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 6),
        child: _ProfileAvatar(
          dimension: dimension,
          isDark: isDark,
          initials: initials,
          avatarPath: avatarPath,
          onTap: onTapAvatar,
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.dimension,
    required this.isDark,
    required this.initials,
    this.avatarPath,
    this.onTap,
  });

  final double dimension;
  final bool isDark;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onTap;

  Widget _buildFallback(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: <Widget>[
        SvgPicture.asset(
          isDark
              ? 'assets/images/m01/account_avatar_ring_dark.svg'
              : 'assets/images/m01/account_avatar_ring_light.svg',
        ),
        Align(
          child: FractionallySizedBox(
            widthFactor: 99 / 112,
            heightFactor: 99 / 112,
            child: SvgPicture.asset(
              isDark
                  ? 'assets/images/m01/account_avatar_dark.svg'
                  : 'assets/images/m01/account_avatar_light.svg',
            ),
          ),
        ),
        Center(
          child: Text(
            initials,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: AppColors.onBrand,
              fontFamily: AppTypography.displayFontFamily,
              fontSize: dimension * 48 / 112,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? path = avatarPath?.trim();
    final Widget avatarCore = SizedBox.square(
      dimension: dimension,
      child: (path != null && path.isNotEmpty)
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFC53030),
                  width: 3.2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (isDark ? const Color(0xFFD4AF37) : const Color(0xFF8E292E))
                        .withValues(alpha: 0.24),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: path.startsWith('http')
                    ? Image.network(
                        path,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildFallback(context),
                      )
                    : (path.startsWith('/') || path.startsWith('file:'))
                        ? Image.file(
                            File(path.replaceFirst('file://', '')),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildFallback(context),
                          )
                        : Image.asset(
                            path,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildFallback(context),
                          ),
              ),
            )
          : _buildFallback(context),
    );

    final Widget interactiveAvatar = (onTap != null)
        ? Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              avatarCore,
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF8E292E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF151718) : Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        : avatarCore;

    return Semantics(
      image: true,
      label: 'Avatar de cliente $initials',
      excludeSemantics: true,
      child: onTap != null
          ? GestureDetector(
              key: const Key('account-avatar-touchable'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: interactiveAvatar,
            )
          : avatarCore,
    );
  }
}

class _AccountStatusBadge extends StatelessWidget {
  const _AccountStatusBadge({required this.isGuest, required this.palette});

  final bool isGuest;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color statusColor = isGuest ? palette.textAccent : palette.success;
    final String label = isGuest ? 'SESIÓN DE INVITADO' : 'CUENTA REGISTRADA';

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 160, minHeight: 26),
        decoration: BoxDecoration(
          color: isGuest
              ? palette.surfaceTint
              : (isDark ? const Color(0xFF261D13) : const Color(0xFFFBF4E8)),
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: isGuest
                ? palette.controlBorder
                : (isDark
                    ? const Color(0xFFD4AF37).withValues(alpha: 0.4)
                    : const Color(0xFFC3934F).withValues(alpha: 0.5)),
            width: 1.2,
          ),
          boxShadow: isGuest
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isGuest ? LucideIcons.user : LucideIcons.crown,
                size: 13,
                color: isGuest
                    ? statusColor
                    : (isDark ? const Color(0xFFD4AF37) : const Color(0xFF95692A)),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isGuest
                        ? statusColor
                        : (isDark ? const Color(0xFFF3E5AB) : const Color(0xFF8E292E)),
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
