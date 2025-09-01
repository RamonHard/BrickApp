class PostData {
  final String propertyType;
  final String location;
  final String? videoPath;
  final int? price;
  final int? discount;
  final int? commission;
  final String currency;
  final int bedrooms;
  final int baths;
  final int sqft;
  final int units;
  final bool isActive;
  final String? pendingReason;
  final bool isRent;
  final bool isSale;
  final bool hasParking;
  final bool isFurnished;
  final bool hasAC;
  final bool hasInternet;
  final bool hasSecurity;
  final bool isPetFriendly;
  final String description;
  final List<String> photoPaths;

  PostData({
    required this.propertyType,
    required this.location,
    this.price,
    this.discount,
    this.commission,
    required this.currency,
    required this.bedrooms,
    required this.baths,
    required this.sqft,
    required this.units,
    required this.isActive,
    this.pendingReason,
    required this.isRent,
    required this.isSale,
    required this.hasParking,
    required this.isFurnished,
    required this.hasAC,
    this.videoPath,
    required this.hasInternet,
    required this.hasSecurity,
    required this.isPetFriendly,
    required this.description,
    required this.photoPaths,
  });

  PostData copyWith({
    String? propertyType,
    String? location,
    int? price,
    int? discount,
    int? commission,
    String? currency,
    int? bedrooms,
    int? baths,
    int? sqft,
    int? units,
    bool? isActive,
    String? pendingReason,
    bool? isRent,
    bool? isSale,
    bool? hasParking,
    bool? isFurnished,
    bool? hasAC,
    String? videoPath,
    bool? hasInternet,
    bool? hasSecurity,
    bool? isPetFriendly,
    String? description,
    List<String>? photoPaths,
  }) {
    return PostData(
      propertyType: propertyType ?? this.propertyType,
      location: location ?? this.location,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      commission: commission ?? this.commission,
      currency: currency ?? this.currency,
      bedrooms: bedrooms ?? this.bedrooms,
      baths: baths ?? this.baths,
      videoPath: videoPath ?? this.videoPath,
      sqft: sqft ?? this.sqft,
      units: units ?? this.units,
      isActive: isActive ?? this.isActive,
      pendingReason: pendingReason ?? this.pendingReason,
      isRent: isRent ?? this.isRent,
      isSale: isSale ?? this.isSale,
      hasParking: hasParking ?? this.hasParking,
      isFurnished: isFurnished ?? this.isFurnished,
      hasAC: hasAC ?? this.hasAC,
      hasInternet: hasInternet ?? this.hasInternet,
      hasSecurity: hasSecurity ?? this.hasSecurity,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      description: description ?? this.description,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}
