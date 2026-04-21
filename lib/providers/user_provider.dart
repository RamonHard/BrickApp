import 'dart:async';
import 'dart:convert';

import 'package:brickapp/utils/urls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<User> {
  Timer? _refreshTimer;
  bool _isRefreshing = false;
  DateTime _lastRefresh = DateTime.now();
  static const _minRefreshInterval = Duration(minutes: 5);

  UserNotifier() : super(User(accountType: AccountType.client)) {
    // Don't start auto-refresh immediately - wait for login
    // _startAutoRefresh(); // Remove this line - start only after login
  }

  // Called after login or register
  void setFromBackend(Map<String, dynamic> userData, String token) {
    state = User.fromBackend(userData, token: token);
    // Start auto-refresh after login
    _startAutoRefresh();
    // Refresh immediately after login
    refreshProfile();
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
    _stopAutoRefresh();
    state = User(accountType: AccountType.client);
  }

  // Start auto-refresh timer
  void _startAutoRefresh() {
    _stopAutoRefresh(); // Stop any existing timer
    if (state.id != null) {
      // Use state.id directly instead of isLoggedIn getter
      _refreshTimer = Timer.periodic(_minRefreshInterval, (timer) {
        refreshProfile();
      });
      print('✅ Auto-refresh started (every 40 seconds)');
    }
  }

  // Stop auto-refresh timer
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    print('🛑 Auto-refresh stopped');
  }

  // Getters
  String? get token => state.token;
  bool get isLoggedIn => state.id != null;
  bool get isClient => state.isClient;
  bool get isPropertyManager => state.isPropertyManager;
  bool get isServiceProvider => state.isServiceProvider;

  // Refresh profile with throttling to prevent multiple rapid calls
  Future<void> refreshProfile() async {
    if (_isRefreshing) return; // ✅ Remove print

    final token = state.token;
    if (token == null) return; // ✅ Remove print

    _isRefreshing = true;
    _lastRefresh = DateTime.now();

    try {
      // ✅ Remove the print here too
      final res = await http.get(
        Uri.parse('${AppUrls.baseUrl}/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final user = data['user'] ?? data;
        state = User.fromBackend(user, token: token);
        // ✅ Remove success print
      } else if (res.statusCode == 401) {
        clearUser();
      }
    } catch (e) {
      // ✅ Keep only error prints
      print('❌ Profile refresh error: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  // Manual refresh (can be called from UI)
  Future<void> manualRefresh() async {
    print('🖱️ Manual refresh requested');
    await refreshProfile();
  }

  // Force immediate refresh regardless of interval
  Future<void> forceRefresh() async {
    print('⚡ Force refresh requested');
    await refreshProfile();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);

// Optional: Provider to watch refresh status
final isRefreshingProvider = Provider<bool>((ref) {
  final notifier = ref.read(userProvider.notifier);
  return (notifier as UserNotifier)._isRefreshing;
});
