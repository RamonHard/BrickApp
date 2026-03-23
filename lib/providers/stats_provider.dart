import 'dart:convert';
import 'package:brickapp/pages/pManagerPages/p_manager_seetings.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final managerStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, token) async {
      final response = await http.get(
        Uri.parse(AppUrls.managerStats),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['stats'];
      }
      throw Exception('Failed to load stats');
    });

// Payment settings state
final paymentSettingsProvider =
    StateNotifierProvider<PaymentSettingsNotifier, PaymentSettingsState>(
      (ref) => PaymentSettingsNotifier(),
    );
