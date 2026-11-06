import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';
import '../application/user_profile_controller.dart';
import '../domain/profile_models.dart';

class _PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final String truncated = digits.length > 9 ? digits.substring(0, 9) : digits;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(truncated[i]);
    }
    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardExpiryTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String oldText = oldValue.text;
    final String newText = newValue.text;

    String digits = newText.replaceAll(RegExp(r'\D'), '');
    if (oldText.endsWith('/') && newText.length < oldText.length) {
      if (digits.isNotEmpty) {
        digits = digits.substring(0, digits.length - 1);
      }
    }

    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(digits[i]);
    }

    if (digits.length == 2 &&
        !oldText.endsWith('/') &&
        newText.length > oldText.length) {
      buffer.write('/');
    }

    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.contains('•')) {
      return newValue;
    }
    final String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final String truncated = digits.length > 16 ? digits.substring(0, 16) : digits;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(truncated[i]);
    }
    final String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({
    required this.controller,
    required this.currentDisplayName,
    required this.currentEmail,
    super.key,
  });

  final UserProfileController controller;
  final String currentDisplayName;
  final String currentEmail;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String? _selectedAvatar;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const List<String> _availableAvatars = <String>[
    '🐉',
    '🍜',
    '🥟',
    '🥢',
    '🥠',
    '🏮',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.controller.displayName ?? widget.currentDisplayName,
    );
    _phoneController = TextEditingController(
      text: widget.controller.phone != null
          ? ProfileFormatters.formatPhone(widget.controller.phone!)
          : '',
    );
    _selectedAvatar = widget.controller.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return AlertDialog(
      key: const Key('edit-profile-dialog'),
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
      title: Row(
        children: <Widget>[
          Icon(LucideIcons.userPen, color: palette.accentGold, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Editar perfil',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Avatar selector / photo upload
              Center(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: palette.surfaceTint,
                      child: Text(
                        _selectedAvatar ??
                            (_nameController.text.isNotEmpty
                                ? _nameController.text[0].toUpperCase()
                                : 'C'),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Foto / Ícono de perfil',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _availableAvatars.map((String emoji) {
                        final bool isSelected = _selectedAvatar == emoji;
                        return InkWell(
                          key: Key('avatar-option-$emoji'),
                          onTap: () {
                            setState(() {
                              _selectedAvatar = emoji;
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? palette.brandRed.withValues(alpha: 0.15)
                                  : palette.surfaceTint,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? palette.brandRed
                                    : palette.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 18)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Display name input
              TextFormField(
                key: const Key('profile-name-input'),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  labelStyle: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: palette.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.brandRed),
                  ),
                ),
                validator: (String? val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingresa tu nombre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Phone input with 9 digits validation
              TextFormField(
                key: const Key('profile-phone-input'),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  _PhoneNumberTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Número de celular (9 dígitos)',
                  hintText: 'Ej. 987 654 321',
                  prefixText: '+51 ',
                  labelStyle: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: palette.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.brandRed),
                  ),
                ),
                validator: ProfileValidators.phone,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('profile-cancel-action'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          key: const Key('profile-save-action'),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.brandRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.controller.updateProfile(
                displayName: _nameController.text,
                phone: _phoneController.text,
                avatarPath: _selectedAvatar,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Guardar cambios',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class AddAddressDialog extends StatefulWidget {
  const AddAddressDialog({required this.controller, super.key});

  final UserProfileController controller;

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final TextEditingController _labelController =
      TextEditingController(text: 'Casa');
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return AlertDialog(
      key: const Key('add-address-dialog'),
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
      title: Row(
        children: <Widget>[
          Icon(LucideIcons.mapPin, color: palette.accentGold, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Agregar dirección',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                key: const Key('address-label-input'),
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Alias / Nombre (ej. Casa, Oficina)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                ),
                validator: ProfileValidators.addressLabel,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('address-text-input'),
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Dirección completa (Calle, Nro, Dpto)',
                  hintText: 'Ej. Av. Primavera 450, Santiago de Surco',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                ),
                validator: ProfileValidators.address,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('address-reference-input'),
                controller: _referenceController,
                decoration: InputDecoration(
                  labelText: 'Referencia (opcional)',
                  hintText: 'Ej. Portón negro al lado de la bodega',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('address-cancel-action'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          key: const Key('address-save-action'),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.brandRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.controller.addAddress(
                label: _labelController.text,
                address: _addressController.text,
                reference: _referenceController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Guardar dirección',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class AddCardDialog extends StatefulWidget {
  const AddCardDialog({required this.controller, super.key});

  final UserProfileController controller;

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _holderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return AlertDialog(
      key: const Key('add-card-dialog'),
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
      title: Row(
        children: <Widget>[
          Icon(LucideIcons.creditCard, color: palette.accentGold, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Agregar tarjeta',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Card number with 16-digits validation
              TextFormField(
                key: const Key('card-number-input'),
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s•]')),
                  _CardNumberTextInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta (16 dígitos)',
                  hintText: '4557 0000 0000 0000',
                  prefixIcon: const Icon(LucideIcons.creditCard, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                ),
                validator: ProfileValidators.cardNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('card-holder-input'),
                controller: _holderController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Titular de la tarjeta',
                  hintText: 'NOMBRE COMO FIGURA EN LA TARJETA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                ),
                validator: ProfileValidators.cardHolder,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: const Key('card-expiry-input'),
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        _CardExpiryTextInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Vencimiento',
                        hintText: 'MM/AA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: palette.border),
                        ),
                      ),
                      validator: ProfileValidators.cardExpiry,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      key: const Key('card-cvv-input'),
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: palette.border),
                        ),
                      ),
                      validator: ProfileValidators.cardCvv,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          key: const Key('card-cancel-action'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          key: const Key('card-save-action'),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.brandRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              widget.controller.addCard(
                rawCardNumber: _cardNumberController.text,
                cardHolder: _holderController.text,
                expiry: _expiryController.text,
                cvv: _cvvController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Guardar tarjeta',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
