import 'package:brickapp/utils/urls.dart';

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
  final bool? isSuspended;
  final String? suspensionReason;
  
  // ✅ New wallet fields
  final double? withdrawableBalance;
  final double? lockedBalance;

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
    this.isSuspended,
    this.suspensionReason,
    this.withdrawableBalance,
    this.lockedBalance,
  });

  bool get isLoggedIn => id != null;
  
  // ✅ Total balance getter
  double get totalBalance => (withdrawableBalance ?? 0) + (lockedBalance ?? 0);
  
  // ✅ Check if user has withdrawable funds
  bool get hasWithdrawableFunds => (withdrawableBalance ?? 0) > 0;
  
  // ✅ Check if user has locked funds
  bool get hasLockedFunds => (lockedBalance ?? 0) > 0;

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
    bool? isSuspended,
    String? suspensionReason,
    double? withdrawableBalance,
    double? lockedBalance,
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
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      withdrawableBalance: withdrawableBalance ?? this.withdrawableBalance,
      lockedBalance: lockedBalance ?? this.lockedBalance,
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
      gender: map['gender'],
      avatar: map['avatar'],
      isVerified: map['is_verified'] ?? false,
      isSuspended: map['is_suspended'] ?? false,
      suspensionReason: map['suspension_reason'],
      accountType: roleToAccountType(map['role']),
      token: token,
      // ✅ Parse wallet balances from backend response
      withdrawableBalance: map['withdrawable_balance'] != null 
          ? double.tryParse(map['withdrawable_balance'].toString()) 
          : null,
      lockedBalance: map['locked_balance'] != null 
          ? double.tryParse(map['locked_balance'].toString()) 
          : null,
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
    return '${AppUrls.baseUrl}/$avatar';
  }
}