// models/user_model.dart
enum AccountType { transportServiceProvider, propertyOwner, regular }

class User {
  final String? uid;
  final String? email;
  final String? phoneNumber;
  final String? fullName;
  final String? businessName;
  final String? idNumber;
  final String? driverPermitNumber;
  final String? address;
  final String? gender;
  final AccountType accountType;
  final String? idFrontPhoto;
  final String? idBackPhoto;
  final String? facePhoto;
  final String? driverPermitPhoto;
  final String? status;
  final DateTime? registrationDate;

  User({
    this.uid,
    this.email,
    this.phoneNumber,
    this.fullName,
    this.businessName,
    this.idNumber,
    this.driverPermitNumber,
    this.address,
    this.gender,
    required this.accountType,
    this.idFrontPhoto,
    this.idBackPhoto,
    this.facePhoto,
    this.driverPermitPhoto,
    this.status,
    this.registrationDate,
  });

  User copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? businessName,
    String? idNumber,
    String? driverPermitNumber,
    String? address,
    String? gender,
    AccountType? accountType,
    String? idFrontPhoto,
    String? idBackPhoto,
    String? facePhoto,
    String? driverPermitPhoto,
    String? status,
    DateTime? registrationDate,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      idNumber: idNumber ?? this.idNumber,
      driverPermitNumber: driverPermitNumber ?? this.driverPermitNumber,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      accountType: accountType ?? this.accountType,
      idFrontPhoto: idFrontPhoto ?? this.idFrontPhoto,
      idBackPhoto: idBackPhoto ?? this.idBackPhoto,
      facePhoto: facePhoto ?? this.facePhoto,
      driverPermitPhoto: driverPermitPhoto ?? this.driverPermitPhoto,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }

  // FIXED: Make these methods static
  static String accountTypeToString(AccountType type) {
    switch (type) {
      case AccountType.transportServiceProvider:
        return 'transportServiceProvider';
      case AccountType.propertyOwner:
        return 'propertyOwner';
      case AccountType.regular:
      default:
        return 'regular';
    }
  }

  // FIXED: Make these methods static
  static AccountType stringToAccountType(String? typeString) {
    if (typeString == null) return AccountType.regular;

    switch (typeString) {
      case 'transportServiceProvider':
        return AccountType.transportServiceProvider;
      case 'propertyOwner':
        return AccountType.propertyOwner;
      case 'regular':
      default:
        return AccountType.regular;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'businessName': businessName,
      'idNumber': idNumber,
      'driverPermitNumber': driverPermitNumber,
      'address': address,
      'gender': gender,
      'accountType': accountTypeToString(accountType), // Use static method
      'idFrontPhoto': idFrontPhoto,
      'idBackPhoto': idBackPhoto,
      'facePhoto': facePhoto,
      'driverPermitPhoto': driverPermitPhoto,
      'status': status,
      'registrationDate': registrationDate?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      fullName: map['fullName'],
      businessName: map['businessName'],
      idNumber: map['idNumber'],
      driverPermitNumber: map['driverPermitNumber'],
      address: map['address'],
      gender: map['gender'],
      accountType: stringToAccountType(map['accountType']), // Use static method
      idFrontPhoto: map['idFrontPhoto'],
      idBackPhoto: map['idBackPhoto'],
      facePhoto: map['facePhoto'],
      driverPermitPhoto: map['driverPermitPhoto'],
      status: map['status'],
      registrationDate:
          map['registrationDate'] != null
              ? DateTime.parse(map['registrationDate'])
              : null,
    );
  }

  // Helper methods to check account type
  bool get isRegular => accountType == AccountType.regular;
  bool get isPropertyOwner => accountType == AccountType.propertyOwner;
  bool get isTransportManager =>
      accountType == AccountType.transportServiceProvider;

  // Get display name for account type
  String get accountTypeDisplay {
    switch (accountType) {
      case AccountType.propertyOwner:
        return 'Property Manager';
      case AccountType.transportServiceProvider:
        return 'Transport Manager';
      case AccountType.regular:
      default:
        return 'Regular Client';
    }
  }

  // Get account type as string when needed
  String get accountTypeString => accountTypeToString(accountType);
}
