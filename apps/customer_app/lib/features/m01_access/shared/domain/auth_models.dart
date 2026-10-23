enum AuthSessionKind { user, guest }

class CustomerIdentity {
  const CustomerIdentity({
    required this.id,
    required this.displayName,
    required this.email,
    required this.isActive,
    required this.roles,
    required this.createdAt,
  });

  final String id;
  final String displayName;
  final String email;
  final bool isActive;
  final List<String> roles;
  final DateTime createdAt;
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.kind,
    this.refreshToken,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final AuthSessionKind kind;
  final CustomerIdentity? user;

  bool get isGuest => kind == AuthSessionKind.guest;
}

class RegistrationInput {
  const RegistrationInput({
    required this.displayName,
    required this.email,
    required this.password,
  });

  final String displayName;
  final String email;
  final String password;
}

class LoginInput {
  const LoginInput({required this.email, required this.password});

  final String email;
  final String password;
}

abstract final class AccessValidators {
  static String? displayName(String? value) {
    final String name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Ingresa tu nombre completo.';
    }
    if (name.length > 120) {
      return 'El nombre no puede superar 120 caracteres.';
    }
    return null;
  }

  static String? email(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (email.length > 254 ||
        RegExp(r'\s', unicode: true).hasMatch(email) ||
        '@'.allMatches(email).length != 1) {
      return 'Ingresa un correo electrónico válido.';
    }
    final List<String> parts = email.split('@');
    if (parts.any((String part) => part.isEmpty)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (value!.length > 128) {
      return 'La contraseña no puede superar 128 caracteres.';
    }
    return null;
  }

  static String? registrationPassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Crea una contraseña.';
    }
    if (password.length < 8) {
      return 'Usa al menos 8 caracteres.';
    }
    if (password.length > 128) {
      return 'La contraseña no puede superar 128 caracteres.';
    }
    return null;
  }
}
