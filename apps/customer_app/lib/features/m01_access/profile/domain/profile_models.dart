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

abstract final class ProfileFormatters {
  static String formatPhone(String raw) {
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('51') && digits.length > 9) {
      digits = digits.substring(2);
    }
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 9; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String formatCardNumber(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

abstract final class ProfileValidators {
  static String? phone(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa tu número de celular.';
    }
    if (RegExp(r'[^\d\s\+\-]').hasMatch(raw)) {
      return 'El número solo debe contener dígitos numéricos.';
    }
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('51') && digits.length == 11) {
      digits = digits.substring(2);
    }
    if (digits.length != 9) {
      return 'El celular debe tener exactamente 9 dígitos (ingresaste ${digits.length}).';
    }
    if (!digits.startsWith('9')) {
      return 'El número de celular debe comenzar con 9.';
    }
    return null;
  }

  static bool isLuhnValid(String number) {
    final String clean = number.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 13 || clean.length > 19) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = clean.length - 1; i >= 0; i--) {
      int n = int.parse(clean[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n = (n % 10) + 1;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static String? cardNumber(String? value, {bool validateLuhn = false}) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa el número de tarjeta.';
    }
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) {
      return 'La tarjeta debe tener exactamente 16 dígitos (ingresaste ${digits.length}).';
    }
    if (validateLuhn && !isLuhnValid(digits)) {
      return 'El número de tarjeta no es válido (verificación Luhn).';
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
    final List<String> parts = raw.split('/');
    final int month = int.parse(parts[0]);
    final int year = 2000 + int.parse(parts[1]);
    final DateTime now = DateTime.now();
    final DateTime expiry = DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
    if (expiry.isBefore(now)) {
      return 'La tarjeta está vencida.';
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
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'\.-]+$").hasMatch(raw)) {
      return 'El nombre del titular solo debe contener letras.';
    }
    return null;
  }

  static String? name(String? value, {String label = 'nombre'}) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa tu $label.';
    }
    if (raw.length < 2) {
      return 'El $label debe tener al menos 2 caracteres.';
    }
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]+$").hasMatch(raw)) {
      return 'El $label solo debe contener letras.';
    }
    return null;
  }

  static String? email(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(raw)) {
      return 'Ingresa un correo electrónico válido (ej. usuario@kairo.pe).';
    }
    return null;
  }

  static String? birthDate(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }
    final RegExp regex = RegExp(r'^(\d{2})[\/\-](\d{2})[\/\-](\d{4})$');
    final RegExpMatch? match = regex.firstMatch(raw);
    if (match == null) {
      return 'Usa el formato DD/MM/AAAA (ej. 15/08/1995).';
    }
    final int day = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int year = int.parse(match.group(3)!);

    if (month < 1 || month > 12) {
      return 'El mes debe estar entre 01 y 12.';
    }

    final int maxDaysInMonth = switch (month) {
      2 => (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };

    if (day < 1 || day > maxDaysInMonth) {
      return 'Día inválido para el mes especificado (máx. $maxDaysInMonth).';
    }

    final DateTime date = DateTime(year, month, day);
    final DateTime now = DateTime.now();

    if (date.isAfter(now)) {
      return 'La fecha no puede ser en el futuro.';
    }
    if (year < 1900) {
      return 'Año inválido (debe ser mayor a 1900).';
    }
    return null;
  }

  static String? address(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'Ingresa la dirección (calle, número o urbanización).';
    }
    if (raw.length < 5) {
      return 'Ingresa una dirección más detallada (mínimo 5 caracteres).';
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
