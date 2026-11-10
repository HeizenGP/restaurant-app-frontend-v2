enum RoleCode {
  customer('CUSTOMER'),
  waiter('WAITER'),
  cashier('CASHIER'),
  admin('ADMIN'),
  kitchen('KITCHEN'),
  superAdmin('SUPER_ADMIN');

  const RoleCode(this.value);
  final String value;

  static RoleCode fromString(String raw) {
    final String clean = raw.trim().toUpperCase();
    return switch (clean) {
      'CUSTOMER' => RoleCode.customer,
      'WAITER' => RoleCode.waiter,
      'CASHIER' => RoleCode.cashier,
      'ADMIN' => RoleCode.admin,
      'KITCHEN' => RoleCode.kitchen,
      'SUPER_ADMIN' => RoleCode.superAdmin,
      _ => RoleCode.customer,
    };
  }

  String get displayName => switch (this) {
    RoleCode.customer => 'Cliente',
    RoleCode.waiter => 'Mozo',
    RoleCode.cashier => 'Cajero',
    RoleCode.admin => 'Administrador',
    RoleCode.kitchen => 'Cocinero',
    RoleCode.superAdmin => 'Super Admin',
  };
}

class StaffUser {
  const StaffUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.isActive,
    required this.roles,
    required this.createdAt,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String email;
  final bool isActive;
  final Set<RoleCode> roles;
  final DateTime createdAt;
  final String? phone;
  final String? avatarUrl;

  bool get isSuperAdmin => roles.contains(RoleCode.superAdmin);
  bool get isAdmin => isSuperAdmin || roles.contains(RoleCode.admin);
  bool get isCashier => isSuperAdmin || roles.contains(RoleCode.cashier);
  bool get isWaiter => isSuperAdmin || roles.contains(RoleCode.waiter);
  bool get isKitchen => isSuperAdmin || roles.contains(RoleCode.kitchen);
  bool get isStaff => roles.any((RoleCode r) => r != RoleCode.customer);

  bool hasRole(RoleCode role) => isSuperAdmin || roles.contains(role);

  factory StaffUser.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rolesRaw =
        json['roles'] as List<dynamic>? ?? <dynamic>[];
    final Set<RoleCode> parsedRoles = rolesRaw
        .map((dynamic r) => RoleCode.fromString(r.toString()))
        .toSet();

    return StaffUser(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      roles: parsedRoles,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'display_name': displayName,
      'email': email,
      'is_active': isActive,
      'roles': roles.map((RoleCode r) => r.value).toList(),
      'created_at': createdAt.toIso8601String(),
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}

class StaffSession {
  const StaffSession({required this.accessToken, this.refreshToken, this.user});

  final String accessToken;
  final String? refreshToken;
  final StaffUser? user;
}
