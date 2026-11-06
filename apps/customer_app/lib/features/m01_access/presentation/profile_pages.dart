import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../profile/application/user_profile_controller.dart';
import '../profile/domain/profile_models.dart';
import '../shared/application/auth_session_controller.dart';

// ==============================================================================
// 1. HUB PRINCIPAL DE CUENTA ("Mi cuenta")
// ==============================================================================

class AccountHubPage extends StatelessWidget {
  const AccountHubPage({
    required this.authController,
    required this.profileController,
    required this.onNavigateToPersonalInfo,
    required this.onNavigateToAddresses,
    required this.onNavigateToPaymentMethods,
    required this.onNavigateToOrders,
    required this.onToggleTheme,
    required this.isDark,
    super.key,
  });

  final AuthSessionController authController;
  final UserProfileController profileController;
  final VoidCallback onNavigateToPersonalInfo;
  final VoidCallback onNavigateToAddresses;
  final VoidCallback onNavigateToPaymentMethods;
  final VoidCallback onNavigateToOrders;
  final VoidCallback onToggleTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[authController, profileController]),
      builder: (BuildContext context, _) {
        final AuthState authState = authController.state;
        final bool isGuest = authState.session?.isGuest ?? true;
        final String name = (profileController.displayName?.isNotEmpty == true)
            ? profileController.displayName!
            : (authState.session?.user?.displayName ?? 'Invitado');
        final String email = authState.session?.user?.email ?? 'invitado@chifaasia.pe';
        final String? photoPath = profileController.avatarPath;

        return AsiaScaffold(
          title: 'Mi cuenta',
          subtitle: 'Gestiona tu perfil, direcciones y pagos',
          onToggleTheme: onToggleTheme,
          isDark: isDark,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 8),
              // Tarjeta de usuario destacada
              AsiaCard(
                padding: const EdgeInsets.all(18),
                onTap: isGuest ? null : onNavigateToPersonalInfo,
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.surfaceSubtle,
                      backgroundImage: photoPath != null
                          ? FileImage(File(photoPath))
                          : null,
                      child: photoPath == null
                          ? Icon(
                              isGuest ? LucideIcons.userX : LucideIcons.user,
                              size: 28,
                              color: theme.brandCrimson,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AsiaTypography.titleMedium.copyWith(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AsiaTypography.bodySmall.copyWith(
                              color: theme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isGuest
                                  ? theme.surfaceSubtle
                                  : theme.brandGold.withValues(alpha: 0.15),
                              borderRadius: AsiaRadii.brPill,
                              border: Border.all(
                                color: isGuest
                                    ? theme.border
                                    : theme.brandGold.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  isGuest ? LucideIcons.info : LucideIcons.checkCheck,
                                  size: 13,
                                  color: isGuest ? theme.textTertiary : theme.brandGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isGuest ? 'Cuenta invitado' : 'Cuenta verificada',
                                  style: AsiaTypography.labelSmall.copyWith(
                                    color: isGuest ? theme.textSecondary : theme.brandGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isGuest)
                      Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: theme.textTertiary,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sección: Mi perfil
              const _SectionTitle(title: 'Mi perfil'),
              const SizedBox(height: 8),
              AsiaCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    _MenuTile(
                      key: const Key('account-personal-info-tile'),
                      icon: LucideIcons.user,
                      title: 'Información personal',
                      subtitle: 'Nombre, teléfono y correo',
                      onTap: onNavigateToPersonalInfo,
                    ),
                    Divider(color: theme.border, height: 1),
                    _MenuTile(
                      key: const Key('account-addresses-tile'),
                      icon: LucideIcons.mapPin,
                      title: 'Direcciones de entrega',
                      subtitle: '${profileController.addresses.length} guardadas',
                      onTap: onNavigateToAddresses,
                    ),
                    Divider(color: theme.border, height: 1),
                    _MenuTile(
                      key: const Key('account-cards-tile'),
                      icon: LucideIcons.creditCard,
                      title: 'Métodos de pago',
                      subtitle: '${profileController.cards.length} tarjetas registradas',
                      onTap: onNavigateToPaymentMethods,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sección: Pedidos & Actividad
              const _SectionTitle(title: 'Pedidos'),
              const SizedBox(height: 8),
              AsiaCard(
                padding: EdgeInsets.zero,
                child: _MenuTile(
                  key: const Key('account-orders-tile'),
                  icon: LucideIcons.receiptText,
                  title: 'Historial de pedidos',
                  subtitle: 'Seguimiento de compras y pedidos pasados',
                  onTap: onNavigateToOrders,
                ),
              ),
              const SizedBox(height: 24),

              // Sección: Sesión
              const _SectionTitle(title: 'Sesión'),
              const SizedBox(height: 8),
              AsiaCard(
                padding: EdgeInsets.zero,
                child: _MenuTile(
                  key: const Key('account-logout-tile'),
                  icon: LucideIcons.logOut,
                  iconColor: theme.error,
                  title: 'Cerrar sesión',
                  subtitle: isGuest ? 'Salir del modo invitado' : 'Desconectar cuenta',
                  onTap: () => _confirmLogout(context),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    showDialog<void>(
      context: context,
      builder: (BuildContext dContext) => AlertDialog(
        backgroundColor: theme.surface,
        shape: const RoundedRectangleBorder(borderRadius: AsiaRadii.brCard),
        title: Text('¿Cerrar sesión?', style: AsiaTypography.titleMedium),
        content: Text(
          'Tendrás que ingresar tus credenciales nuevamente.',
          style: AsiaTypography.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: Text('Cancelar', style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            key: const Key('logout-confirm-button'),
            onPressed: () {
              Navigator.of(dContext).pop();
              authController.logout();
            },
            child: Text('Cerrar sesión', style: TextStyle(color: theme.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// 2. PANTALLA INDEPENDIENTE DE INFORMACIÓN PERSONAL
// ==============================================================================

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({
    required this.profileController,
    required this.onBack,
    super.key,
  });

  final UserProfileController profileController;
  final VoidCallback onBack;

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      await widget.profileController.updateProfile(
        displayName: widget.profileController.displayName ?? 'Cliente',
        avatarPath: file.path,
      );
    }
  }

  void _showEditFieldDialog({
    required String title,
    required String initialValue,
    required ValueChanged<String> onSave,
  }) {
    final TextEditingController textController = TextEditingController(text: initialValue);
    final AsiaTheme theme = context.asiaTheme;

    showDialog<void>(
      context: context,
      builder: (BuildContext dContext) => AlertDialog(
        backgroundColor: theme.surface,
        shape: const RoundedRectangleBorder(borderRadius: AsiaRadii.brCard),
        title: Text(title, style: AsiaTypography.titleMedium),
        content: AsiaTextField(
          controller: textController,
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dContext).pop(),
            child: Text('Cancelar', style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              onSave(textController.text.trim());
              Navigator.of(dContext).pop();
            },
            child: Text('Guardar', style: TextStyle(color: theme.brandCrimson, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.profileController,
      builder: (BuildContext context, _) {
        final String name = widget.profileController.displayName ?? '';
        final String phone = widget.profileController.phone ?? '';
        final String? photoPath = widget.profileController.avatarPath;
        final String address = widget.profileController.addresses.isNotEmpty
            ? widget.profileController.addresses.first.address
            : '';

        return AsiaScaffold(
          title: 'Información personal',
          subtitle: 'Actualiza tus datos de contacto',
          showBack: true,
          onBack: widget.onBack,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: theme.surfaceSubtle,
                      backgroundImage: photoPath != null
                          ? FileImage(File(photoPath))
                          : null,
                      child: photoPath == null
                          ? Icon(LucideIcons.user, size: 40, color: theme.brandCrimson)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: AsiaPressable(
                        onPressed: _pickImage,
                        borderRadius: AsiaRadii.brPill,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.brandCrimson,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.surface, width: 2),
                          ),
                          child: const Icon(LucideIcons.camera, size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name.isNotEmpty ? name : 'Usuario',
                textAlign: TextAlign.center,
                style: AsiaTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              // Tarjetas de datos individuales
              _InfoCard(
                icon: LucideIcons.user,
                label: 'Nombre completo',
                value: name.isNotEmpty ? name : 'No registrado',
                onEdit: () => _showEditFieldDialog(
                  title: 'Editar nombre',
                  initialValue: name,
                  onSave: (String val) => widget.profileController.updateProfile(displayName: val),
                ),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: LucideIcons.phone,
                label: 'Teléfono',
                value: phone.isNotEmpty ? phone : 'No registrado',
                onEdit: () => _showEditFieldDialog(
                  title: 'Editar teléfono',
                  initialValue: phone,
                  onSave: (String val) => widget.profileController.updateProfile(
                    displayName: widget.profileController.displayName ?? 'Cliente',
                    phone: val,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: LucideIcons.mapPin,
                label: 'Dirección principal',
                value: address.isNotEmpty ? address : 'No registrada',
                onEdit: null,
              ),
              const SizedBox(height: 32),

              // Zona de peligro
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.error.withValues(alpha: 0.06),
                  borderRadius: AsiaRadii.brCard,
                  border: Border.all(color: theme.error.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(LucideIcons.triangleAlert, size: 18, color: theme.error),
                        const SizedBox(width: 8),
                        Text(
                          'Zona de peligro',
                          style: AsiaTypography.titleSmall.copyWith(color: theme.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Una vez eliminada tu cuenta, no podrás recuperarla. Todos tus pedidos y datos serán eliminados permanentemente.',
                      style: AsiaTypography.bodySmall.copyWith(
                        color: theme.error.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AsiaButton(
                      label: 'Eliminar mi cuenta',
                      variant: AsiaButtonVariant.danger,
                      height: 44,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Acción restringida por seguridad')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

// ==============================================================================
// 3. PANTALLA INDEPENDIENTE DE DIRECCIONES
// ==============================================================================

class AddressesPage extends StatelessWidget {
  const AddressesPage({
    required this.profileController,
    required this.onBack,
    super.key,
  });

  final UserProfileController profileController;
  final VoidCallback onBack;

  void _showAddAddressDialog(BuildContext context) {
    final TextEditingController labelCtrl = TextEditingController(text: 'Casa');
    final TextEditingController streetCtrl = TextEditingController();
    final TextEditingController refCtrl = TextEditingController();
    final AsiaTheme theme = context.asiaTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Nueva dirección', style: AsiaTypography.titleMedium),
            const SizedBox(height: 16),
            AsiaTextField(
              controller: labelCtrl,
              label: 'Etiqueta (Ej. Casa, Trabajo)',
              prefixIcon: LucideIcons.tag,
            ),
            const SizedBox(height: 12),
            AsiaTextField(
              controller: streetCtrl,
              label: 'Dirección completa (Calle / Av. / Jr.)',
              prefixIcon: LucideIcons.mapPin,
            ),
            const SizedBox(height: 12),
            AsiaTextField(
              controller: refCtrl,
              label: 'Referencia (Opcional)',
              prefixIcon: LucideIcons.info,
            ),
            const SizedBox(height: 20),
            AsiaButton(
              label: 'Guardar Dirección',
              onPressed: () {
                if (streetCtrl.text.trim().isNotEmpty) {
                  profileController.addAddress(
                    label: labelCtrl.text.trim(),
                    address: streetCtrl.text.trim(),
                    reference: refCtrl.text.trim(),
                  );
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: profileController,
      builder: (BuildContext context, _) {
        final List<CustomerAddress> addresses = profileController.addresses;

        return AsiaScaffold(
          title: 'Mis direcciones',
          subtitle: 'Direcciones guardadas para entregas delivery',
          showBack: true,
          onBack: onBack,
          bottomAction: AsiaButton(
            label: 'Agregar nueva dirección',
            leading: LucideIcons.plus,
            onPressed: () => _showAddAddressDialog(context),
          ),
          body: addresses.isEmpty
              ? const AsiaStateView(
                  kind: AsiaStateKind.empty,
                  title: 'No tienes direcciones guardadas',
                  message: 'Agrega una dirección para pedir comida a domicilio más rápido.',
                  icon: LucideIcons.mapPin,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final CustomerAddress address = addresses[index];
                    return AsiaCard(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.surfaceSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.mapPin, size: 19, color: theme.brandCrimson),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      address.label,
                                      style: AsiaTypography.titleSmall,
                                    ),
                                    if (address.isDefault) ...<Widget>[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.brandCrimson.withValues(alpha: 0.12),
                                          borderRadius: AsiaRadii.brPill,
                                        ),
                                        child: Text(
                                          'Predeterminada',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.brandCrimson,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  address.address,
                                  style: AsiaTypography.bodyMedium,
                                ),
                                if (address.reference != null && address.reference!.isNotEmpty)
                                  Text(
                                    'Ref: ${address.reference}',
                                    style: AsiaTypography.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(LucideIcons.trash2, size: 18, color: theme.textTertiary),
                            onPressed: () => profileController.removeAddress(address.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ==============================================================================
// 4. PANTALLA INDEPENDIENTE DE MÉTODOS DE PAGO
// ==============================================================================

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({
    required this.profileController,
    required this.onBack,
    super.key,
  });

  final UserProfileController profileController;
  final VoidCallback onBack;

  void _showAddCardDialog(BuildContext context) {
    final TextEditingController numberCtrl = TextEditingController();
    final TextEditingController holderCtrl = TextEditingController();
    final TextEditingController expiryCtrl = TextEditingController();
    final TextEditingController cvvCtrl = TextEditingController();
    final AsiaTheme theme = context.asiaTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Agregar tarjeta', style: AsiaTypography.titleMedium),
            const SizedBox(height: 16),
            AsiaTextField(
              controller: numberCtrl,
              label: 'Número de tarjeta',
              hintText: '4242 •••• •••• ••••',
              prefixIcon: LucideIcons.creditCard,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AsiaTextField(
              controller: holderCtrl,
              label: 'Titular de la tarjeta',
              hintText: 'Nombre como figura en la tarjeta',
              prefixIcon: LucideIcons.user,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: AsiaTextField(
                    controller: expiryCtrl,
                    label: 'Vencimiento',
                    hintText: '12/28',
                    prefixIcon: LucideIcons.calendar,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AsiaTextField(
                    controller: cvvCtrl,
                    label: 'CVV',
                    hintText: '123',
                    prefixIcon: LucideIcons.lock,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AsiaButton(
              label: 'Vincular Tarjeta',
              onPressed: () {
                if (numberCtrl.text.trim().isNotEmpty && holderCtrl.text.trim().isNotEmpty) {
                  profileController.addCard(
                    rawCardNumber: numberCtrl.text.trim(),
                    cardHolder: holderCtrl.text.trim(),
                    expiry: expiryCtrl.text.trim().isNotEmpty ? expiryCtrl.text.trim() : '12/28',
                    cvv: cvvCtrl.text.trim().isNotEmpty ? cvvCtrl.text.trim() : '123',
                  );
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: profileController,
      builder: (BuildContext context, _) {
        final List<SavedPaymentCard> cards = profileController.cards;

        return AsiaScaffold(
          title: 'Métodos de pago',
          subtitle: 'Tarjetas y billeteras guardadas de forma segura',
          showBack: true,
          onBack: onBack,
          bottomAction: AsiaButton(
            label: 'Agregar nueva tarjeta',
            leading: LucideIcons.plus,
            onPressed: () => _showAddCardDialog(context),
          ),
          body: cards.isEmpty
              ? const AsiaStateView(
                  kind: AsiaStateKind.empty,
                  title: 'No tienes tarjetas guardadas',
                  message: 'Vincula una tarjeta de crédito o débito para pagar en un toque.',
                  icon: LucideIcons.creditCard,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final SavedPaymentCard card = cards[index];
                    return AsiaCard(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.brandCrimson.withValues(alpha: 0.12),
                              borderRadius: AsiaRadii.brSm,
                            ),
                            child: Icon(LucideIcons.creditCard, color: theme.brandCrimson, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  card.cardNumberMasked,
                                  style: AsiaTypography.titleSmall.copyWith(letterSpacing: 1.1),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${card.brand} · Expira: ${card.expiry}',
                                  style: AsiaTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(LucideIcons.trash2, size: 18, color: theme.textTertiary),
                            onPressed: () => profileController.removeCard(card.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ==============================================================================
// COMPONENTES AUXILIARES
// ==============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AsiaTypography.labelLarge.copyWith(
          color: theme.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final Color effectiveIconColor = iconColor ?? theme.textPrimary;

    return AsiaPressable(
      onPressed: onTap,
      borderRadius: AsiaRadii.brMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.surfaceSubtle,
                borderRadius: AsiaRadii.brSm,
              ),
              child: Icon(icon, size: 19, color: effectiveIconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AsiaTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AsiaTypography.bodySmall.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 18, color: theme.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: theme.brandCrimson),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AsiaTypography.labelSmall.copyWith(color: theme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: Icon(LucideIcons.pencil, size: 17, color: theme.brandGold),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
