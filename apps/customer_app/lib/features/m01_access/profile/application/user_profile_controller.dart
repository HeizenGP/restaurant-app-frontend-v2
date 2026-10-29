import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/profile_models.dart';
import '../../shared/domain/auth_models.dart';

typedef RemoteProfileUpdater = Future<void> Function({
  String? displayName,
  String? phone,
  String? avatarUrl,
  List<Map<String, dynamic>>? savedCards,
  List<Map<String, dynamic>>? savedAddresses,
});

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
    FlutterSecureStorage? storage,
  })  : _secureStorage = storage,
        _displayName = initialDisplayName,
        _lastName = initialLastName,
        _phone = initialPhone,
        _avatarPath = initialAvatarPath,
        _birthDate = initialBirthDate,
        _dietaryPreferences = initialDietaryPreferences,
        _addresses = initialAddresses != null
            ? List<CustomerAddress>.from(initialAddresses)
            : <CustomerAddress>[
                const CustomerAddress(
                  id: 'addr-default-1',
                  label: 'Casa',
                  address: 'Av. Las Begonias 123',
                  department: '401',
                  reference: 'Frente al parque',
                  isDefault: true,
                ),
              ],
        _cards = initialCards != null
            ? List<SavedPaymentCard>.from(initialCards)
            : <SavedPaymentCard>[
                const SavedPaymentCard(
                  id: 'card-default-1',
                  cardNumberMasked: '•••• •••• •••• 4242',
                  cardHolder: 'Titular de Cuenta',
                  expiry: '12/28',
                  brand: 'Visa',
                ),
              ];

  final FlutterSecureStorage? _secureStorage;
  static const String _storageKey = 'chifa_asia.user_profile.v1';
  String? _userId;
  RemoteProfileUpdater? _onRemoteUpdate;

  void setRemoteUpdater(RemoteProfileUpdater? updater) {
    _onRemoteUpdate = updater;
  }

  static String storageKeyFor(String? userId) =>
      userId != null && userId.isNotEmpty
          ? 'chifa_asia.user_profile.$userId.v1'
          : _storageKey;

  String? _displayName;
  String? _lastName;
  String? _phone;
  String? _avatarPath;
  String? _birthDate;
  String? _dietaryPreferences;
  int _selectedTabIndex = 0;
  final List<CustomerAddress> _addresses;
  final List<SavedPaymentCard> _cards;

  String? get userId => _userId;
  String? get displayName => _displayName;
  String? get lastName => _lastName;
  String? get phone => _phone;
  String? get avatarPath => _avatarPath;
  String? get birthDate => _birthDate;
  String? get dietaryPreferences => _dietaryPreferences;
  int get selectedTabIndex => _selectedTabIndex;
  List<CustomerAddress> get addresses => List<CustomerAddress>.unmodifiable(_addresses);
  List<SavedPaymentCard> get cards => List<SavedPaymentCard>.unmodifiable(_cards);

  Future<void> loadForUser(String? userId) async {
    _userId = userId;
    _displayName = null;
    _lastName = null;
    _phone = null;
    _avatarPath = null;
    _birthDate = null;
    _dietaryPreferences = null;
    _selectedTabIndex = 0;
    _addresses.clear();
    _cards.clear();

    if (userId == null || userId.isEmpty || _secureStorage == null) {
      notifyListeners();
      return;
    }

    try {
      final String? raw = await _secureStorage.read(key: storageKeyFor(userId));
      if (raw == null || raw.isEmpty) {
        notifyListeners();
        return;
      }
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        notifyListeners();
        return;
      }

      if (decoded['displayName'] is String && (decoded['displayName'] as String).isNotEmpty) {
        _displayName = decoded['displayName'] as String;
      }
      if (decoded['lastName'] is String) {
        _lastName = decoded['lastName'] as String;
      }
      if (decoded['phone'] is String) {
        _phone = decoded['phone'] as String;
      }
      if (decoded['avatarPath'] is String) {
        _avatarPath = decoded['avatarPath'] as String;
      }
      if (decoded['birthDate'] is String) {
        _birthDate = decoded['birthDate'] as String;
      }
      if (decoded['dietaryPreferences'] is String) {
        _dietaryPreferences = decoded['dietaryPreferences'] as String;
      }
      if (decoded['addresses'] is List) {
        final List<dynamic> list = decoded['addresses'] as List<dynamic>;
        for (final dynamic item in list) {
          if (item is Map<String, dynamic>) {
            _addresses.add(CustomerAddress(
              id: item['id'] as String? ?? 'addr-${DateTime.now().millisecondsSinceEpoch}',
              label: item['label'] as String? ?? 'Casa',
              address: item['address'] as String? ?? '',
              reference: item['reference'] as String?,
              department: item['department'] as String?,
              recipientPhone: item['recipientPhone'] as String?,
              isDefault: item['isDefault'] as bool? ?? false,
            ));
          }
        }
      }
      if (decoded['cards'] is List) {
        final List<dynamic> list = decoded['cards'] as List<dynamic>;
        for (final dynamic item in list) {
          if (item is Map<String, dynamic>) {
            _cards.add(SavedPaymentCard(
              id: item['id'] as String? ?? 'card-${DateTime.now().millisecondsSinceEpoch}',
              cardNumberMasked: item['cardNumberMasked'] as String? ?? '•••• 0000',
              cardHolder: item['cardHolder'] as String? ?? '',
              expiry: item['expiry'] as String? ?? '',
              brand: item['brand'] as String? ?? 'Visa',
              documentType: item['documentType'] as String?,
              documentNumber: item['documentNumber'] as String?,
            ));
          }
        }
      }
    } catch (_) {
      // Safe fallback on corrupted storage
    }
    notifyListeners();
  }

  void clear() {
    _userId = null;
    _displayName = null;
    _lastName = null;
    _phone = null;
    _avatarPath = null;
    _birthDate = null;
    _dietaryPreferences = null;
    _selectedTabIndex = 0;
    _addresses.clear();
    _cards.clear();
    notifyListeners();
  }

  Future<void> clearLegacyStorage() async {
    try {
      await _secureStorage?.delete(key: _storageKey);
    } catch (_) {}
  }

  Future<void> loadFromStorage() => loadForUser(_userId);

  Future<void> saveToStorage() async {
    if (_secureStorage == null) return;
    try {
      final Map<String, dynamic> data = <String, dynamic>{
        'displayName': _displayName,
        'lastName': _lastName,
        'phone': _phone,
        'avatarPath': _avatarPath,
        'birthDate': _birthDate,
        'dietaryPreferences': _dietaryPreferences,
        'addresses': _addresses.map((CustomerAddress a) => <String, dynamic>{
          'id': a.id,
          'label': a.label,
          'address': a.address,
          'reference': a.reference,
          'department': a.department,
          'recipientPhone': a.recipientPhone,
          'isDefault': a.isDefault,
        }).toList(),
        'cards': _cards.map((SavedPaymentCard c) => <String, dynamic>{
          'id': c.id,
          'cardNumberMasked': c.cardNumberMasked,
          'cardHolder': c.cardHolder,
          'expiry': c.expiry,
          'brand': c.brand,
          'documentType': c.documentType,
          'documentNumber': c.documentNumber,
        }).toList(),
      };
      await _secureStorage.write(key: storageKeyFor(_userId), value: jsonEncode(data));
    } catch (_) {
      // Ignore write errors
    }
  }

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void syncWithUser(CustomerIdentity? user) {
    if (user == null) {
      clear();
      return;
    }
    _userId = user.id;
    _displayName = user.displayName;
    if (user.phone != null && user.phone!.isNotEmpty) {
      _phone = user.phone;
    }
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      _avatarPath = user.avatarUrl;
    }
    if (user.savedAddresses.isNotEmpty) {
      _addresses.clear();
      for (final dynamic item in user.savedAddresses) {
        if (item is Map<String, dynamic>) {
          _addresses.add(CustomerAddress(
            id: item['id'] as String? ?? 'addr-${DateTime.now().millisecondsSinceEpoch}',
            label: item['label'] as String? ?? 'Casa',
            address: item['address'] as String? ?? '',
            reference: item['reference'] as String?,
            department: item['department'] as String?,
            recipientPhone: item['recipient_phone'] as String?,
            isDefault: item['is_default'] as bool? ?? false,
          ));
        }
      }
    }
    if (user.savedCards.isNotEmpty) {
      _cards.clear();
      for (final dynamic item in user.savedCards) {
        if (item is Map<String, dynamic>) {
          _cards.add(SavedPaymentCard(
            id: item['id'] as String? ?? 'card-${DateTime.now().millisecondsSinceEpoch}',
            cardNumberMasked: item['card_number_masked'] as String? ?? '•••• 0000',
            cardHolder: item['card_holder'] as String? ?? '',
            expiry: item['expiry'] as String? ?? '',
            brand: item['brand'] as String? ?? 'Visa',
            documentType: item['document_type'] as String?,
            documentNumber: item['document_number'] as String?,
          ));
        }
      }
    }
    notifyListeners();
    unawaited(saveToStorage());
  }

  void _syncRemote() {
    if (_onRemoteUpdate == null || _userId == null) return;
    final List<Map<String, dynamic>> cardsData = _cards.map((SavedPaymentCard c) => <String, dynamic>{
      'id': c.id,
      'card_number_masked': c.cardNumberMasked,
      'card_holder': c.cardHolder,
      'expiry': c.expiry,
      'brand': c.brand,
      if (c.documentType != null) 'document_type': c.documentType,
      if (c.documentNumber != null) 'document_number': c.documentNumber,
    }).toList();

    final List<Map<String, dynamic>> addressesData = _addresses.map((CustomerAddress a) => <String, dynamic>{
      'id': a.id,
      'label': a.label,
      'address': a.address,
      if (a.reference != null) 'reference': a.reference,
      if (a.department != null) 'department': a.department,
      if (a.recipientPhone != null) 'recipient_phone': a.recipientPhone,
      'is_default': a.isDefault,
    }).toList();

    unawaited(_onRemoteUpdate!(
      displayName: _displayName,
      phone: _phone,
      avatarUrl: _avatarPath,
      savedCards: cardsData,
      savedAddresses: addressesData,
    ));
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
    unawaited(saveToStorage());
    _syncRemote();
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
    unawaited(saveToStorage());
    _syncRemote();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((CustomerAddress a) => a.id == id);
    notifyListeners();
    unawaited(saveToStorage());
    _syncRemote();
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
    unawaited(saveToStorage());
    _syncRemote();
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
    unawaited(saveToStorage());
    _syncRemote();
  }

  void removeCard(String id) {
    _cards.removeWhere((SavedPaymentCard c) => c.id == id);
    notifyListeners();
    unawaited(saveToStorage());
    _syncRemote();
  }

  void updateCard(SavedPaymentCard updated) {
    final int index = _cards.indexWhere((SavedPaymentCard c) => c.id == updated.id);
    if (index == -1) return;
    _cards[index] = updated;
    notifyListeners();
    unawaited(saveToStorage());
    _syncRemote();
  }
}
