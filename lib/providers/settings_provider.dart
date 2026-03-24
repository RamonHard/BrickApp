import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:brickapp/utils/urls.dart';

class PublicSettings {
  final double commissionPercent;
  final double clientDiscountPercent;
  final int commissionMonths;

  PublicSettings({
    this.commissionPercent = 10.0,
    this.clientDiscountPercent = 8.0,
    this.commissionMonths = 3,
  });
}

final publicSettingsProvider = FutureProvider<PublicSettings>((ref) async {
  try {
    final res = await http.get(Uri.parse(AppUrls.publicSettings));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final settings = List<Map<String, dynamic>>.from(data['settings']);

      double commissionPercent = 10.0;
      double clientDiscountPercent = 8.0;
      int commissionMonths = 3;

      for (final s in settings) {
        if (s['key'] == 'property_commission_percent') {
          commissionPercent = double.tryParse(s['value'].toString()) ?? 10.0;
        }
        if (s['key'] == 'client_discount_percent') {
          clientDiscountPercent = double.tryParse(s['value'].toString()) ?? 8.0;
        }
        if (s['key'] == 'commission_months') {
          commissionMonths = int.tryParse(s['value'].toString()) ?? 3;
        }
      }

      return PublicSettings(
        commissionPercent: commissionPercent,
        clientDiscountPercent: clientDiscountPercent,
        commissionMonths: commissionMonths,
      );
    }
  } catch (e) {
    print('❌ Settings error: $e');
  }

  // Return defaults if fetch fails
  return PublicSettings();
});
