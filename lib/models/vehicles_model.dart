class VehicleModel {
  final int id;
  final int userId;
  final int vehicleTypeId;
  final String? vehicleTypeName;
  final double? pricePerKm;
  final String? brand;
  final String plateNumber;
  final String status;
  final List<String> images;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final DateTime? createdAt;

  VehicleModel({
    required this.id,
    required this.userId,
    required this.vehicleTypeId,
    this.vehicleTypeName,
    this.pricePerKm,
    this.brand,
    required this.plateNumber,
    required this.status,
    this.images = const [],
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.createdAt,
  });

  List<String> get imageUrls {
    return images.map((img) => 'http://10.0.2.2:3000/$img').toList();
  }

  String get displayName => '${brand ?? ''} - $plateNumber';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      userId: json['user_id'],
      vehicleTypeId: json['vehicle_type_id'],
      vehicleTypeName: json['vehicle_type_name'],
      pricePerKm:
          json['price_per_km'] != null
              ? double.tryParse(json['price_per_km'].toString())
              : null,
      brand: json['brand'],
      plateNumber: json['plate_number'] ?? '',
      status: json['status'] ?? 'active',
      images:
          json['images'] != null
              ? List<String>.from(
                (json['images'] as List).where((e) => e != null),
              )
              : [],
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
      ownerEmail: json['owner_email'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }
}
