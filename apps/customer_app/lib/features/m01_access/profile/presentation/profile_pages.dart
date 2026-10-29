import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../application/user_profile_controller.dart';
import '../domain/profile_models.dart';

const List<String> kSampleProfilePhotos = <String>[
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
  'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=300',
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300',
];

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    required this.themeModeController,
    required this.controller,
    required this.currentDisplayName,
    required this.currentEmail,
    this.onBackPressed,
    this.showBackButton = true,
    super.key,
  });

  final ThemeModeController themeModeController;
  final UserProfileController controller;
  final String currentDisplayName;
  final String currentEmail;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _dietaryController;
  late final TextEditingController _customPhotoUrlController;

  String? _currentPhotoPath;
  bool _showPhotoSelector = false;

  @override
  void initState() {
    super.initState();
    _currentPhotoPath = widget.controller.avatarPath;
    _nameController = TextEditingController(
      text: widget.controller.displayName ?? widget.currentDisplayName,
    );
    _lastNameController = TextEditingController(
      text: widget.controller.lastName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.controller.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.currentEmail,
    );
    _birthDateController = TextEditingController(
      text: widget.controller.birthDate ?? '',
    );
    _dietaryController = TextEditingController(
      text: widget.controller.dietaryPreferences ?? '',
    );
    _customPhotoUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _dietaryController.dispose();
    _customPhotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _currentPhotoPath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder a la imagen: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.controller.updateProfile(
      displayName: _nameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      avatarPath: _currentPhotoPath,
      birthDate: _birthDateController.text,
      dietaryPreferences: _dietaryController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente.'),
        duration: Duration(seconds: 2),
      ),
    );

    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ChifaPageScaffold(
        pageKey: const Key('page-edit-profile'),
        title: 'Editar perfil',
        subtitle: 'Actualiza tus datos personales y foto de perfil.',
        themeModeController: widget.themeModeController,
        onBackPressed: widget.onBackPressed,
        showBackButton: widget.showBackButton,
        child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Profile Photo section
            Center(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    key: const Key('edit-profile-avatar-touchable'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProfilePhotoViewerPage(
                            themeModeController: widget.themeModeController,
                            avatarPath: _currentPhotoPath,
                            displayName: _nameController.text.trim().isNotEmpty
                                ? _nameController.text.trim()
                                : widget.currentDisplayName,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: palette.surfaceTint,
                            border: Border.all(
                              color: isDark ? palette.accentGold : palette.brandRed,
                              width: 3,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _buildAvatarImage(palette),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? const Color(0xFF1F2937) : Colors.white,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    key: const Key('view-photo-fullscreen-action'),
                    icon: const Icon(LucideIcons.maximize2, size: 14),
                    label: const Text(
                      'Ver foto completa',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: palette.brandRed,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProfilePhotoViewerPage(
                            themeModeController: widget.themeModeController,
                            avatarPath: _currentPhotoPath,
                            displayName: _nameController.text.trim().isNotEmpty
                                ? _nameController.text.trim()
                                : widget.currentDisplayName,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: <Widget>[
                      OutlinedButton.icon(
                        key: const Key('upload-photo-action'),
                        icon: const Icon(LucideIcons.imageUp, size: 16),
                        label: const Text('Subir / Cambiar foto'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.brandRed,
                          side: BorderSide(color: palette.brandRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showPhotoSelector = !_showPhotoSelector;
                          });
                        },
                      ),
                      if (_currentPhotoPath != null)
                        TextButton.icon(
                          key: const Key('remove-photo-action'),
                          icon: const Icon(LucideIcons.trash2, size: 16),
                          label: const Text('Eliminar'),
                          style: TextButton.styleFrom(
                            foregroundColor: palette.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _currentPhotoPath = null;
                            });
                          },
                        ),
                    ],
                  ),
                  if (_showPhotoSelector) ...<Widget>[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Sube una foto desde tu dispositivo:',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const Key('pick-photo-camera'),
                                  icon: const Icon(LucideIcons.camera, size: 16),
                                  label: const Text('Cámara'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: palette.brandRed,
                                    side: BorderSide(color: palette.brandRed),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _pickImage(ImageSource.camera),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  key: const Key('pick-photo-gallery'),
                                  icon: const Icon(LucideIcons.image, size: 16),
                                  label: const Text('Galería'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: palette.brandRed,
                                    side: BorderSide(color: palette.brandRed),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'O selecciona una foto de retrato:',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: kSampleProfilePhotos.map((String url) {
                                final bool isSelected = _currentPhotoPath == url;
                                return GestureDetector(
                                  key: Key('sample-photo-${kSampleProfilePhotos.indexOf(url)}'),
                                  onTap: () {
                                    setState(() {
                                      _currentPhotoPath = url;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? palette.brandRed
                                            : palette.border,
                                        width: isSelected ? 3 : 1,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(LucideIcons.user),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'O ingresa el enlace directo a tu foto:',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextFormField(
                                  key: const Key('photo-url-input'),
                                  controller: _customPhotoUrlController,
                                  decoration: InputDecoration(
                                    hintText: 'https://ejemplo.com/mifoto.jpg',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: palette.border),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                key: const Key('apply-photo-url-button'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: palette.brandRed,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  final String val = _customPhotoUrlController.text.trim();
                                  if (val.isNotEmpty) {
                                    setState(() {
                                      _currentPhotoPath = val;
                                    });
                                  }
                                },
                                child: const Text('Aplicar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: Datos de Identidad
            _buildSectionHeader(
              icon: LucideIcons.user,
              title: 'DATOS DE IDENTIDAD',
              palette: palette,
            ),
            const SizedBox(height: 10),

            ChifaTextField(
              key: const Key('edit-profile-name'),
              controller: _nameController,
              leadingIcon: LucideIcons.user,
              label: 'Nombre completo',
              hintText: 'Ej. Roberto',
              keyboardType: TextInputType.name,
              validator: (String? val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Ingresa tu nombre completo.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            ChifaTextField(
              key: const Key('edit-profile-lastname'),
              controller: _lastNameController,
              leadingIcon: LucideIcons.userCheck,
              label: 'Apellidos',
              hintText: 'Ej. Wong Chang',
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 12),

            ChifaTextField(
              key: const Key('edit-profile-email'),
              controller: _emailController,
              leadingIcon: LucideIcons.mail,
              label: 'Correo electrónico (Cuenta principal)',
              hintText: 'correo@ejemplo.com',
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),

            const SizedBox(height: 18),

            // Section 2: Contacto y Promociones
            _buildSectionHeader(
              icon: LucideIcons.phone,
              title: 'CONTACTO Y BENEFICIOS',
              palette: palette,
            ),
            const SizedBox(height: 10),

            ChifaTextField(
              key: const Key('edit-profile-phone'),
              controller: _phoneController,
              leadingIcon: LucideIcons.phone,
              label: 'Celular de contacto (Perú - 9 dígitos)',
              hintText: 'Ej. 987654321',
              keyboardType: TextInputType.phone,
              validator: ProfileValidators.phone,
            ),
            const SizedBox(height: 12),

            ChifaTextField(
              key: const Key('edit-profile-birthdate'),
              controller: _birthDateController,
              leadingIcon: LucideIcons.cake,
              label: 'Fecha de nacimiento (Promociones)',
              hintText: 'DD/MM/AAAA (ej. 15/08/1995)',
              keyboardType: TextInputType.datetime,
            ),

            const SizedBox(height: 18),

            // Section 3: Notas de Cocina
            _buildSectionHeader(
              icon: LucideIcons.utensilsCrossed,
              title: 'NOTAS PARA LA COCINA',
              palette: palette,
            ),
            const SizedBox(height: 10),

            ChifaTextField(
              key: const Key('edit-profile-dietary'),
              controller: _dietaryController,
              leadingIcon: LucideIcons.chefHat,
              label: 'Preferencias culinarias / Alergias',
              hintText: 'Ej. Sin picante, poco sillao, alérgico a mariscos',
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 24),

            ChifaButton(
              key: const Key('edit-profile-save-button'),
              label: 'Guardar cambios de perfil',
              leading: LucideIcons.check,
              height: 52,
              borderRadius: 14,
              onPressed: _save,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required AppPalette palette,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: palette.brandRed),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: palette.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage(AppPalette palette) {
    if (_currentPhotoPath != null && _currentPhotoPath!.trim().isNotEmpty) {
      final String path = _currentPhotoPath!.trim();
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackAvatar(palette),
        );
      } else if (path.startsWith('/') || path.startsWith('file:')) {
        return Image.file(
          File(path.replaceFirst('file://', '')),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackAvatar(palette),
        );
      } else {
        return Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackAvatar(palette),
        );
      }
    }
    return _fallbackAvatar(palette);
  }

  Widget _fallbackAvatar(AppPalette palette) {
    final String initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : 'C';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: palette.brandRed,
        ),
      ),
    );
  }
}

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({
    required this.themeModeController,
    required this.controller,
    this.existingAddress,
    this.onBackPressed,
    this.showBackButton = true,
    super.key,
  });

  final ThemeModeController themeModeController;
  final UserProfileController controller;
  final CustomerAddress? existingAddress;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _addressController;
  late final TextEditingController _deptController;
  late final TextEditingController _referenceController;
  late final TextEditingController _phoneController;
  bool _isDefault = false;

  final List<String> _commonLabels = const <String>[
    'Casa',
    'Trabajo',
    'Pareja',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final CustomerAddress? existing = widget.existingAddress;
    _labelController = TextEditingController(text: existing?.label ?? 'Casa');
    _addressController = TextEditingController(text: existing?.address ?? '');
    _deptController = TextEditingController(text: existing?.department ?? '');
    _referenceController = TextEditingController(text: existing?.reference ?? '');
    _phoneController = TextEditingController(text: existing?.recipientPhone ?? '');
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _deptController.dispose();
    _referenceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.existingAddress != null) {
      widget.controller.updateAddress(
        CustomerAddress(
          id: widget.existingAddress!.id,
          label: _labelController.text.trim(),
          address: _addressController.text.trim(),
          department: _deptController.text.trim().isNotEmpty ? _deptController.text.trim() : null,
          reference: _referenceController.text.trim().isNotEmpty ? _referenceController.text.trim() : null,
          recipientPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          isDefault: _isDefault,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dirección actualizada exitosamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      widget.controller.addAddress(
        label: _labelController.text,
        address: _addressController.text,
        department: _deptController.text,
        reference: _referenceController.text,
        recipientPhone: _phoneController.text,
        isDefault: _isDefault,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dirección guardada exitosamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Scaffold(
      body: ChifaPageScaffold(
        pageKey: const Key('page-add-address'),
      title: widget.existingAddress != null ? 'Editar dirección' : 'Nueva dirección',
      subtitle: widget.existingAddress != null
          ? 'Modifica los datos de tu dirección de entrega.'
          : 'Guarda tus direcciones para tus pedidos por delivery.',
      themeModeController: widget.themeModeController,
      onBackPressed: widget.onBackPressed,
      showBackButton: widget.showBackButton,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Tipo de dirección',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _commonLabels.map((String label) {
                  final bool isSelected = _labelController.text.trim() == label;
                  final IconData icon = switch (label) {
                    'Casa' => LucideIcons.house,
                    'Trabajo' => LucideIcons.briefcase,
                    'Pareja' => LucideIcons.heart,
                    _ => LucideIcons.mapPin,
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('address-type-chip-$label'),
                      avatar: Icon(icon, size: 16),
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            _labelController.text = label;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            ChifaTextField(
              key: const Key('address-label-input'),
              controller: _labelController,
              label: 'Nombre / Alias de la dirección',
              hintText: 'Ej. Casa, Depa Surco, Trabajo',
              validator: ProfileValidators.addressLabel,
            ),
            const SizedBox(height: 16),

            ChifaTextField(
              key: const Key('address-text-input'),
              controller: _addressController,
              label: 'Dirección completa (Calle y Nro)',
              hintText: 'Ej. Av. Javier Prado Este 2450, San Borja',
              keyboardType: TextInputType.streetAddress,
              validator: ProfileValidators.address,
            ),
            const SizedBox(height: 16),

            ChifaTextField(
              key: const Key('address-dept-input'),
              controller: _deptController,
              label: 'N° Departamento / Interior / Piso (opcional)',
              hintText: 'Ej. Dpto 402, Torre B, Piso 4',
            ),
            const SizedBox(height: 16),

            ChifaTextField(
              key: const Key('address-reference-input'),
              controller: _referenceController,
              label: 'Referencia para el repartidor',
              hintText: 'Ej. Al lado del banco, reja negra',
              keyboardType: TextInputType.streetAddress,
            ),
            const SizedBox(height: 16),

            ChifaTextField(
              key: const Key('address-phone-input'),
              controller: _phoneController,
              label: 'Teléfono de contacto en recepción (opcional)',
              hintText: 'Ej. 987111222',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            SwitchListTile.adaptive(
              key: const Key('address-default-switch'),
              title: Text(
                'Establecer como dirección principal',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              subtitle: Text(
                'Se seleccionará automáticamente al pedir por delivery.',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  color: palette.textSecondary,
                ),
              ),
              value: _isDefault,
              activeTrackColor: palette.brandRed,
              onChanged: (bool val) => setState(() => _isDefault = val),
            ),

            const SizedBox(height: 32),

            ChifaButton(
              key: const Key('save-address-button'),
              label: widget.existingAddress != null ? 'Guardar cambios' : 'Guardar dirección',
              height: 52,
              borderRadius: 14,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
}

class AddCardPage extends StatefulWidget {
  const AddCardPage({
    required this.themeModeController,
    required this.controller,
    this.existingCard,
    this.onBackPressed,
    this.showBackButton = true,
    super.key,
  });

  final ThemeModeController themeModeController;
  final UserProfileController controller;
  final SavedPaymentCard? existingCard;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardNumberController;
  late final TextEditingController _cardHolderController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  late final TextEditingController _docNumberController;

  String _docType = 'DNI';
  bool _saveForFuture = true;

  @override
  void initState() {
    super.initState();
    final SavedPaymentCard? existing = widget.existingCard;
    _cardNumberController = TextEditingController(text: existing?.cardNumberMasked ?? '');
    _cardHolderController = TextEditingController(text: existing?.cardHolder ?? '');
    _expiryController = TextEditingController(text: existing?.expiry ?? '');
    _cvvController = TextEditingController(text: existing != null ? '•••' : '');
    _docType = existing?.documentType ?? 'DNI';
    _docNumberController = TextEditingController(text: existing?.documentNumber ?? '');

    _cardNumberController.addListener(() => setState(() {}));
    _cardHolderController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.existingCard != null) {
      final String raw = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
      String masked = widget.existingCard!.cardNumberMasked;
      String brand = widget.existingCard!.brand;
      if (raw.length == 16) {
        final String last4 = raw.substring(12);
        masked = '•••• •••• •••• $last4';
        brand = raw.startsWith('4')
            ? 'Visa'
            : (raw.startsWith('5')
                ? 'Mastercard'
                : (raw.startsWith('3') ? 'Amex' : 'Tarjeta'));
      }
      widget.controller.updateCard(
        SavedPaymentCard(
          id: widget.existingCard!.id,
          cardNumberMasked: masked,
          cardHolder: _cardHolderController.text.trim().toUpperCase(),
          expiry: _expiryController.text.trim(),
          brand: brand,
          documentType: _docType,
          documentNumber: _docNumberController.text.trim().isNotEmpty
              ? _docNumberController.text.trim()
              : null,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarjeta actualizada de forma segura.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      widget.controller.addCard(
        rawCardNumber: _cardNumberController.text,
        cardHolder: _cardHolderController.text,
        expiry: _expiryController.text,
        cvv: _cvvController.text,
        documentType: _docType,
        documentNumber: _docNumberController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarjeta guardada de forma segura.'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Scaffold(
      body: ChifaPageScaffold(
        pageKey: const Key('page-add-card'),
      title: widget.existingCard != null ? 'Editar tarjeta' : 'Agregar tarjeta',
      subtitle: widget.existingCard != null
          ? 'Modifica los datos de tu tarjeta guardada.'
          : 'Registra tu medio de pago para pagar con un toque.',
      themeModeController: widget.themeModeController,
      onBackPressed: widget.onBackPressed,
      showBackButton: widget.showBackButton,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Interactive Live Card Preview
            _LiveCreditCardPreview(
              palette: palette,
              rawNumber: _cardNumberController.text,
              holder: _cardHolderController.text,
              expiry: _expiryController.text,
            ),

            const SizedBox(height: 28),

            ChifaTextField(
              key: const Key('card-number-input'),
              controller: _cardNumberController,
              label: 'Número de tarjeta (16 dígitos)',
              hintText: '4557 0000 0000 0000',
              keyboardType: TextInputType.number,
              validator: (String? value) {
                if (widget.existingCard != null && value != null && value.contains('•')) {
                  return null;
                }
                return ProfileValidators.cardNumber(value);
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            ChifaTextField(
              key: const Key('card-holder-input'),
              controller: _cardHolderController,
              label: 'Nombre del titular',
              hintText: 'NOMBRE COMO FIGURA EN LA TARJETA',
              validator: ProfileValidators.cardHolder,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            Row(
              children: <Widget>[
                Expanded(
                  child: ChifaTextField(
                    key: const Key('card-expiry-input'),
                    controller: _expiryController,
                    label: 'Vencimiento',
                    hintText: 'MM/AA',
                    keyboardType: TextInputType.number,
                    validator: ProfileValidators.cardExpiry,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ChifaTextField(
                    key: const Key('card-cvv-input'),
                    controller: _cvvController,
                    label: 'CVV',
                    hintText: '123',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (String? value) {
                      if (widget.existingCard != null && value != null && value.contains('•')) {
                        return null;
                      }
                      return ProfileValidators.cardCvv(value);
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: <Widget>[
                SizedBox(
                  width: 105,
                  child: DropdownButtonFormField<String>(
                    initialValue: _docType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Doc',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: palette.border),
                      ),
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                      DropdownMenuItem(value: 'CE', child: Text('CE')),
                      DropdownMenuItem(value: 'PAS', child: Text('PAS')),
                    ],
                    onChanged: (String? val) {
                      if (val != null) setState(() => _docType = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChifaTextField(
                    key: const Key('card-doc-number-input'),
                    controller: _docNumberController,
                    label: 'N° Documento del titular',
                    hintText: 'Ej. 72345678',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SwitchListTile.adaptive(
              key: const Key('card-save-switch'),
              title: Text(
                'Guardar tarjeta para futuras compras',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              subtitle: Text(
                'Tus compras serán más rápidas y seguras.',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  color: palette.textSecondary,
                ),
              ),
              value: _saveForFuture,
              activeTrackColor: palette.brandRed,
              onChanged: (bool val) => setState(() => _saveForFuture = val),
            ),
            const SizedBox(height: 16),

            const ChifaCard(
              icon: LucideIcons.shieldCheck,
              title: 'Seguridad certificada PCI-DSS',
              subtitle: 'Tus datos viajan con encriptación de 256 bits y nunca se guardan códigos CVV.',
              minimumHeight: 65,
            ),

            const SizedBox(height: 32),

            ChifaButton(
              key: const Key('save-card-button'),
              label: widget.existingCard != null ? 'Guardar cambios' : 'Guardar tarjeta',
              height: 52,
              borderRadius: 14,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
}

class _LiveCreditCardPreview extends StatelessWidget {
  const _LiveCreditCardPreview({
    required this.palette,
    required this.rawNumber,
    required this.holder,
    required this.expiry,
  });

  final AppPalette palette;
  final String rawNumber;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    final String digits = rawNumber.replaceAll(RegExp(r'\D'), '');
    final String brand = digits.startsWith('4')
        ? 'VISA'
        : (digits.startsWith('5')
            ? 'MASTERCARD'
            : (digits.startsWith('3')
                ? 'AMEX'
                : (rawNumber.contains('•') ? 'TARJETA' : 'CHIFA ASIA')));

    // Format into 4 chunks
    final StringBuffer formattedNumber = StringBuffer();
    if (rawNumber.contains('•') && digits.length < 16) {
      formattedNumber.write(rawNumber);
    } else {
      for (int i = 0; i < 16; i++) {
        if (i > 0 && i % 4 == 0) formattedNumber.write('  ');
        if (i < digits.length) {
          formattedNumber.write(digits[i]);
        } else {
          formattedNumber.write('•');
        }
      }
    }

    return AspectRatio(
      aspectRatio: 340 / 195,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFF1F2937),
              Color(0xFF111827),
              Color(0xFF0F172A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Icon(
                      LucideIcons.cpu,
                      color: Color(0xFFD4AF37),
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Icon(
                      LucideIcons.wifi,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ],
                ),
                Text(
                  brand,
                  style: const TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                formattedNumber.toString(),
                style: const TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'TITULAR',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        holder.trim().isNotEmpty
                            ? holder.trim().toUpperCase()
                            : 'NOMBRE DEL CLIENTE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      'VENCE',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      expiry.trim().isNotEmpty ? expiry.trim() : 'MM/AA',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePhotoViewerPage extends StatefulWidget {
  const ProfilePhotoViewerPage({
    required this.themeModeController,
    this.avatarPath,
    this.displayName = 'Foto del perfil',
    this.onEditProfile,
    this.onBackPressed,
    super.key,
  });

  final ThemeModeController themeModeController;
  final String? avatarPath;
  final String displayName;
  final VoidCallback? onEditProfile;
  final VoidCallback? onBackPressed;

  @override
  State<ProfilePhotoViewerPage> createState() => _ProfilePhotoViewerPageState();
}

class _ProfilePhotoViewerPageState extends State<ProfilePhotoViewerPage> {
  bool _showOverlay = true;

  void _handleBack() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? path = widget.avatarPath?.trim();
    final bool hasPhoto = path != null && path.isNotEmpty;

    return Scaffold(
      key: const Key('page-photo-viewer'),
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showOverlay
          ? AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.70),
              elevation: 0,
              leading: IconButton(
                key: const Key('photo-viewer-back'),
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: _handleBack,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.displayName.isNotEmpty
                        ? widget.displayName
                        : 'Foto del perfil',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Chifa ASIA · Perfil de cliente',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                if (widget.onEditProfile != null)
                  IconButton(
                    key: const Key('photo-viewer-edit'),
                    icon: const Icon(LucideIcons.pencil, color: Colors.white),
                    tooltip: 'Editar perfil',
                    onPressed: () {
                      _handleBack();
                      widget.onEditProfile!();
                    },
                  ),
              ],
            )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _showOverlay = !_showOverlay;
          });
        },
        child: Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: hasPhoto
                ? (path.startsWith('http')
                    ? Image.network(
                        path,
                        fit: BoxFit.contain,
                        key: const Key('photo-viewer-image'),
                        errorBuilder: (_, _, _) => _buildPlaceholder(),
                      )
                    : (path.startsWith('/') || path.startsWith('file:'))
                        ? Image.file(
                            File(path.replaceFirst('file://', '')),
                            fit: BoxFit.contain,
                            key: const Key('photo-viewer-image'),
                            errorBuilder: (_, _, _) => _buildPlaceholder(),
                          )
                        : Image.asset(
                            path,
                            fit: BoxFit.contain,
                            key: const Key('photo-viewer-image'),
                            errorBuilder: (_, _, _) => _buildPlaceholder(),
                          ))
                : _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      key: const Key('photo-viewer-placeholder'),
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1F2937),
        border: Border.all(color: const Color(0xFFD4AF37), width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              LucideIcons.user,
              size: 80,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(height: 8),
            Text(
              widget.displayName.isNotEmpty
                  ? widget.displayName[0].toUpperCase()
                  : 'C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
