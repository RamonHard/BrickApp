import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../utils/urls.dart';

// Transport booking state
class TransportBookingState {
  final String? pickupLocation;
  final String? dropoffLocation;
  final int? selectedVehicleTypeId;
  final String? selectedVehicleTypeName;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final double distanceKm;
  final double? estimatedPrice;
  final bool isLoading;

  const TransportBookingState({
    this.pickupLocation,
    this.dropoffLocation,
    this.selectedVehicleTypeId,
    this.selectedVehicleTypeName,
    this.selectedDate,
    this.selectedTime,
    this.distanceKm = 0,
    this.estimatedPrice,
    this.isLoading = false,
  });

  TransportBookingState copyWith({
    String? pickupLocation,
    String? dropoffLocation,
    int? selectedVehicleTypeId,
    String? selectedVehicleTypeName,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    double? distanceKm,
    double? estimatedPrice,
    bool? isLoading,
  }) {
    return TransportBookingState(
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      selectedVehicleTypeId:
          selectedVehicleTypeId ?? this.selectedVehicleTypeId,
      selectedVehicleTypeName:
          selectedVehicleTypeName ?? this.selectedVehicleTypeName,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Keep old field name so existing code doesn't break
  String? get selectedTruckType => selectedVehicleTypeName;
}

class TransportBookingNotifier extends StateNotifier<TransportBookingState> {
  TransportBookingNotifier() : super(const TransportBookingState());

  void setPickupLocation(String location) =>
      state = state.copyWith(pickupLocation: location);

  void setDropoffLocation(String location) =>
      state = state.copyWith(dropoffLocation: location);

  void setVehicleType(int id, String name) =>
      state = state.copyWith(
        selectedVehicleTypeId: id,
        selectedVehicleTypeName: name,
      );

  void setSelectedDate(DateTime date) =>
      state = state.copyWith(selectedDate: date);

  void setSelectedTime(TimeOfDay time) =>
      state = state.copyWith(selectedTime: time);

  void setDistance(double km) => state = state.copyWith(distanceKm: km);

  // Keep old method name so existing code doesn't break
  void setSelectedTruckType(String type) =>
      state = state.copyWith(selectedVehicleTypeName: type);

  // Fetch live price from backend
  Future<void> calculatePrice(double distanceKm) async {
    if (state.selectedVehicleTypeId == null) return;

    state = state.copyWith(isLoading: true, distanceKm: distanceKm);

    try {
      final uri = Uri.parse(AppUrls.transportCalculate).replace(
        queryParameters: {
          'vehicle_type_id': state.selectedVehicleTypeId.toString(),
          'distance_km': distanceKm.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = state.copyWith(
          estimatedPrice: double.tryParse(data['total'].toString()),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() => state = const TransportBookingState();
}

final bookingProvider =
    StateNotifierProvider<TransportBookingNotifier, TransportBookingState>(
      (ref) => TransportBookingNotifier(),
    );

// Property bookings history
final myPropertyBookingsProvider = FutureProvider.autoDispose
    .family<List<PropertyBookingModel>, String>((ref, token) async {
      final response = await http.get(
        Uri.parse(AppUrls.myBookings),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['bookings'];
        return list.map((e) => PropertyBookingModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load bookings');
      }
    });

// Transport bookings history
final myTransportBookingsProvider = FutureProvider.autoDispose
    .family<List<TransportBookingModel>, String>((ref, token) async {
      final response = await http.get(
        Uri.parse(AppUrls.myTransportBookings),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['bookings'];
        return list.map((e) => TransportBookingModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load transport bookings');
      }
    });
