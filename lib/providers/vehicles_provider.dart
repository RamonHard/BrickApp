import 'dart:convert';
import 'package:brickapp/models/vehicles_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../utils/urls.dart';

// Vehicle types provider
final vehicleTypesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final response = await http.get(Uri.parse(AppUrls.vehicleTypes));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['types']);
      } else {
        throw Exception('Failed to load vehicle types');
      }
    });

// All vehicles provider
final vehiclesProvider = FutureProvider.autoDispose<List<VehicleModel>>((
  ref,
) async {
  final response = await http.get(Uri.parse(AppUrls.vehicles));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List list = data['vehicles'];
    return list.map((e) => VehicleModel.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load vehicles');
  }
});

// My vehicles provider — for service providers
final myVehiclesFamilyProvider = FutureProvider.autoDispose
    .family<List<VehicleModel>, String>((ref, token) async {
      final response = await http.get(
        Uri.parse(AppUrls.myVehicles),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['vehicles'];
        return list.map((e) => VehicleModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load your vehicles');
      }
    });

// Selected vehicle type for transport booking
final selectedVehicleTypeProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

// Distance provider
final distanceProvider = StateProvider<double>((ref) => 0.0);

// Price calculation provider
final priceCalculationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
      final vehicleTypeId = params['vehicle_type_id'];
      final distanceKm = params['distance_km'];

      final uri = Uri.parse(AppUrls.transportCalculate).replace(
        queryParameters: {
          'vehicle_type_id': vehicleTypeId.toString(),
          'distance_km': distanceKm.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to calculate price');
      }
    });
