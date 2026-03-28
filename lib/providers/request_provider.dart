import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:brickapp/utils/urls.dart';

// ─── Property Manager Requests ─────────────────────────
final managerRequestsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, token) async {
      final res = await http.get(
        Uri.parse(AppUrls.managerRequests),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['bookings']);
      }
      throw Exception('Failed to load manager requests');
    });

// ─── Service Provider Requests ─────────────────────────
final providerRequestsProvider = FutureProvider.family<
  List<Map<String, dynamic>>,
  String
>((ref, token) async {
  if (token.isEmpty) {
    print('❌ No token provided for provider requests');
    return [];
  }

  try {
    print('🌐 Fetching provider requests from: ${AppUrls.providerRequests}');

    final response = await http.get(
      Uri.parse(AppUrls.providerRequests),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📡 Provider requests response status: ${response.statusCode}");
    print("📦 Provider requests response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] == true) {
        final List<dynamic> bookings = data['bookings'] ?? [];
        print("✅ Found ${bookings.length} provider requests");
        return List<Map<String, dynamic>>.from(bookings);
      } else {
        print("⚠️ Error loading provider requests: ${data['message']}");
        return [];
      }
    } else if (response.statusCode == 401) {
      print("🔒 Unauthorized - token may be invalid");
      return [];
    } else if (response.statusCode == 403) {
      print("🚫 Forbidden - user may not have service_provider role");
      return [];
    } else {
      print("❌ Failed to load provider requests: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("💥 Exception loading provider requests: $e");
    return [];
  }
});

// ─── Client Requests ───────────────────────────────────

final clientRequestsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, token) async {
      print('📡 Client requests URL: ${AppUrls.clientRequests}');
      print('📡 Token length: ${token.length}');

      final res = await http.get(
        Uri.parse(AppUrls.clientRequests),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📡 Status: ${res.statusCode}');
      print('📡 Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['bookings']);
      }
      throw Exception(
        'Failed to load client requests: ${res.statusCode} ${res.body}',
      );
    });
