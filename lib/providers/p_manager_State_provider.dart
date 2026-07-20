// providers/stats_provider.dart
import 'dart:convert';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final managerStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, token) async {
    if (token.isEmpty) {
      print('❌ Stats: Token is empty');
      throw Exception('Not logged in');
    }

    print('📊 Stats: Fetching manager stats with token: ${token.substring(0, 20)}...');
    
    try {
      final response = await http.get(
        Uri.parse('${AppUrls.baseUrl}/properties/manager/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Stats response status: ${response.statusCode}');
      print('📊 Stats response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode != 200) {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      
      if (data['status'] != true) {
        throw Exception(data['message'] ?? 'Failed to load stats');
      }

      final stats = data['stats'] ?? {};
      
      // Ensure all numeric values are properly typed
      return {
        'total_properties': stats['total_properties'] ?? 0,
        'active_properties': stats['active_properties'] ?? 0,
        'pending_properties': stats['pending_properties'] ?? 0,
        'inactive_properties': stats['inactive_properties'] ?? 0,
        'total_views': stats['total_views'] ?? 0,
        'total_bookings': stats['total_bookings'] ?? 0,
        'total_revenue': (stats['total_revenue'] ?? 0).toDouble(),
        'average_rating': (stats['average_rating'] ?? 0).toDouble(),
        'properties': stats['properties'] ?? [],
        'bookings': stats['bookings'] ?? {},
        'revenue': stats['revenue'] ?? {},
        'monthly_revenue': stats['monthly_revenue'] ?? [],
        'recent_bookings': stats['recent_bookings'] ?? [],
      };
    } catch (e) {
      print('❌ Stats error: $e');
      rethrow;
    }
  },
);

// ✅ Add a provider that doesn't depend on token (uses userProvider internally)
final managerStatsAutoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userState = ref.watch(userProvider);
  final token = userState.token;
  
  if (token == null || token.isEmpty) {
    throw Exception('Not logged in');
  }
  
  return ref.watch(managerStatsProvider(token).future);
});