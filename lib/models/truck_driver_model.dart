// models/truck_model.dart
import 'dart:io';

class Truck {
  final String id;
  final String truckModel;
  final String licensePlate;
  final String vehicleType;
  final String capacity;
  final int pricePerKm;
  final String phone;
  final String email;
  final File? photo;
  final DateTime createdAt;
  final String ownerId; // Add owner ID to track who posted the truck
  final bool isAvailable; // Add availability status

  Truck({
    required this.id,
    required this.truckModel,
    required this.licensePlate,
    required this.vehicleType,
    required this.capacity,
    required this.pricePerKm,
    required this.phone,
    required this.email,
    this.photo,
    required this.createdAt,
    required this.ownerId,
    this.isAvailable = true,
  });

  Truck copyWith({
    String? id,
    String? truckModel,
    String? licensePlate,
    String? vehicleType,
    String? capacity,
    int? pricePerKm,
    String? phone,
    String? email,
    File? photo,
    DateTime? createdAt,
    String? ownerId,
    bool? isAvailable,
  }) {
    return Truck(
      id: id ?? this.id,
      truckModel: truckModel ?? this.truckModel,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      capacity: capacity ?? this.capacity,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
