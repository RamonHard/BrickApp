import 'package:brickapp/utils/urls.dart';

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
  final String? ownerAvatar;
  final DateTime createdAt; // ✅ Changed from nullable to required
  final List<String> insideViews;
  final String? videoPath;
  final int? bedrooms;
  final int? bathrooms;
  final double? squareFeet;
  final int? rating; // ✅ Added rating field
  final String? reviewText; // ✅ Added review text field
  final DateTime? ratedAt; // ✅ Added rated at timestamp

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
    this.ownerAvatar,
    required this.createdAt, // ✅ Now required
    this.insideViews = const [],
    this.videoPath,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.rating, // ✅ Added
    this.reviewText, // ✅ Added
    this.ratedAt, // ✅ Added
  });

  String? get thumbnailUrl {
    if (thumbnail == null || thumbnail!.isEmpty) return null;
    if (thumbnail!.startsWith('http')) return thumbnail;
    return '${AppUrls.baseUrl}/$thumbnail';
  }

  List<String> get insideViewUrls =>
      insideViews.map((img) {
        if (img.startsWith('http')) return img;
        return '${AppUrls.baseUrl}/$img';
      }).toList();

  String? get videoUrl {
    if (videoPath == null || videoPath!.isEmpty) return null;
    if (videoPath!.startsWith('http')) return videoPath;
    return '${AppUrls.baseUrl}/$videoPath';
  }

  factory PropertyBookingModel.fromJson(Map<String, dynamic> json) {
    // Parse inside_views array
    List<String> images = [];
    if (json['inside_views'] != null) {
      final raw = json['inside_views'];
      if (raw is List) {
        images = raw.where((e) => e != null).map((e) => e.toString()).toList();
      }
    }

    // Parse created_at - handle null case
    DateTime createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at']) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    // Parse rating - could be null or 0
    int? rating;
    if (json['rating'] != null) {
      rating = int.tryParse(json['rating'].toString());
      if (rating == 0) rating = null; // Treat 0 as no rating
    }

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
      ownerAvatar: json['owner_avatar'],
      createdAt: createdAt,
      insideViews: images,
      videoPath: json['video_path'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      squareFeet:
          json['square_feet'] != null
              ? double.tryParse(json['square_feet'].toString())
              : null,
      rating: rating,
      reviewText: json['review_text'],
      ratedAt: json['rated_at'] != null
          ? DateTime.tryParse(json['rated_at'])
          : null,
    );
  }

  // ✅ Helper to check if property can be rated
  bool get canRate {
    // Must be visit_confirmed, have no rating, and at least 30 days old
    return status == 'visit_confirmed' &&
        (rating == null || rating == 0) &&
        createdAt.difference(DateTime.now()).inDays.abs() >= 30;
  }

  // ✅ Helper to get days since booking
  int get daysSinceBooking => DateTime.now().difference(createdAt).inDays.abs();

  // ✅ Helper to get days remaining until can rate
  int get daysUntilCanRate => 30 - daysSinceBooking;
}