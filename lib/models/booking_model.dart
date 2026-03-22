class PropertyBookingModel {
  final int id;
  final int clientId;
  final int propertyId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double platformCommission;
  final String status;
  final String? propertyType;
  final String? address;
  final String? description;
  final String? thumbnail;
  final String? ownerName;
  final String? ownerPhone;
  final DateTime? createdAt;

  PropertyBookingModel({
    required this.id,
    required this.clientId,
    required this.propertyId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.platformCommission,
    required this.status,
    this.propertyType,
    this.address,
    this.description,
    this.thumbnail,
    this.ownerName,
    this.ownerPhone,
    this.createdAt,
  });

  String? get thumbnailUrl {
    if (thumbnail == null) return null;
    return 'http://10.0.2.2:3000/$thumbnail';
  }

  factory PropertyBookingModel.fromJson(Map<String, dynamic> json) {
    return PropertyBookingModel(
      id: json['id'],
      clientId: json['client_id'],
      propertyId: json['property_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      platformCommission:
          double.tryParse(json['platform_commission'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      propertyType: json['property_type'],
      address: json['address'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
    );
  }
}

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
      bookingDate: DateTime.parse(json['booking_date']),
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
