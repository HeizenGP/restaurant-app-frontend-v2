final class CustomerAddress {
  const CustomerAddress({
    required this.id,
    required this.label,
    required this.address,
    this.reference,
    this.department,
    this.recipientPhone,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String address;
  final String? reference;
  final String? department;
  final String? recipientPhone;
  final bool isDefault;

  String get fullText {
    final StringBuffer buffer = StringBuffer(address);
    if (department != null && department!.trim().isNotEmpty) {
      buffer.write(', Dpto ${department!.trim()}');
    }
    if (reference != null && reference!.trim().isNotEmpty) {
      buffer.write(' (${reference!.trim()})');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAddress &&
          other.id == id &&
          other.label == label &&
          other.address == address &&
          other.reference == reference &&
          other.department == department &&
          other.recipientPhone == recipientPhone &&
          other.isDefault == isDefault;

  @override
  int get hashCode => Object.hash(
        id,
        label,
        address,
        reference,
        department,
        recipientPhone,
        isDefault,
      );
}

final class SavedPaymentCard {
  const SavedPaymentCard({
    required this.id,
    required this.cardNumberMasked,
    required this.cardHolder,
    required this.expiry,
    required this.brand,
    this.documentType,
    this.documentNumber,
  });

  final String id;
  final String cardNumberMasked;
  final String cardHolder;
  final String expiry;
  final String brand;
  final String? documentType;
  final String? documentNumber;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPaymentCard &&
          other.id == id &&
          other.cardNumberMasked == cardNumberMasked &&
          other.cardHolder == cardHolder &&
          other.expiry == expiry &&
          other.brand == brand &&
          other.documentType == documentType &&
          other.documentNumber == documentNumber;

  @override
  int get hashCode => Object.hash(
        id,
        cardNumberMasked,
        cardHolder,
        expiry,
        brand,
        documentType,
        documentNumber,
      );
}

abstract final class ProfileValidators {
  static String? phone(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa tu número de celular.';
    }
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) {
      return 'El celular debe tener exactamente 9 dígitos (ingresaste ${digits.length}).';
    }
    if (!digits.startsWith('9')) {
      return 'El número de celular debe comenzar con 9.';
    }
    return null;
  }

  static String? cardNumber(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa el número de tarjeta.';
    }
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) {
      return 'La tarjeta debe tener exactamente 16 dígitos (ingresaste ${digits.length}).';
    }
    return null;
  }

  static String? cardExpiry(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa la fecha de vencimiento.';
    }
    final RegExp regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regex.hasMatch(raw)) {
      return 'Formato inválido. Usa MM/AA (ej. 12/28).';
    }
    return null;
  }

  static String? cardCvv(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa el código CVV.';
    }
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 3 || digits.length > 4) {
      return 'El CVV debe tener 3 o 4 dígitos.';
    }
    return null;
  }

  static String? cardHolder(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa el nombre del titular como figura en la tarjeta.';
    }
    if (raw.length < 3) {
      return 'El nombre es muy corto.';
    }
    return null;
  }

  static String? address(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa la dirección (calle, número o urbanización).';
    }
    if (raw.length < 5) {
      return 'Ingresa una dirección más detallada.';
    }
    return null;
  }

  static String? addressLabel(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa una etiqueta (ej. Casa, Trabajo, Pareja).';
    }
    return null;
  }
}
