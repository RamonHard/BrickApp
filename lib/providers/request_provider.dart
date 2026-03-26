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
final providerRequestsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, token) async {
      final res = await http.get(
        Uri.parse(AppUrls.providerRequests),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['bookings']);
      }
      throw Exception('Failed to load provider requests');
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
