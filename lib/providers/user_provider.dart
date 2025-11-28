// providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User(accountType: AccountType.regular));

  // FIXED: Use the proper static method name
  void setUserData(Map<String, dynamic> data) {
    final processedData = Map<String, dynamic>.from(data);

    // If accountType is already an enum, convert it to string
    if (processedData['accountType'] is AccountType) {
      processedData['accountType'] = User.accountTypeToString(
        processedData['accountType'] as AccountType,
      );
    }

    state = User.fromMap({...state.toMap(), ...processedData});
  }

  void updateUser(User newUser) {
    state = newUser;
  }

  void clearUser() {
    state = User(accountType: AccountType.regular);
  }

  void updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? businessName,
    String? address,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      businessName: businessName,
      address: address,
    );
  }

  void updateAccountType(AccountType type) {
    state = state.copyWith(accountType: type);
  }

  void setBasicUserInfo({
    required String email,
    required String phoneNumber,
    String? fullName,
  }) {
    state = state.copyWith(
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      accountType: AccountType.regular,
      registrationDate: DateTime.now(),
    );
  }

  void setPropertyManagerData({
    required String fullName,
    required String phoneNumber,
    required String idNumber,
    required String businessName,
    required String address,
    required String gender,
    String? email,
    String? idFrontPhoto,
    String? idBackPhoto,
    String? facePhoto,
  }) {
    state = state.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      idNumber: idNumber,
      businessName: businessName,
      address: address,
      gender: gender,
      email: email ?? state.email,
      accountType: AccountType.propertyOwner,
      idFrontPhoto: idFrontPhoto,
      idBackPhoto: idBackPhoto,
      facePhoto: facePhoto,
      status: 'pending_review',
      registrationDate: DateTime.now(),
    );
  }

  void setTransportManagerData({
    required String fullName,
    required String phoneNumber,
    required String idNumber,
    required String driverPermitNumber,
    required String address,
    required String gender,
    String? email,
    String? businessName,
    String? idFrontPhoto,
    String? idBackPhoto,
    String? facePhoto,
    String? driverPermitPhoto,
  }) {
    state = state.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      idNumber: idNumber,
      driverPermitNumber: driverPermitNumber,
      address: address,
      gender: gender,
      email: email ?? state.email,
      businessName: businessName,
      accountType: AccountType.transportServiceProvider,
      idFrontPhoto: idFrontPhoto,
      idBackPhoto: idBackPhoto,
      facePhoto: facePhoto,
      driverPermitPhoto: driverPermitPhoto,
      status: 'pending_review',
      registrationDate: DateTime.now(),
    );
  }

  void updateStatus(String newStatus) {
    state = state.copyWith(status: newStatus);
  }

  // Helper getters
  String get displayName => state.fullName ?? 'User';
  String get displayPhone => state.phoneNumber ?? 'Not set';
  String get displayEmail => state.email ?? 'Not set';
  String get displayAccountType => state.accountTypeDisplay;
  AccountType get currentAccountType => state.accountType;
}

final userProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);
