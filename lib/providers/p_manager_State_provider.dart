import 'dart:convert';

import 'package:brickapp/utils/urls.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final managerStatsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, token) async {
    if (token.isEmpty) throw Exception('No token');
    final res = await http.get(
      Uri.parse(AppUrls.managerStats),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Failed to load stats');
    final data = jsonDecode(res.body);
    return data['stats'] ?? {};
  },
);