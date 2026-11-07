import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../../location_delivery/application/location_delivery_controller.dart';
import '../../location_delivery/presentation/map_location_picker_page.dart';
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

  Future<void> _pickAvatar(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        await profileController.updateProfile(
          displayName: profileController.displayName ?? 'Cliente',
          avatarPath: file.path,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        authController,
        profileController,
      ]),
      builder: (BuildContext context, _) {
        final AuthState authState = authController.state;
        final bool isGuest = authState.session?.isGuest ?? true;
        final String name = (profileController.displayName?.isNotEmpty == true)
            ? profileController.displayName!
            : (authState.session?.user?.displayName ?? 'Invitado');
        final String email =
            authState.session?.user?.email ?? 'invitado@kairo.pe';
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
              // Tarjeta de usuario destacada: al presionar Heize no se abre nada,
              // solo se interactúa con la foto de perfil para verla en grande o cambiarla (estilo WhatsApp).
              AsiaCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: <Widget>[
                    Tooltip(
                      message: 'Ver foto de perfil',
                      child: GestureDetector(
                        onTap: () {
                          showProfilePhotoViewer(
                            context: context,
                            photoPath: photoPath,
                            name: name,
                            onEditPhoto: () => _pickAvatar(context),
                          );
                        },
                        child: Stack(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: theme.surfaceSubtle,
                              backgroundImage: photoPath != null
                                  ? FileImage(File(photoPath))
                                  : null,
                              child: photoPath == null
                                  ? Icon(
                                      isGuest
                                          ? LucideIcons.userX
                                          : LucideIcons.user,
                                      size: 28,
                                      color: theme.brandCrimson,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: theme.brandCrimson,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  LucideIcons.camera,
                                  size: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
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
                                  isGuest
                                      ? LucideIcons.info
                                      : LucideIcons.checkCheck,
                                  size: 13,
                                  color: isGuest
                                      ? theme.textTertiary
                                      : theme.brandGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isGuest
                                      ? 'Cuenta invitado'
                                      : 'Cuenta verificada',
                                  style: AsiaTypography.labelSmall.copyWith(
                                    color: isGuest
                                        ? theme.textSecondary
                                        : theme.brandGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                      subtitle:
                          '${profileController.addresses.length} guardadas',
                      onTap: onNavigateToAddresses,
                    ),
                    Divider(color: theme.border, height: 1),
                    _MenuTile(
                      key: const Key('account-cards-tile'),
                      icon: LucideIcons.wallet,
                      title: 'Métodos de pago',
                      subtitle: 'Yape, Plin y Efectivo disponibles',
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
                  subtitle: isGuest
                      ? 'Salir del modo invitado'
                      : 'Desconectar cuenta',
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
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          TextButton(
            key: const Key('logout-confirm-button'),
            onPressed: () {
              Navigator.of(dContext).pop();
              authController.logout();
            },
            child: Text(
              'Cerrar sesión',
              style: TextStyle(color: theme.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// VISOR DE FOTO DE PERFIL A PANTALLA COMPLETA (Estilo WhatsApp)
// ==============================================================================

void showProfilePhotoViewer({
  required BuildContext context,
  required String? photoPath,
  required String name,
  required VoidCallback onEditPhoto,
}) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder:
          (
            BuildContext vContext,
            Animation<double> anim,
            Animation<double> secAnim,
          ) {
            final AsiaTheme theme = vContext.asiaTheme;
            final bool hasValidFile =
                photoPath != null && File(photoPath).existsSync();

            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () => Navigator.of(vContext).pop(),
                ),
                title: const Text(
                  'Foto del perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Editar o cambiar foto',
                    icon: const Icon(LucideIcons.pencil, color: Colors.white),
                    onPressed: () {
                      Navigator.of(vContext).pop();
                      onEditPhoto();
                    },
                  ),
                ],
              ),
              body: Center(
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: hasValidFile
                      ? Image.file(
                          File(photoPath),
                          fit: BoxFit.contain,
                          width: double.infinity,
                        )
                      : Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: theme.surfaceSubtle,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.user,
                            size: 100,
                            color: theme.brandCrimson,
                          ),
                        ),
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: AsiaButton(
                    label: 'Cambiar foto de perfil',
                    leading: LucideIcons.camera,
                    onPressed: () {
                      Navigator.of(vContext).pop();
                      onEditPhoto();
                    },
                  ),
                ),
              ),
            );
          },
    ),
  );
}

// ==============================================================================
// 2. PANTALLA INDEPENDIENTE DE INFORMACIÓN PERSONAL (WhatsApp-style edit)
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
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _phoneFocusNode;

  bool _isEditingName = false;
  bool _isEditingPhone = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profileController.displayName ?? '',
    );
    _phoneController = TextEditingController(
      text: ProfileFormatters.formatPhone(widget.profileController.phone ?? ''),
    );
    _nameFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      await widget.profileController.updateProfile(
        displayName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : (widget.profileController.displayName ?? 'Cliente'),
        avatarPath: file.path,
      );
    }
  }

  Future<void> _handleSave() async {
    final String trimmedName = _nameController.text.trim();
    final String rawPhone = _phoneController.text.trim();

    final String? phoneError = rawPhone.isNotEmpty
        ? ProfileValidators.phone(rawPhone)
        : null;
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              const Icon(
                LucideIcons.circleAlert,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(phoneError)),
            ],
          ),
          backgroundColor: context.asiaTheme.brandCrimson,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final String trimmedPhone = rawPhone.replaceAll(RegExp(r'\s+'), '');

    setState(() {
      _isSaving = true;
      _isEditingName = false;
      _isEditingPhone = false;
    });

    await widget.profileController.updateProfile(
      displayName: trimmedName.isNotEmpty ? trimmedName : 'Cliente',
      phone: trimmedPhone,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: <Widget>[
            Icon(LucideIcons.check, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Datos actualizados correctamente'),
          ],
        ),
        backgroundColor: context.asiaTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: widget.profileController,
      builder: (BuildContext context, _) {
        final String? photoPath = widget.profileController.avatarPath;
        final String name = widget.profileController.displayName ?? 'Cliente';
        final String address = widget.profileController.addresses.isNotEmpty
            ? widget.profileController.addresses.first.address
            : 'No registrada';

        return AsiaScaffold(
          title: 'Información personal',
          subtitle: 'Actualiza tus datos de contacto directamente',
          showBack: true,
          onBack: widget.onBack,
          bottomAction: AsiaButton(
            key: const Key('personal-info-save-button'),
            label: _isSaving ? 'Guardando...' : 'Guardar cambios',
            isLoading: _isSaving,
            leading: LucideIcons.save,
            onPressed: _isSaving ? null : _handleSave,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              // Avatar estilo WhatsApp: al tocarlo se abre en grande, con botón de cámara para cambiar
              Center(
                child: Stack(
                  children: <Widget>[
                    Tooltip(
                      message: 'Ver foto de perfil',
                      child: GestureDetector(
                        onTap: () {
                          showProfilePhotoViewer(
                            context: context,
                            photoPath: photoPath,
                            name: name,
                            onEditPhoto: _pickImage,
                          );
                        },
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: theme.surfaceSubtle,
                          backgroundImage: photoPath != null
                              ? FileImage(File(photoPath))
                              : null,
                          child: photoPath == null
                              ? Icon(
                                  LucideIcons.user,
                                  size: 44,
                                  color: theme.brandCrimson,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Tooltip(
                        message: 'Cambiar foto',
                        child: AsiaPressable(
                          onPressed: _pickImage,
                          borderRadius: AsiaRadii.brPill,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: theme.brandCrimson,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.surface,
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.camera,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Toca tu foto para verla en grande o la cámara para cambiarla',
                textAlign: TextAlign.center,
                style: AsiaTypography.bodySmall.copyWith(
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Formulario editable con iconos de lápiz a la derecha (estilo WhatsApp)
              AsiaCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Datos de contacto',
                      style: AsiaTypography.titleSmall.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Campo: Nombre completo (Lectura con lápiz o edición interactiva)
                    if (!_isEditingName)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: AsiaRadii.brMd,
                          border: Border.all(color: theme.border, width: 0.8),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              LucideIcons.user,
                              size: 20,
                              color: theme.brandCrimson,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Nombre completo',
                                    style: AsiaTypography.labelSmall.copyWith(
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text
                                        : 'No registrado',
                                    style: AsiaTypography.bodyMedium.copyWith(
                                      color: theme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'Editar nombre',
                              child: IconButton(
                                key: const Key('edit-name-button'),
                                icon: Icon(
                                  LucideIcons.pencil,
                                  size: 18,
                                  color: theme.brandGold,
                                ),
                                onPressed: () {
                                  setState(() => _isEditingName = true);
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    _nameFocusNode.requestFocus();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: AsiaRadii.brMd,
                          border: Border.all(
                            color: theme.brandGold,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              LucideIcons.user,
                              size: 20,
                              color: theme.brandCrimson,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                key: const Key('personal-info-name-field'),
                                controller: _nameController,
                                focusNode: _nameFocusNode,
                                style: AsiaTypography.bodyMedium.copyWith(
                                  color: theme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  labelText: 'Nombre completo',
                                  labelStyle: AsiaTypography.labelSmall
                                      .copyWith(color: theme.brandGold),
                                ),
                                onSubmitted: (_) => _handleSave(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.check,
                                size: 20,
                                color: theme.success,
                              ),
                              tooltip: 'Guardar',
                              onPressed: _handleSave,
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.x,
                                size: 20,
                                color: theme.textTertiary,
                              ),
                              tooltip: 'Cancelar',
                              onPressed: () {
                                setState(() {
                                  _nameController.text =
                                      widget.profileController.displayName ??
                                      '';
                                  _isEditingName = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // 2. Campo: Teléfono (Lectura con lápiz o edición interactiva)
                    if (!_isEditingPhone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceSubtle,
                          borderRadius: AsiaRadii.brMd,
                          border: Border.all(color: theme.border, width: 0.8),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              LucideIcons.phone,
                              size: 20,
                              color: theme.brandCrimson,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Teléfono',
                                    style: AsiaTypography.labelSmall.copyWith(
                                      color: theme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _phoneController.text.isNotEmpty
                                        ? ProfileFormatters.formatPhone(
                                            _phoneController.text,
                                          )
                                        : 'No registrado',
                                    style: AsiaTypography.bodyMedium.copyWith(
                                      color: theme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'Editar teléfono',
                              child: IconButton(
                                key: const Key('edit-phone-button'),
                                icon: Icon(
                                  LucideIcons.pencil,
                                  size: 18,
                                  color: theme.brandGold,
                                ),
                                onPressed: () {
                                  setState(() => _isEditingPhone = true);
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    _phoneFocusNode.requestFocus();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: AsiaRadii.brMd,
                          border: Border.all(
                            color: theme.brandGold,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              LucideIcons.phone,
                              size: 20,
                              color: theme.brandCrimson,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                key: const Key('personal-info-phone-field'),
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                inputFormatters: <TextInputFormatter>[
                                  PhoneInputFormatter(),
                                ],
                                style: AsiaTypography.bodyMedium.copyWith(
                                  color: theme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  labelText: 'Teléfono (9 dígitos)',
                                  hintText: '987 654 321',
                                  labelStyle: AsiaTypography.labelSmall
                                      .copyWith(color: theme.brandGold),
                                ),
                                onSubmitted: (_) => _handleSave(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.check,
                                size: 20,
                                color: theme.success,
                              ),
                              tooltip: 'Guardar',
                              onPressed: _handleSave,
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.x,
                                size: 20,
                                color: theme.textTertiary,
                              ),
                              tooltip: 'Cancelar',
                              onPressed: () {
                                setState(() {
                                  _phoneController.text =
                                      ProfileFormatters.formatPhone(
                                        widget.profileController.phone ?? '',
                                      );
                                  _isEditingPhone = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Dirección principal (informativa)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.surfaceSubtle,
                        borderRadius: AsiaRadii.brSm,
                        border: Border.all(color: theme.border, width: 0.8),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            LucideIcons.mapPin,
                            size: 18,
                            color: theme.brandGold,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Dirección principal',
                                  style: AsiaTypography.labelSmall.copyWith(
                                    color: theme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  address,
                                  style: AsiaTypography.bodySmall.copyWith(
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Zona de peligro
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.error.withValues(alpha: 0.06),
                  borderRadius: AsiaRadii.brCard,
                  border: Border.all(
                    color: theme.error.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          LucideIcons.triangleAlert,
                          size: 18,
                          color: theme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Zona de peligro',
                          style: AsiaTypography.titleSmall.copyWith(
                            color: theme.error,
                          ),
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
                          const SnackBar(
                            content: Text('Acción restringida por seguridad'),
                          ),
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
    this.locationDeliveryController,
    super.key,
  });

  final UserProfileController profileController;
  final VoidCallback onBack;
  final LocationDeliveryController? locationDeliveryController;

  void _onAddAddressPressed(BuildContext context) {
    if (locationDeliveryController != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext _) => MapLocationPickerPage(
            controller: locationDeliveryController!,
            onAddressSaved: (CustomerAddress address) {
              profileController.addAddress(
                label: address.label,
                address: address.address,
                reference: address.reference,
                department: address.department,
                recipientPhone: address.recipientPhone,
                latitude: address.latitude,
                longitude: address.longitude,
                isDefault: address.isDefault,
              );
            },
          ),
        ),
      );
    } else {
      _showAddAddressDialog(context);
    }
  }

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
            leading: LucideIcons.mapPin,
            onPressed: () => _onAddAddressPressed(context),
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
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 10),
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
                            child: Icon(
                              LucideIcons.mapPin,
                              size: 19,
                              color: theme.brandCrimson,
                            ),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.brandCrimson.withValues(
                                            alpha: 0.12,
                                          ),
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
                                if (address.reference != null &&
                                    address.reference!.isNotEmpty)
                                  Text(
                                    'Ref: ${address.reference}',
                                    style: AsiaTypography.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              LucideIcons.pencil,
                              size: 18,
                              color: theme.textSecondary,
                            ),
                            tooltip: 'Editar dirección',
                            onPressed: () {
                              if (locationDeliveryController != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext _) =>
                                        MapLocationPickerPage(
                                          controller:
                                              locationDeliveryController!,
                                          addressToEdit: address,
                                          onAddressSaved:
                                              (CustomerAddress updated) {
                                                profileController.updateAddress(
                                                  updated,
                                                );
                                              },
                                        ),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              LucideIcons.trash2,
                              size: 18,
                              color: theme.textTertiary,
                            ),
                            tooltip: 'Eliminar dirección',
                            onPressed: () =>
                                profileController.removeAddress(address.id),
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
// 4. PANTALLA INDEPENDIENTE DE MÉTODOS DE PAGO (Yape, Plin y Efectivo)
// ==============================================================================

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({
    required this.profileController,
    required this.onBack,
    super.key,
  });

  final UserProfileController profileController;
  final VoidCallback onBack;

  static const String _kairoPhone = '987 654 321';
  static const String _kairoHolder = 'KAIRO Restaurant S.A.C.';

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text.replaceAll(' ', '')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            const Icon(LucideIcons.check, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$label copiado al portapapeles'),
          ],
        ),
        backgroundColor: context.asiaTheme.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAddCardDialog(BuildContext context) {
    final TextEditingController numberCtrl = TextEditingController();
    final TextEditingController holderCtrl = TextEditingController();
    final TextEditingController expiryCtrl = TextEditingController();
    final TextEditingController cvvCtrl = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final AsiaTheme theme = ctx.asiaTheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Agregar tarjeta',
                          style: AsiaTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: numberCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        CardNumberInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Número de tarjeta (16 dígitos)',
                        hintText: '4557 1234 5678 9012',
                        border: OutlineInputBorder(
                          borderRadius: AsiaRadii.brMd,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.creditCard,
                          size: 20,
                        ),
                      ),
                      validator: (String? val) {
                        final String raw = (val ?? '').replaceAll(
                          RegExp(r'\D'),
                          '',
                        );
                        if (raw.length != 16) {
                          return 'La tarjeta debe tener 16 dígitos.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: holderCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Titular de la tarjeta',
                        hintText: 'JUAN PEREZ',
                        border: OutlineInputBorder(
                          borderRadius: AsiaRadii.brMd,
                        ),
                        prefixIcon: const Icon(LucideIcons.user, size: 20),
                      ),
                      validator: (String? val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa el nombre del titular.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: expiryCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              ExpiryDateInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Vencimiento (MM/AA)',
                              hintText: '12/28',
                              border: OutlineInputBorder(
                                borderRadius: AsiaRadii.brMd,
                              ),
                            ),
                            validator: (String? val) {
                              final String raw = val ?? '';
                              if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                                  .hasMatch(raw)) {
                                return 'Usa formato MM/AA.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: cvvCtrl,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              border: OutlineInputBorder(
                                borderRadius: AsiaRadii.brMd,
                              ),
                            ),
                            validator: (String? val) {
                              if (val == null || val.length < 3) {
                                return '3 o 4 dígitos.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AsiaButton(
                      label: 'Guardar tarjeta',
                      leading: LucideIcons.check,
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final String rawNumber = numberCtrl.text.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );

                          profileController.addCard(
                            rawCardNumber: rawNumber,
                            cardHolder: holderCtrl.text.trim().toUpperCase(),
                            expiry: expiryCtrl.text.trim(),
                            cvv: cvvCtrl.text.trim(),
                          );

                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: <Widget>[
                                  Icon(
                                    LucideIcons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Tarjeta guardada exitosamente'),
                                ],
                              ),
                              backgroundColor: theme.success,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaScaffold(
      title: 'Métodos de pago',
      subtitle: 'Medios de pago oficiales aceptados en KAIRO',
      showBack: true,
      onBack: onBack,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),

          // Banner de política sin anticipo 50%
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.brandGold.withValues(alpha: 0.1),
              borderRadius: AsiaRadii.brCard,
              border: Border.all(
                color: theme.brandGold.withValues(alpha: 0.35),
                width: 0.9,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(LucideIcons.sparkles, color: theme.brandGold, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Sin anticipo del 50 %',
                        style: AsiaTypography.titleSmall.copyWith(
                          color: theme.brandGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'En KAIRO ya no requerimos adelantos. Puedes pagar el 100 % de tu pedido de forma directa mediante Yape, Plin o en Efectivo al recibirlo.',
                        style: AsiaTypography.bodySmall.copyWith(
                          color: theme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Método: Yape
          _PaymentOptionCard(
            title: 'Yape',
            badgeText: 'Móvil directo',
            icon: LucideIcons.smartphone,
            accentColor: const Color(0xFF742284),
            description: 'Transfiere directamente desde tu app Yape',
            phone: _kairoPhone,
            holder: _kairoHolder,
            onCopy: () =>
                _copyToClipboard(context, _kairoPhone, 'Número de Yape'),
          ),
          const SizedBox(height: 14),

          // 2. Método: Plin
          _PaymentOptionCard(
            title: 'Plin',
            badgeText: 'Móvil directo',
            icon: LucideIcons.zap,
            accentColor: const Color(0xFF00A8E8),
            description: 'Válido para Scotiabank, Interbank, BBVA y BanBif',
            phone: _kairoPhone,
            holder: _kairoHolder,
            onCopy: () =>
                _copyToClipboard(context, _kairoPhone, 'Número de Plin'),
          ),
          const SizedBox(height: 14),

          // 3. Método: Efectivo
          AsiaCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: AsiaRadii.brMd,
                  ),
                  child: const Icon(
                    LucideIcons.banknote,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Efectivo',
                            style: AsiaTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.15),
                              borderRadius: AsiaRadii.brPill,
                            ),
                            child: const Text(
                              'Contra entrega / Salón',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Paga al momento de la entrega o en mesa. Puedes indicar en las notas del pedido si necesitas cambio para un billete en particular.',
                        style: AsiaTypography.bodySmall.copyWith(
                          color: theme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección: Tarjetas Guardadas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Tarjetas guardadas',
                style: AsiaTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () => _openAddCardDialog(context),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.brandCrimson,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          AnimatedBuilder(
            animation: profileController,
            builder: (BuildContext context, _) {
              final List<SavedPaymentCard> cards = profileController.cards;
              if (cards.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surfaceSubtle,
                    borderRadius: AsiaRadii.brMd,
                    border: Border.all(color: theme.border, width: 0.8),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        LucideIcons.creditCard,
                        size: 22,
                        color: theme.textTertiary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No tienes tarjetas guardadas. Agrega una para agilizar tus pagos.',
                          style: AsiaTypography.bodySmall.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: cards.map((SavedPaymentCard card) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: AsiaRadii.brMd,
                      border: Border.all(color: theme.border, width: 0.8),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.brandGold.withValues(alpha: 0.12),
                            borderRadius: AsiaRadii.brSm,
                          ),
                          child: Icon(
                            LucideIcons.creditCard,
                            size: 20,
                            color: theme.brandGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                card.cardNumberMasked,
                                style: AsiaTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${card.cardHolder} • Vence ${card.expiry}',
                                style: AsiaTypography.bodySmall.copyWith(
                                  color: theme.textSecondary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.trash2,
                            size: 18,
                            color: theme.brandCrimson,
                          ),
                          tooltip: 'Eliminar tarjeta',
                          onPressed: () {
                            profileController.removeCard(card.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Tarjeta eliminada'),
                                backgroundColor: theme.brandCrimson,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.title,
    required this.badgeText,
    required this.icon,
    required this.accentColor,
    required this.description,
    required this.phone,
    required this.holder,
    required this.onCopy,
  });

  final String title;
  final String badgeText;
  final IconData icon;
  final Color accentColor;
  final String description;
  final String phone;
  final String holder;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AsiaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: AsiaRadii.brMd,
                ),
                child: Icon(icon, color: accentColor, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          title,
                          style: AsiaTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: AsiaRadii.brPill,
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AsiaTypography.bodySmall.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: AsiaRadii.brSm,
              border: Border.all(color: theme.border, width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Número oficial:',
                      style: AsiaTypography.labelSmall.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: AsiaTypography.titleSmall.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Titular: $holder',
                      style: AsiaTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: theme.textTertiary,
                      ),
                    ),
                  ],
                ),
                AsiaButton(
                  label: 'Copiar',
                  variant: AsiaButtonVariant.secondary,
                  height: 36,
                  leading: LucideIcons.copy,
                  onPressed: onCopy,
                ),
              ],
            ),
          ),
        ],
      ),
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
