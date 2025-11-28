// account_form_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountFormState {
  final String email;
  final String password;
  final String phoneNumber;
  final String fullName;
  final String? idFrontPhotoPath;
  final String? idBackPhotoPath;
  final String? driverPermitPath;
  final String? facePhotoPath;

  AccountFormState({
    this.email = '',
    this.password = '',
    this.phoneNumber = '',
    this.fullName = '',
    this.idFrontPhotoPath,
    this.idBackPhotoPath,
    this.driverPermitPath,
    this.facePhotoPath,
  });

  AccountFormState copyWith({
    String? email,
    String? password,
    String? phoneNumber,
    String? fullName,
    String? idFrontPhotoPath,
    String? idBackPhotoPath,
    String? driverPermitPath,
    String? facePhotoPath,
  }) {
    return AccountFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      idFrontPhotoPath: idFrontPhotoPath ?? this.idFrontPhotoPath,
      idBackPhotoPath: idBackPhotoPath ?? this.idBackPhotoPath,
      driverPermitPath: driverPermitPath ?? this.driverPermitPath,
      facePhotoPath: facePhotoPath ?? this.facePhotoPath,
    );
  }
}

class AccountFormNotifier extends StateNotifier<AccountFormState> {
  AccountFormNotifier() : super(AccountFormState());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
  }

  void updateFullName(String fullName) {
    state = state.copyWith(fullName: fullName);
  }

  void updateIdFrontPhoto(String path) {
    state = state.copyWith(idFrontPhotoPath: path);
  }

  void updateIdBackPhoto(String path) {
    state = state.copyWith(idBackPhotoPath: path);
  }

  void updateDriverPermit(String path) {
    state = state.copyWith(driverPermitPath: path);
  }

  void updateFacePhoto(String path) {
    state = state.copyWith(facePhotoPath: path);
  }

  void reset() {
    state = AccountFormState();
  }
}

final accountFormProvider =
    StateNotifierProvider<AccountFormNotifier, AccountFormState>(
      (ref) => AccountFormNotifier(),
    );
