import 'package:hooks_riverpod/hooks_riverpod.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
      return UserProfileNotifier();
    });

class UserProfileState {
  final String userName;
  final String phoneNumber;
  final String fullName;
  final String gender;
  final bool isExpanded;

  UserProfileState({
    this.userName = "Ramon Hardluck",
    this.phoneNumber = "0740856741",
    this.fullName = "Ramon Hard",
    this.gender = "Male",
    this.isExpanded = false,
  });

  UserProfileState copyWith({
    String? userName,
    String? phoneNumber,
    String? fullName,
    String? gender,
    bool? isExpanded,
  }) {
    return UserProfileState(
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(UserProfileState());

  void toggleExpansion() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void updateProfile({
    String? userName,
    String? phoneNumber,
    String? fullName,
    String? gender,
  }) {
    state = state.copyWith(
      userName: userName ?? state.userName,
      phoneNumber: phoneNumber ?? state.phoneNumber,
      fullName: fullName ?? state.fullName,
      gender: gender ?? state.gender,
    );
  }
}
