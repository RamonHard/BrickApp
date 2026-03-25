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

final clientRequestsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      token,
    ) async {
      if (token.isEmpty) {
        throw Exception('No authentication token found');
      }

      try {
        final response = await http.get(
          Uri.parse(AppUrls.clientRequests),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('📡 API Response Status: ${response.statusCode}');
        print('📡 API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Check the response structure
          print('📡 Decoded data: $data');

          // Handle different response structures
          if (data['status'] == true && data['bookings'] != null) {
            final bookings = List<Map<String, dynamic>>.from(data['bookings']);
            print('✅ Found ${bookings.length} bookings');
            return bookings;
          } else if (data is List) {
            // If the API returns a list directly
            final bookings = List<Map<String, dynamic>>.from(data);
            print('✅ Found ${bookings.length} bookings (direct list)');
            return bookings;
          } else {
            print('⚠️ Unexpected response structure: $data');
            return [];
          }
        } else if (response.statusCode == 401) {
          throw Exception('Session expired. Please login again.');
        } else {
          throw Exception('Failed to load requests: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error fetching client requests: $e');
        throw Exception('Error loading requests: $e');
      }
    });
