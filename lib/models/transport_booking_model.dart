class TransportBookingModel {
  final int id;
  final int clientId;
  final int vehicleId;
  final String pickupLocation;
  final String dropoffLocation;
  final double distanceKm;
  final double pricePerKm;
  final double platformCommission;
  final double totalPrice;
  final String status;
  final DateTime bookingDate;
  final String? brand;
  final String? plateNumber;
  final String? vehicleTypeName;
  final String? providerName;
  final String? providerPhone;
  final DateTime? createdAt;

  TransportBookingModel({
    required this.id,
    required this.clientId,
    required this.vehicleId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distanceKm,
    required this.pricePerKm,
    required this.platformCommission,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
    this.brand,
    this.plateNumber,
    this.vehicleTypeName,
    this.providerName,
    this.providerPhone,
    this.createdAt,
  });

  factory TransportBookingModel.fromJson(Map<String, dynamic> json) {
    return TransportBookingModel(
      id: json['id'],
      clientId: json['client_id'],
      vehicleId: json['vehicle_id'],
      pickupLocation: json['pickup_location'] ?? '',
      dropoffLocation: json['dropoff_location'] ?? '',
      distanceKm: double.tryParse(json['distance_km'].toString()) ?? 0,
      pricePerKm: double.tryParse(json['price_per_km'].toString()) ?? 0,
      platformCommission:
          double.tryParse(json['platform_commission'].toString()) ?? 0,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      bookingDate:
          DateTime.tryParse(
            json['booking_date']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(), // ✅ fallback
      brand: json['brand'],
      plateNumber: json['plate_number'],
      vehicleTypeName: json['vehicle_type_name'],
      providerName: json['provider_name'],
      providerPhone: json['provider_phone'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }
}
