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
  final DateTime? createdAt;
  final List<String> insideViews; // ✅ new
  final String? videoPath; // ✅ new
  final int? bedrooms; // ✅ new
  final int? bathrooms; // ✅ new
  final double? squareFeet; // ✅ new

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
    this.createdAt,
    this.insideViews = const [],
    this.videoPath,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
  });

  String? get thumbnailUrl {
    if (thumbnail == null || thumbnail!.isEmpty) return null;
    if (thumbnail!.startsWith('http')) return thumbnail;
    return '${AppUrls.baseUrl}/$thumbnail';
  }

  // ✅ Convert relative paths to full URLs
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
    // ✅ Parse inside_views array
    List<String> images = [];
    if (json['inside_views'] != null) {
      final raw = json['inside_views'];
      if (raw is List) {
        images = raw.where((e) => e != null).map((e) => e.toString()).toList();
      }
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
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      insideViews: images,
      videoPath: json['video_path'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      squareFeet:
          json['square_feet'] != null
              ? double.tryParse(json['square_feet'].toString())
              : null,
    );
  }
}
