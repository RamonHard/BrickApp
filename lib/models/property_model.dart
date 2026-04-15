import 'package:brickapp/utils/urls.dart';

class PropertyModel {
  // ─── Backend fields ────────────────────────────────────
  final int? userId;
  final String listingType;
  final String status;
  final double? rentPrice;
  final double? salePrice;
  final String? ownerName;
  final String? ownerPhone;
  final String? ownerEmail;
  final List<String> images;
  final int? minimumMonths;
  final int? rentDurationMonths;
  // ─── Core fields (used everywhere) ────────────────────
  final int id;
  final String propertyType;
  final String location; // maps to address from backend
  final String description;
  final String numberOfMonths;
  final double price; // maps to rentPrice from backend
  final double discount;
  final double? commission;
  final double? landPercentage;
  final String currency;
  final String thumbnail;
  final String? rulesDocumentPath;
  String? videoPath;

  // bedrooms stays as bedrooms
  // baths = bathrooms (kept as baths to not break existing UI)
  final int bedrooms;
  final int baths; // same as bathrooms
  final double? sqft;
  final int units;
  final bool isActive;
  final bool isLand;
  final String? pendingReason;
  final bool isRent;
  final bool isSale;

  // Amenities
  final bool hasParking;
  final bool isFurnished;
  final bool hasAC;
  final bool hasInternet;
  final bool hasCompound;
  final bool hasSecurity;
  final bool isPetFriendly;
  final List<String> amenities;

  // Media
  final String productIMG;
  final List<String> photoPaths;
  final List<String> insideViews;

  // Ratings
  final double starRating;
  final double reviews;

  // Uploader info
  final String uploaderName;
  final String uploaderEmail;
  final String uploaderIMG;
  final int uploaderPhoneNumber;

  // Sale info
  double enteredSalePrice;
  final String saleConditions;

  // Metadata
  final String? destinationTitle;
  final String? package;
  final DateTime dateCreated;

  PropertyModel({
    // Backend fields
    this.userId,
    this.listingType = '',
    this.status = 'active',
    this.rentPrice,
    this.salePrice,
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
    this.images = const [],
    this.minimumMonths,
    this.rentDurationMonths,
    // Core fields
    required this.id,
    required this.propertyType,
    required this.location,
    required this.description,
    required this.price,
    required this.discount,
    required this.numberOfMonths,
    required this.thumbnail,
    this.commission,
    this.landPercentage,
    this.videoPath,
    required this.currency,
    required this.bedrooms,
    required this.baths,
    required this.sqft,
    required this.units,
    required this.isActive,
    required this.isLand,
    this.pendingReason,
    required this.isRent,
    required this.isSale,
    required this.enteredSalePrice,
    required this.saleConditions,
    required this.hasParking,
    required this.isFurnished,
    required this.hasAC,
    required this.hasInternet,
    required this.hasSecurity,
    required this.hasCompound,
    required this.isPetFriendly,
    required this.amenities,
    required this.productIMG,
    required this.photoPaths,
    this.insideViews = const [],
    required this.starRating,
    required this.reviews,
    required this.uploaderName,
    required this.uploaderEmail,
    required this.uploaderIMG,
    this.rulesDocumentPath,
    required this.uploaderPhoneNumber,
    this.destinationTitle,
    this.package,
    required this.dateCreated,
  });

  // ─── Convenience getters ───────────────────────────────

  // address is an alias for location (backend uses address)
  String? get address => location.isEmpty ? null : location;

  // bathrooms is an alias for baths (backend uses bathrooms)
  int get bathrooms => baths;

  // display price: prefer rentPrice from backend, fall back to price
  double get displayPrice => rentPrice ?? salePrice ?? price;

  // Full URL helpers
  // Find this getter and apply same fix
  String? get thumbnailUrl {
    if (thumbnail == null || thumbnail!.isEmpty) return null;
    if (thumbnail!.startsWith('http')) return thumbnail;
    return '${AppUrls.baseUrl}/$thumbnail';
  }

  List<String> get imageUrls {
    return images
        .map(
          (img) => img.startsWith('http') ? img : 'http://10.0.2.2:3000/$img',
        )
        .toList();
  }

  // ─── Build from backend JSON ───────────────────────────
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // ✅ Parse images array
    final List<String> imgs =
        json['images'] != null
            ? List<String>.from(
              (json['images'] as List).where((e) => e != null),
            )
            : [];

    // ✅ Parse videos array — backend returns 'videos' not 'video_path'
    String? videoPath;
    if (json['videos'] != null && (json['videos'] as List).isNotEmpty) {
      videoPath = json['videos'][0].toString();
    } else if (json['video_path'] != null) {
      videoPath = json['video_path'].toString();
    }

    // ✅ Parse amenities
    final List<String> amenitiesList =
        json['amenities'] != null
            ? List<String>.from(
              (json['amenities'] as List).where((e) => e != null),
            )
            : [];

    final double rPrice =
        json['rent_price'] != null
            ? double.tryParse(json['rent_price'].toString()) ?? 0
            : 0;

    final double sPrice =
        json['sale_price'] != null
            ? double.tryParse(json['sale_price'].toString()) ?? 0
            : 0;

    return PropertyModel(
      userId: json['user_id'],
      listingType: json['listing_type'] ?? '',
      status: json['status'] ?? 'active',
      rentPrice:
          json['rent_price'] != null
              ? double.tryParse(json['rent_price'].toString())
              : null,
      salePrice:
          json['sale_price'] != null
              ? double.tryParse(json['sale_price'].toString())
              : null,
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
      ownerEmail: json['owner_email'],
      images: imgs,
      minimumMonths:
          json['minimum_months'] != null
              ? int.tryParse(json['minimum_months'].toString()) ?? 1
              : (json['rent_duration_months'] != null
                  ? int.tryParse(json['rent_duration_months'].toString()) ?? 1
                  : 1),
      rentDurationMonths: json['rent_duration_months'] ?? 0,
      id: json['id'] ?? 0,
      propertyType: json['property_type'] ?? '',
      location: json['address'] ?? '',
      description: json['description'] ?? '',
      price: rPrice,
      discount: 0,
      numberOfMonths: json['rent_duration_months']?.toString() ?? '',
      thumbnail: json['thumbnail'] ?? '',
      currency: 'UGX',
      bedrooms: json['bedrooms'] ?? 0,
      baths: json['bathrooms'] ?? 0,
      sqft:
          json['square_feet'] != null
              ? double.tryParse(json['square_feet'].toString())
              : null,
      units: json['units'] ?? 0,
      isActive: json['status'] == 'active',
      isLand: json['property_type'] == 'Land',
      isRent: json['listing_type'] == 'rent',
      isSale: json['listing_type'] == 'sale',
      enteredSalePrice: sPrice,
      saleConditions: json['sale_condition'] ?? '',
      pendingReason: json['pending_reason'],
      hasParking:
          amenitiesList.contains('Parking') ||
          amenitiesList.contains('parking'),
      isFurnished:
          amenitiesList.contains('Furnished') ||
          amenitiesList.contains('furnished'),
      hasAC:
          amenitiesList.contains('Air Conditioning') ||
          amenitiesList.contains('AC'),
      hasInternet:
          amenitiesList.contains('Internet') ||
          amenitiesList.contains('internet'),
      hasSecurity:
          amenitiesList.contains('Security') ||
          amenitiesList.contains('security'),
      hasCompound:
          amenitiesList.contains('Compound') ||
          amenitiesList.contains('Commpound') || // ✅ fix typo from DB
          amenitiesList.contains('compound'),
      isPetFriendly:
          amenitiesList.contains('Pet Friendly') ||
          amenitiesList.contains('pet friendly'),
      amenities: amenitiesList,
      productIMG: imgs.isNotEmpty ? imgs.first : '',
      photoPaths: imgs,
      // ✅ insideViews = all images
      insideViews: imgs,
      // ✅ videoPath from videos array
      videoPath: videoPath,
      landPercentage:
          json['land_percentage'] != null
              ? double.tryParse(json['land_percentage'].toString())
              : null,
      starRating: 0,
      reviews: 0,
      uploaderName: json['owner_name'] ?? '',
      uploaderEmail: json['owner_email'] ?? '',
      uploaderIMG:
          json['owner_avatar'] != null &&
                  json['owner_avatar'].toString().isNotEmpty
              ? '${AppUrls.baseUrl}/${json['owner_avatar']}'
              : '',
      uploaderPhoneNumber: 0,
      dateCreated:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
              : DateTime.now(),
      rulesDocumentPath:
          json['documents'] != null && (json['documents'] as List).isNotEmpty
              ? json['documents'][0].toString()
              : null,
    );
  }

  // ─── CopyWith ──────────────────────────────────────────
  PropertyModel copyWith({
    int? userId,
    String? listingType,
    String? status,
    double? rentPrice,
    double? salePrice,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    List<String>? images,
    int? id,
    String? propertyType,
    String? location,
    String? description,
    double? price,
    double? discount,
    double? commission,
    double? landPercentage,
    String? currency,
    String? thumbnail,
    String? videoPath,
    double? enteredSalePrice,
    String? saleConditions,
    int? bedrooms,
    int? baths,
    double? sqft,
    int? units,
    bool? isActive,
    bool? isLand,
    int? minimumMonths,
    String? pendingReason,
    bool? isRent,
    bool? isSale,
    bool? hasParking,
    bool? hasCompound,
    bool? isFurnished,
    bool? hasAC,
    bool? hasInternet,
    bool? hasSecurity,
    bool? isPetFriendly,
    List<String>? amenities,
    String? productIMG,
    List<String>? photoPaths,
    List<String>? insideViews,
    double? starRating,
    double? reviews,
    String? uploaderName,
    String? uploaderEmail,
    String? uploaderIMG,
    int? uploaderPhoneNumber,
    String? numberOfMonths,
    String? destinationTitle,
    String? package,
    DateTime? dateCreated,
    String? rulesDocumentPath,
  }) {
    return PropertyModel(
      userId: userId ?? this.userId,
      listingType: listingType ?? this.listingType,
      status: status ?? this.status,
      rentPrice: rentPrice ?? this.rentPrice,
      salePrice: salePrice ?? this.salePrice,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      images: images ?? this.images,
      id: id ?? this.id,
      propertyType: propertyType ?? this.propertyType,
      location: location ?? this.location,
      minimumMonths: minimumMonths ?? this.minimumMonths,
      description: description ?? this.description,
      numberOfMonths: numberOfMonths ?? this.numberOfMonths,
      thumbnail: thumbnail ?? this.thumbnail,
      price: price ?? this.price,
      enteredSalePrice: enteredSalePrice ?? this.enteredSalePrice,
      saleConditions: saleConditions ?? this.saleConditions,
      discount: discount ?? this.discount,
      commission: commission ?? this.commission,
      landPercentage: landPercentage ?? this.landPercentage,
      currency: currency ?? this.currency,
      bedrooms: bedrooms ?? this.bedrooms,
      baths: baths ?? this.baths,
      sqft: sqft ?? this.sqft,
      units: units ?? this.units,
      isActive: isActive ?? this.isActive,
      isLand: isLand ?? this.isLand,
      pendingReason: pendingReason ?? this.pendingReason,
      isRent: isRent ?? this.isRent,
      isSale: isSale ?? this.isSale,
      hasParking: hasParking ?? this.hasParking,
      hasCompound: hasCompound ?? this.hasCompound,
      isFurnished: isFurnished ?? this.isFurnished,
      hasAC: hasAC ?? this.hasAC,
      hasInternet: hasInternet ?? this.hasInternet,
      hasSecurity: hasSecurity ?? this.hasSecurity,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      amenities: amenities ?? this.amenities,
      productIMG: productIMG ?? this.productIMG,
      photoPaths: photoPaths ?? this.photoPaths,
      videoPath: videoPath ?? this.videoPath,
      rulesDocumentPath: rulesDocumentPath ?? this.rulesDocumentPath,
      insideViews: insideViews ?? this.insideViews,
      starRating: starRating ?? this.starRating,
      reviews: reviews ?? this.reviews,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderEmail: uploaderEmail ?? this.uploaderEmail,
      uploaderIMG: uploaderIMG ?? this.uploaderIMG,
      uploaderPhoneNumber: uploaderPhoneNumber ?? this.uploaderPhoneNumber,
      destinationTitle: destinationTitle ?? this.destinationTitle,
      package: package ?? this.package,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
