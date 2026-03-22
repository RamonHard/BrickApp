import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User(accountType: AccountType.client));

  // Called after login or register
  void setFromBackend(Map<String, dynamic> userData, String token) {
    state = User.fromBackend(userData, token: token);
  }

  // Update specific fields after edit profile
  void updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? avatar,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      avatar: avatar,
    );
  }

  // Update role after upgrade
  void updateRole(String role) {
    state = state.copyWith(accountType: User.roleToAccountType(role));
  }

  void clearUser() {
    state = User(accountType: AccountType.client);
  }

  // Getters
  String? get token => state.token;
  bool get isLoggedIn => state.id != null;
  bool get isClient => state.isClient;
  bool get isPropertyManager => state.isPropertyManager;
  bool get isServiceProvider => state.isServiceProvider;
}

final userProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);
