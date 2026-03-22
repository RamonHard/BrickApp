enum AccountType { service_provider, property_manager, client, admin }

class User {
  final int? id;
  final String? email;
  final String? phone;
  final String? fullName;
  final String? companyName;
  final String? idNumber;
  final String? address;
  final String? gender;
  final String? avatar;
  final String? token;
  final AccountType accountType;
  final bool isVerified;
  final String? status;

  User({
    this.id,
    this.email,
    this.phone,
    this.fullName,
    this.companyName,
    this.idNumber,
    this.address,
    this.gender,
    this.avatar,
    this.token,
    required this.accountType,
    this.isVerified = false,
    this.status,
  });

  User copyWith({
    int? id,
    String? email,
    String? phone,
    String? fullName,
    String? companyName,
    String? idNumber,
    String? address,
    String? gender,
    String? avatar,
    String? token,
    AccountType? accountType,
    bool? isVerified,
    String? status,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
      accountType: accountType ?? this.accountType,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
    );
  }

  // Convert backend role string to AccountType
  static AccountType roleToAccountType(String? role) {
    switch (role) {
      case 'property_manager':
        return AccountType.property_manager;
      case 'service_provider':
        return AccountType.service_provider;
      case 'admin':
        return AccountType.admin;
      default:
        return AccountType.client;
    }
  }

  // Convert AccountType back to backend role string
  static String accountTypeToRole(AccountType type) {
    switch (type) {
      case AccountType.property_manager:
        return 'property_manager';
      case AccountType.service_provider:
        return 'service_provider';
      case AccountType.admin:
        return 'admin';
      default:
        return 'client';
    }
  }

  // Build from backend login/register response
  factory User.fromBackend(Map<String, dynamic> map, {String? token}) {
    return User(
      id: map['id'],
      fullName: map['full_name'] ?? map['fullName'],
      phone: map['phone'],
      email: map['email'],
      avatar: map['avatar'],
      isVerified: map['is_verified'] ?? false,
      accountType: roleToAccountType(map['role']),
      token: token,
    );
  }

  // Helper getters
  bool get isClient => accountType == AccountType.client;
  bool get isPropertyManager => accountType == AccountType.property_manager;
  bool get isServiceProvider => accountType == AccountType.service_provider;
  bool get isAdmin => accountType == AccountType.admin;

  String get displayName => fullName ?? 'User';
  String get displayPhone => phone ?? 'Not set';
  String get displayEmail => email ?? 'Not set';

  String get accountTypeDisplay {
    switch (accountType) {
      case AccountType.property_manager:
        return 'Property Manager';
      case AccountType.service_provider:
        return 'Service Provider';
      case AccountType.admin:
        return 'Admin';
      default:
        return 'Client';
    }
  }

  // Full avatar URL
  String? get avatarUrl {
    if (avatar == null) return null;
    return '${AppBaseUrl.base}/$avatar';
  }
}

class AppBaseUrl {
  static const String base = 'http://10.0.2.2:3000';
}
