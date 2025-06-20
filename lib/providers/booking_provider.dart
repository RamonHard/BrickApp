import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Booking state model
class BookingState {
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? selectedTruckType;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final double? estimatedPrice;
  final bool isLoading;

  const BookingState({
    this.pickupLocation,
    this.dropoffLocation,
    this.selectedTruckType,
    this.selectedDate,
    this.selectedTime,
    this.estimatedPrice,
    this.isLoading = false,
  });

  BookingState copyWith({
    String? pickupLocation,
    String? dropoffLocation,
    String? selectedTruckType,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    double? estimatedPrice,
    bool? isLoading,
  }) {
    return BookingState(
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      selectedTruckType: selectedTruckType ?? this.selectedTruckType,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Booking StateNotifier
class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  void setPickupLocation(String location) {
    state = state.copyWith(pickupLocation: location);
  }

  void setDropoffLocation(String location) {
    state = state.copyWith(dropoffLocation: location);
  }

  void setSelectedTruckType(String type) {
    state = state.copyWith(selectedTruckType: type);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setSelectedTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  void setEstimatedPrice(double price) {
    state = state.copyWith(estimatedPrice: price);
  }

  void setIsLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void calculatePrice(double distance) {
    double basePrice = 50.0; // Base price
    double distancePrice = distance * 2.0; // $2 per km

    switch (state.selectedTruckType) {
      case 'Small Truck':
        basePrice += 20.0;
        break;
      case 'Medium Truck':
        basePrice += 40.0;
        break;
      case 'Large Truck':
        basePrice += 60.0;
        break;
      default:
        basePrice += 30.0;
    }

    setEstimatedPrice(basePrice + distancePrice);
  }
}

// Riverpod Provider
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((
  ref,
) {
  return BookingNotifier();
});
