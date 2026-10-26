import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/design_system/design_system.dart';
import '../../m01_access/profile/application/user_profile_controller.dart';
import '../../m01_access/profile/domain/profile_models.dart';
import '../../m01_access/profile/presentation/profile_pages.dart';

class FoundationHomePage extends StatelessWidget {
  const FoundationHomePage({
    required this.themeModeController,
    this.content,
    this.onBackPressed,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.tableLabel,
    this.showBackButton,
    super.key,
  });

  final ThemeModeController themeModeController;
  final Widget? content;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final String? tableLabel;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-inicio'),
      title: 'El sabor nos reúne',
      subtitle: 'Una tradición china con alma peruana.',
      contentGap: 15,
      themeModeController: themeModeController,
      onBackPressed: onBackPressed,
      onCartPressed: onCartPressed,
      cartItemCount: cartItemCount,
      tableLabel: tableLabel,
      showBackButton: showBackButton,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _BrandHero(),
          const SizedBox(height: 23),
          content ??
              const ChifaStateView(
                key: Key('home-empty-catalog'),
                kind: ChifaStateKind.empty,
                title: 'Sin categorías disponibles',
                message: 'No hay datos del catálogo para mostrar por ahora',
              ),
        ],
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
    this.tableLabel,
    this.showBackButton,
    super.key,
  });

  final ThemeModeController themeModeController;
  final Widget? content;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final String? tableLabel;
  final bool? showBackButton;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-menu'),
      title: 'Nuestro menú',
      subtitle: 'Elige una categoría y descubre los platos.',
      contentGap: 14,
      themeModeController: themeModeController,
      onBackPressed: onBackPressed,
      onCartPressed: onCartPressed,
      cartItemCount: cartItemCount,
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
    this.tableLabel,
    this.showBackButton,
    super.key,
  });

  final ThemeModeController themeModeController;
  final Widget? content;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
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
    final String initials = switch (profileController?.avatarPath ?? avatarInitials?.trim()) {
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
                  onAvatarPressed: onLogout == null
                      ? null
                      : () => _confirmLogout(context),
                  onBackPressed: onBackPressed,
                  showBackButton: showBackButton,
                  onCartPressed: onCartPressed,
                  cartItemCount: cartItemCount,
                  tableLabel: tableLabel,
                ),
                const SizedBox(height: 22),
                _ProfileVisual(
                  palette: palette,
                  isDark: isDark,
                  initials: initials,
                  avatarPath: profileController?.avatarPath,
                  onTapAvatar: profileController != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProfilePhotoViewerPage(
                                themeModeController: themeModeController,
                                avatarPath: profileController?.avatarPath,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    identityName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      height: 41 / 32,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Text(
                    identityDetail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                      fontSize: 13,
                      height: 23 / 13,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _AccountStatusBadge(
                      isGuest: isGuest,
                      palette: palette,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _AccountActions(
                    isGuest: isGuest,
                    onOpenOrders: onOpenOrders,
                    onEditProfile: profileController != null && !isGuest
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
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _ProfileTabs(
                    selectedIndex: profileController?.selectedTabIndex ?? 0,
                    onTabSelected: profileController?.setTabIndex,
                  ),
                ),
                const SizedBox(height: 13),
                _buildTabSection(context, palette, identityName, identityDetail),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection(
    BuildContext context,
    AppPalette palette,
    String identityName,
    String identityDetail,
  ) {
    if (profileController != null && profileController!.selectedTabIndex == 1) {
      return _buildAddressesSection(context, palette);
    }
    if (profileController != null && profileController!.selectedTabIndex == 2) {
      return _buildCardsSection(context, palette);
    }
    return _buildInformationSection(context, palette, identityName, identityDetail);
  }

  Widget _buildInformationSection(
    BuildContext context,
    AppPalette palette,
    String identityName,
    String identityDetail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            isGuest ? 'Información de la sesión' : 'Datos personales',
            style: TextStyle(
              color: palette.textPrimary,
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: isGuest
              ? const ChifaStateView(
                  key: Key('guest-account-empty-state'),
                  kind: ChifaStateKind.empty,
                  title: 'Sin datos personales',
                  message: 'La sesión de invitado no guarda datos de cuenta',
                )
              : _AccountDataCard(
                  key: const Key('account-data-card'),
                  displayName: accountCardName ?? identityName,
                  email: accountCardEmail ?? identityDetail,
                ),
        ),
        if (profileController?.phone != null &&
            profileController!.phone!.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: ChifaCard(
              key: const Key('account-phone-card'),
              icon: LucideIcons.phone,
              title: '+51 ${profileController!.phone}',
              subtitle: 'Celular registrado · Validado',
              minimumHeight: 65,
            ),
          ),
        ],
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Text(
            isGuest
                ? 'La sesión de invitado no almacena un perfil.'
                : (profileController != null
                    ? 'Datos verificados para tus pedidos y entregas'
                    : 'Fotos, teléfonos y edición: sin API actual'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textSecondary,
                  fontSize: 10,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressesSection(BuildContext context, AppPalette palette) {
    final List<CustomerAddress> addresses = profileController!.addresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            'Mis direcciones de entrega',
            style: TextStyle(
              color: palette.textPrimary,
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (addresses.isEmpty)
          const ChifaStateView(
            key: Key('addresses-empty-state'),
            kind: ChifaStateKind.empty,
            title: 'Sin direcciones guardadas',
            message: 'Agrega una dirección para pedir por delivery más rápido',
          )
        else
          for (final CustomerAddress addr in addresses) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChifaCard(
                key: ValueKey<String>('address-card-${addr.id}'),
                icon: LucideIcons.mapPin,
                title: addr.label + (addr.isDefault ? ' (Predeterminada)' : ''),
                subtitle: addr.address +
                    (addr.reference != null ? '\nRef: ${addr.reference}' : ''),
                subtitleMaxLines: 3,
                minimumHeight: 70,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddAddressPage(
                        themeModeController: themeModeController,
                        controller: profileController!,
                        existingAddress: addr,
                      ),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      key: ValueKey<String>('edit-address-${addr.id}'),
                      icon: Icon(
                        LucideIcons.pencil,
                        size: 16,
                        color: palette.brandRed,
                      ),
                      tooltip: 'Editar dirección',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AddAddressPage(
                              themeModeController: themeModeController,
                              controller: profileController!,
                              existingAddress: addr,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      key: ValueKey<String>('delete-address-${addr.id}'),
                      icon: Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: palette.textSecondary,
                      ),
                      tooltip: 'Eliminar dirección',
                      onPressed: () => profileController!.removeAddress(addr.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        const SizedBox(height: 10),
        ChifaButton(
          key: const Key('account-add-address-button'),
          label: '+ Agregar dirección',
          height: 48,
          borderRadius: 12,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddAddressPage(
                  themeModeController: themeModeController,
                  controller: profileController!,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context, AppPalette palette) {
    final List<SavedPaymentCard> cards = profileController!.cards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            'Tarjetas y medios de pago',
            style: TextStyle(
              color: palette.textPrimary,
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (cards.isEmpty)
          const ChifaStateView(
            key: Key('cards-empty-state'),
            kind: ChifaStateKind.empty,
            title: 'Sin tarjetas registradas',
            message: 'Agrega una tarjeta de débito o crédito para tus pedidos',
          )
        else
          for (final SavedPaymentCard card in cards) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChifaCard(
                key: ValueKey<String>('card-item-${card.id}'),
                icon: LucideIcons.creditCard,
                title: '${card.brand} ${card.cardNumberMasked}',
                subtitle: 'Titular: ${card.cardHolder} · Vence: ${card.expiry}',
                minimumHeight: 70,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddCardPage(
                        themeModeController: themeModeController,
                        controller: profileController!,
                        existingCard: card,
                      ),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      key: ValueKey<String>('edit-card-${card.id}'),
                      icon: Icon(
                        LucideIcons.pencil,
                        size: 16,
                        color: palette.brandRed,
                      ),
                      tooltip: 'Editar tarjeta',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AddCardPage(
                              themeModeController: themeModeController,
                              controller: profileController!,
                              existingCard: card,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      key: ValueKey<String>('delete-card-${card.id}'),
                      icon: Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: palette.textSecondary,
                      ),
                      tooltip: 'Eliminar tarjeta',
                      onPressed: () => profileController!.removeCard(card.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        const SizedBox(height: 10),
        ChifaButton(
          key: const Key('account-add-card-button'),
          label: '+ Agregar tarjeta (16 dígitos)',
          height: 48,
          borderRadius: 12,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddCardPage(
                  themeModeController: themeModeController,
                  controller: profileController!,
                ),
              ),
            );
          },
        ),
      ],
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

class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Semantics(
      container: true,
      label: 'Cocina Chifa. Un antojo, un gran momento.',
      excludeSemantics: true,
      child: Container(
        height: 167,
        decoration: BoxDecoration(
          color: palette.brandSurface,
          borderRadius: BorderRadius.circular(AppRadii.hero),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 24,
              top: 22,
              width: 270,
              height: 24,
              child: Text(
                'COCINA CHIFA',
                maxLines: 1,
                style: TextStyle(
                  color: palette.onBrand,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 60,
              width: 282,
              height: 76,
              child: Text(
                'Un antojo,\nun gran momento',
                style: TextStyle(
                  color: palette.onBrand,
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 31,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileVisual extends StatelessWidget {
  const _ProfileVisual({
    required this.palette,
    required this.isDark,
    required this.initials,
    this.avatarPath,
    this.onTapAvatar,
  });

  final AppPalette palette;
  final bool isDark;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onTapAvatar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double avatarSize = (constraints.maxWidth * 112 / 354).clamp(
          88.0,
          112.0,
        );
        final double avatarInset = constraints.maxWidth * 12 / 354;

        return Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                _ProfileCover(palette: palette),
                Padding(
                  padding: EdgeInsets.only(left: avatarInset),
                  child: Transform.translate(
                    offset: Offset(0, avatarSize * 0.49),
                    child: _ProfileAvatar(
                      dimension: avatarSize,
                      isDark: isDark,
                      initials: initials,
                      avatarPath: avatarPath,
                      onTap: onTapAvatar,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: avatarSize * 0.56),
          ],
        );
      },
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
                  width: 3,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
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

    return Semantics(
      image: true,
      label: 'Avatar de cliente $initials',
      excludeSemantics: true,
      child: onTap != null
          ? GestureDetector(
              key: const Key('account-avatar-touchable'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: avatarCore,
            )
          : avatarCore,
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 354 / 196,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double factor = (constraints.maxWidth / 354).clamp(0.78, 1);
          return ClipRRect(
            borderRadius: BorderRadius.circular(20 * factor),
            child: ColoredBox(
              color: palette.profileCover,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Align(
                    alignment: const Alignment(3.18, 1.14),
                    child: FractionallySizedBox(
                      widthFactor: 255 / 354,
                      heightFactor: 255 / 196,
                      child: SvgPicture.asset(
                        'assets/images/m01/account_orbit.svg',
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(1.54, -1.44),
                    child: FractionallySizedBox(
                      widthFactor: 151 / 354,
                      heightFactor: 151 / 196,
                      child: SvgPicture.asset(
                        'assets/images/m01/account_orbit_inner.svg',
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.83, -0.17),
                    child: FractionallySizedBox(
                      widthFactor: 70 / 354,
                      heightFactor: 70 / 196,
                      child: SvgPicture.asset(
                        'assets/images/m01/account_sun.svg',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      21 * factor,
                      29 * factor,
                      20 * factor,
                      17 * factor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 42 * factor,
                          height: 2,
                          decoration: BoxDecoration(
                            color: palette.accentGold,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        SizedBox(height: 12 * factor),
                        Text(
                          'CHIFA ASIA  ·  DESDE EL CORAZÓN',
                          maxLines: 1,
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: AppColors.onBrand,
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 10 * factor,
                            fontWeight: FontWeight.w700,
                            height: 1.9,
                          ),
                        ),
                        SizedBox(height: 29 * factor),
                        Text(
                          'Tu lugar especial',
                          maxLines: 1,
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: AppColors.onBrand,
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 33 * factor,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 107 * factor,
                            height: 23 * factor,
                            child: const _DiamondPattern(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DiamondPattern extends StatelessWidget {
  const _DiamondPattern();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(
          4,
          (int index) => Transform.rotate(
            angle: -0.785398,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x6BE5BC74)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountStatusBadge extends StatelessWidget {
  const _AccountStatusBadge({required this.isGuest, required this.palette});

  final bool isGuest;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isGuest ? palette.textAccent : palette.success;
    final String label = isGuest ? 'SESIÓN DE INVITADO' : 'CUENTA REGISTRADA';

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 157, minHeight: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceTint,
            borderRadius: BorderRadius.circular(AppRadii.chip),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: statusColor,
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions({
    required this.isGuest,
    this.onOpenOrders,
    this.onEditProfile,
  });

  final bool isGuest;
  final VoidCallback? onOpenOrders;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Widget primary = _AccountAction(
          key: const Key('account-orders-action'),
          label: 'Ver mis pedidos',
          onPressed: onOpenOrders,
        );
        final Widget secondary = onEditProfile != null && !isGuest
            ? _AccountAction(
                key: const Key('account-edit-profile-action'),
                label: 'Editar perfil',
                onPressed: onEditProfile,
              )
            : _DisabledAccountAction(
                label: isGuest ? 'Perfil no disponible' : 'Editar perfil',
                detail: isGuest ? 'Sesión de invitado' : 'API pendiente',
              );

        if (constraints.maxWidth < 330) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[primary, const SizedBox(height: 10), secondary],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: primary),
              const SizedBox(width: 10),
              Expanded(child: secondary),
            ],
          ),
        );
      },
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({required this.label, this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 47),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onBrand,
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.appPalette.brandSurface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: onPressed == null
            ? content
            : InkWell(onTap: onPressed, child: content),
      ),
    );
  }
}

class _DisabledAccountAction extends StatelessWidget {
  const _DisabledAccountAction({required this.label, required this.detail});

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Semantics(
      button: true,
      enabled: false,
      label: '$label. $detail',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 47),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surfaceTint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.controlBorder, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 9,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    this.selectedIndex = 0,
    this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final List<String> labels = onTabSelected != null
        ? const <String>['Información', 'Direcciones', 'Tarjetas']
        : const <String>['Información', 'Pedidos', 'Preferencias'];

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 45),
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < labels.length; i++)
                  Expanded(
                    flex: i == 0 ? 116 : (i == 1 ? 105 : 113),
                    child: InkWell(
                      key: Key('profile-tab-$i'),
                      onTap: onTabSelected != null ? () => onTabSelected!(i) : null,
                      borderRadius: BorderRadius.circular(10),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: selectedIndex == i
                              ? palette.surfaceTint
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 9,
                          ),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedIndex == i
                                  ? palette.brandRed
                                  : palette.textSecondary,
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 11,
                              fontWeight: selectedIndex == i
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
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
    );
  }
}

class _AccountDataCard extends StatelessWidget {
  const _AccountDataCard({
    required this.displayName,
    required this.email,
    super.key,
  });

  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final TextStyle labelStyle = TextStyle(
      color: palette.textSecondary,
      fontFamily: AppTypography.bodyFontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final TextStyle valueStyle = TextStyle(
      color: palette.textPrimary,
      fontFamily: AppTypography.bodyFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.controlBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Nombre', style: labelStyle),
              const SizedBox(height: 3),
              Text(displayName, style: valueStyle),
              Divider(height: 20, color: palette.controlBorder),
              Text('Correo electrónico', style: labelStyle),
              const SizedBox(height: 3),
              Text(email, style: valueStyle),
            ],
          ),
        ),
      ),
    );
  }
}
