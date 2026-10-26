import 'package:flutter/foundation.dart';

import '../domain/profile_models.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController({
    String? initialDisplayName,
    String? initialLastName,
    String? initialPhone,
    String? initialAvatarPath,
    String? initialBirthDate,
    String? initialDietaryPreferences,
    List<CustomerAddress>? initialAddresses,
    List<SavedPaymentCard>? initialCards,
  })  : _displayName = initialDisplayName,
        _lastName = initialLastName,
        _phone = initialPhone,
        _avatarPath = initialAvatarPath,
        _birthDate = initialBirthDate,
        _dietaryPreferences = initialDietaryPreferences,
        _addresses = initialAddresses ?? <CustomerAddress>[
          const CustomerAddress(
            id: 'addr-default-1',
            label: 'Casa',
            address: 'Av. Las Begonias 123',
            department: '401',
            reference: 'Frente al parque',
            isDefault: true,
          ),
        ],
        _cards = initialCards ?? <SavedPaymentCard>[
          const SavedPaymentCard(
            id: 'card-default-1',
            cardNumberMasked: '•••• •••• •••• 4242',
            cardHolder: 'Titular de Cuenta',
            expiry: '12/28',
            brand: 'Visa',
          ),
        ];

  String? _displayName;
  String? _lastName;
  String? _phone;
  String? _avatarPath;
  String? _birthDate;
  String? _dietaryPreferences;
  int _selectedTabIndex = 0;
  final List<CustomerAddress> _addresses;
  final List<SavedPaymentCard> _cards;

  String? get displayName => _displayName;
  String? get lastName => _lastName;
  String? get phone => _phone;
  String? get avatarPath => _avatarPath;
  String? get birthDate => _birthDate;
  String? get dietaryPreferences => _dietaryPreferences;
  int get selectedTabIndex => _selectedTabIndex;
  List<CustomerAddress> get addresses => List<CustomerAddress>.unmodifiable(_addresses);
  List<SavedPaymentCard> get cards => List<SavedPaymentCard>.unmodifiable(_cards);

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void updateProfile({
    required String displayName,
    String? lastName,
    String? phone,
    String? avatarPath,
    String? birthDate,
    String? dietaryPreferences,
  }) {
    _displayName = displayName.trim();
    if (lastName != null) {
      _lastName = lastName.trim();
    }
    if (phone != null) {
      _phone = phone.trim();
    }
    _avatarPath = avatarPath;
    if (birthDate != null) {
      _birthDate = birthDate.trim();
    }
    if (dietaryPreferences != null) {
      _dietaryPreferences = dietaryPreferences.trim();
    }
    notifyListeners();
  }

  void addAddress({
    required String label,
    required String address,
    String? reference,
    String? department,
    String? recipientPhone,
    bool isDefault = false,
  }) {
    final String id = 'addr-${DateTime.now().millisecondsSinceEpoch}';
    if (isDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        final CustomerAddress a = _addresses[i];
        if (a.isDefault) {
          _addresses[i] = CustomerAddress(
            id: a.id,
            label: a.label,
            address: a.address,
            reference: a.reference,
            department: a.department,
            recipientPhone: a.recipientPhone,
            isDefault: false,
          );
        }
      }
    }
    _addresses.add(
      CustomerAddress(
        id: id,
        label: label.trim(),
        address: address.trim(),
        reference: reference?.trim().isNotEmpty == true ? reference!.trim() : null,
        department: department?.trim().isNotEmpty == true ? department!.trim() : null,
        recipientPhone: recipientPhone?.trim().isNotEmpty == true ? recipientPhone!.trim() : null,
        isDefault: isDefault,
      ),
    );
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((CustomerAddress a) => a.id == id);
    notifyListeners();
  }

  void updateAddress(CustomerAddress updated) {
    final int index = _addresses.indexWhere((CustomerAddress a) => a.id == updated.id);
    if (index == -1) return;
    if (updated.isDefault) {
      for (int i = 0; i < _addresses.length; i++) {
        final CustomerAddress a = _addresses[i];
        if (a.isDefault && a.id != updated.id) {
          _addresses[i] = CustomerAddress(
            id: a.id,
            label: a.label,
            address: a.address,
            reference: a.reference,
            department: a.department,
            recipientPhone: a.recipientPhone,
            isDefault: false,
          );
        }
      }
    }
    _addresses[index] = updated;
    notifyListeners();
  }

  void addCard({
    required String rawCardNumber,
    required String cardHolder,
    required String expiry,
    required String cvv,
    String? documentType,
    String? documentNumber,
  }) {
    final String digits = rawCardNumber.replaceAll(RegExp(r'\D'), '');
    final String last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : '0000';
    final String brand = digits.startsWith('4')
        ? 'Visa'
        : (digits.startsWith('5')
            ? 'Mastercard'
            : (digits.startsWith('3') ? 'Amex' : 'Tarjeta'));

    final String id = 'card-${DateTime.now().millisecondsSinceEpoch}';
    _cards.add(
      SavedPaymentCard(
        id: id,
        cardNumberMasked: '•••• •••• •••• $last4',
        cardHolder: cardHolder.trim().toUpperCase(),
        expiry: expiry.trim(),
        brand: brand,
        documentType: documentType,
        documentNumber: documentNumber?.trim(),
      ),
    );
    notifyListeners();
  }

  void removeCard(String id) {
    _cards.removeWhere((SavedPaymentCard c) => c.id == id);
    notifyListeners();
  }

  void updateCard(SavedPaymentCard updated) {
    final int index = _cards.indexWhere((SavedPaymentCard c) => c.id == updated.id);
    if (index == -1) return;
    _cards[index] = updated;
    notifyListeners();
  }
}
