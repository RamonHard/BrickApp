import 'dart:io';

class Truck {
  final String id;
  final String truckModel;
  final String licensePlate;
  final String vehicleType;
  final String capacity;
  final double pricePerKm;
  final String phone;
  final String email;
  final File? photo;
  final String? photoUrl; // Add this
  final DateTime createdAt;
  final String ownerId;
  final bool isAvailable;

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
    this.photoUrl, // Add this
    required this.createdAt,
    required this.ownerId,
    required this.isAvailable,
  });

  // Add copyWith method
  Truck copyWith({
    String? id,
    String? truckModel,
    String? licensePlate,
    String? vehicleType,
    String? capacity,
    double? pricePerKm,
    String? phone,
    String? email,
    File? photo,
    String? photoUrl,
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
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
