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
      title: 'El sabor nos reúne',
      subtitle: 'Una tradición china con alma peruana.',
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
      title: 'Nuestro menú',
      subtitle: 'Elige una categoría y descubre los platos.',
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
                _ProfileVisual(
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
                Center(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              identityName,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (profileController != null && !isGuest) ...<Widget>[
                            const SizedBox(width: 4),
                            IconButton(
                              key: const Key('account-name-edit-icon'),
                              icon: Icon(
                                LucideIcons.pencil,
                                size: 15,
                                color: isDark ? const Color(0xFFD4AF37) : palette.brandRed,
                              ),
                              tooltip: 'Editar nombre',
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 10),
                _buildConfigItem(
                  context: context,
                  palette: palette,
                  index: 0,
                  icon: LucideIcons.user,
                  title: 'Información personal',
                  subtitle: isGuest ? 'Sesión de invitado' : 'Nombre, correo y contacto',
                  isSelected: (profileController?.selectedTabIndex ?? 0) == 0,
                ),
                const SizedBox(height: 8),
                _buildConfigItem(
                  context: context,
                  palette: palette,
                  index: 1,
                  icon: LucideIcons.mapPin,
                  title: 'Direcciones de entrega',
                  subtitle: isGuest
                      ? 'No disponible en modo invitado'
                      : (profileController != null
                          ? '${profileController!.addresses.length} guardadas'
                          : 'Gestionar direcciones'),
                  isSelected: !isGuest && profileController?.selectedTabIndex == 1,
                ),
                const SizedBox(height: 8),
                _buildConfigItem(
                  context: context,
                  palette: palette,
                  index: 2,
                  icon: LucideIcons.creditCard,
                  title: 'Tarjetas y métodos de pago',
                  subtitle: isGuest
                      ? 'No disponible en modo invitado'
                      : (profileController != null
                          ? '${profileController!.cards.length} guardadas'
                          : 'Gestionar tarjetas'),
                  isSelected: !isGuest && profileController?.selectedTabIndex == 2,
                ),
                const SizedBox(height: 12),
                _buildTabSection(context, palette, identityName, identityDetail),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigItem({
    required BuildContext context,
    required AppPalette palette,
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('profile-tab-$index'),
        onTap: (profileController != null && !isGuest)
            ? () => profileController!.setTabIndex(index)
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? palette.accentGold.withValues(alpha: 0.12)
                    : palette.brandRed.withValues(alpha: 0.08))
                : palette.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (isDark ? palette.accentGold : palette.brandRed)
                  : palette.controlBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? palette.accentGold.withValues(alpha: 0.2)
                          : palette.brandRed.withValues(alpha: 0.15))
                      : palette.surfaceTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: isSelected
                      ? (isDark ? palette.accentGold : palette.brandRed)
                      : palette.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                size: 18,
                color: isSelected
                    ? (isDark ? palette.accentGold : palette.brandRed)
                    : palette.textSecondary,
              ),
            ],
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
    if (isGuest) {
      return _buildInformationSection(context, palette, identityName, identityDetail);
    }
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
                  controller: profileController,
                  onEdit: profileController != null && !isGuest
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
        if (!isGuest &&
            profileController?.phone != null &&
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
                icon: switch (addr.label.toLowerCase()) {
                  'casa' => LucideIcons.home,
                  'trabajo' || 'oficina' => LucideIcons.briefcase,
                  'pareja' => LucideIcons.heart,
                  _ => LucideIcons.mapPin,
                },
                title: addr.label + (addr.isDefault ? ' (Predeterminada)' : ''),
                subtitle: addr.address +
                    (addr.department != null && addr.department!.isNotEmpty
                        ? ', Dpto ${addr.department}'
                        : '') +
                    (addr.reference != null && addr.reference!.isNotEmpty
                        ? '\nRef: ${addr.reference}'
                        : ''),
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
          leading: LucideIcons.plus,
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
          leading: LucideIcons.plus,
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
    const double avatarSize = 120.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: _ProfileAvatar(
          dimension: avatarSize,
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

    final Widget interactiveAvatar = (onTap != null)
        ? Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              avatarCore,
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      width: 2.5,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 5,
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
          icon: onOpenOrders != null ? LucideIcons.receipt : null,
          onPressed: onOpenOrders,
        );
        final Widget secondary = onEditProfile != null && !isGuest
            ? _AccountAction(
                key: const Key('account-edit-profile-action'),
                label: 'Editar perfil',
                icon: LucideIcons.pencil,
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
  const _AccountAction({
    required this.label,
    this.icon,
    this.onPressed,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 47),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: icon == null
            ? Center(
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
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, size: 16, color: AppColors.onBrand),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.onBrand,
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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

class _AccountDataCard extends StatelessWidget {
  const _AccountDataCard({
    required this.displayName,
    required this.email,
    this.controller,
    this.onEdit,
    super.key,
  });

  final String displayName;
  final String email;
  final UserProfileController? controller;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String effectiveName = (controller?.lastName != null && controller!.lastName!.isNotEmpty)
        ? '${controller!.displayName ?? displayName} ${controller!.lastName}'
        : (controller?.displayName ?? displayName);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.controlBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Item 1: Nombre (estilo WhatsApp)
          _buildWhatsAppTile(
            context: context,
            palette: palette,
            icon: LucideIcons.user,
            label: 'Nombre',
            value: effectiveName,
            helper:
                'Visible para el restaurante y en tus pedidos.',
            trailing: onEdit != null
                ? IconButton(
                    key: const Key('account-name-edit-icon'),
                    icon: Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: isDark ? palette.accentGold : palette.brandRed,
                    ),
                    tooltip: 'Editar nombre',
                    onPressed: onEdit,
                  )
                : null,
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: palette.controlBorder),
          // Item 2: Correo electrónico
          _buildWhatsAppTile(
            context: context,
            palette: palette,
            icon: LucideIcons.mail,
            label: 'Correo electrónico',
            value: email,
            helper: 'Cuenta principal vinculada.',
            trailing: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                LucideIcons.badgeCheck,
                size: 20,
                color: palette.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppTile({
    required BuildContext context,
    required AppPalette palette,
    required IconData icon,
    required String label,
    required String value,
    required String helper,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: palette.surfaceTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: palette.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  helper,
                  style: TextStyle(
                    color: palette.textSecondary.withValues(alpha: 0.8),
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
