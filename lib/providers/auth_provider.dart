// auth_provider.dart
import 'package:brickapp/models/user_model.dart';
import 'package:brickapp/providers/user_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier(this.ref) : super(null);
  final Ref ref;

  void createRegularAccount({
    required String email,
    required String password,
    required String phoneNumber,
    String? fullName,
  }) {
    final user = User(
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      accountType: AccountType.regular,
      registrationDate: DateTime.now(),
    );
    state = user;

    // SYNC: Also update the userProvider
    ref
        .read(userProvider.notifier)
        .setBasicUserInfo(
          email: email,
          phoneNumber: phoneNumber,
          fullName: fullName,
        );
  }

  void createTransportServiceProviderAccount({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
    required String idNumber,
    required String driverPermitNumber,
    required String address,
    required String gender,
    String? businessName,
    String? idFrontPhoto,
    String? idBackPhoto,
    String? facePhoto,
    String? driverPermitPhoto,
  }) {
    final user = User(
      accountType: AccountType.transportServiceProvider,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      idNumber: idNumber,
      driverPermitNumber: driverPermitNumber,
      address: address,
      gender: gender,
      businessName: businessName,
      idFrontPhoto: idFrontPhoto,
      idBackPhoto: idBackPhoto,
      facePhoto: facePhoto,
      driverPermitPhoto: driverPermitPhoto,
      status: 'pending_review',
      registrationDate: DateTime.now(),
    );
    state = user;

    // SYNC: Also update the userProvider
    ref
        .read(userProvider.notifier)
        .setTransportManagerData(
          fullName: fullName,
          phoneNumber: phoneNumber,
          idNumber: idNumber,
          driverPermitNumber: driverPermitNumber,
          address: address,
          gender: gender,
          email: email,
          businessName: businessName,
          idFrontPhoto: idFrontPhoto,
          idBackPhoto: idBackPhoto,
          facePhoto: facePhoto,
          driverPermitPhoto: driverPermitPhoto,
        );
  }

  void createPropertyOwnerAccount({
    required String email,
    required String password,
    required String phoneNumber,
    required String fullName,
    required String idNumber,
    required String businessName,
    required String address,
    required String gender,
    String? idFrontPhoto,
    String? idBackPhoto,
    String? facePhoto,
  }) {
    final user = User(
      accountType: AccountType.propertyOwner,
      email: email,
      phoneNumber: phoneNumber,
      fullName: fullName,
      idNumber: idNumber,
      businessName: businessName,
      address: address,
      gender: gender,
      idFrontPhoto: idFrontPhoto,
      idBackPhoto: idBackPhoto,
      facePhoto: facePhoto,
      status: 'pending_review',
      registrationDate: DateTime.now(),
    );
    state = user;

    // SYNC: Also update the userProvider
    ref
        .read(userProvider.notifier)
        .setPropertyManagerData(
          fullName: fullName,
          phoneNumber: phoneNumber,
          idNumber: idNumber,
          businessName: businessName,
          address: address,
          gender: gender,
          email: email,
          idFrontPhoto: idFrontPhoto,
          idBackPhoto: idBackPhoto,
          facePhoto: facePhoto,
        );
  }

  void login({required String email, required String password}) {
    // For demo - in real app, verify credentials with backend
    final user = User(
      email: email,
      accountType: AccountType.regular,
      registrationDate: DateTime.now(),
    );
    state = user;

    // SYNC: Also update the userProvider
    ref
        .read(userProvider.notifier)
        .setBasicUserInfo(
          email: email,
          phoneNumber: '', // You might get this from your backend
          fullName: '', // You might get this from your backend
        );
  }

  void logout() {
    state = null;
    // SYNC: Also clear the userProvider
    ref.read(userProvider.notifier).clearUser();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>(
  (ref) => AuthNotifier(ref), // Pass ref to the notifier
);
