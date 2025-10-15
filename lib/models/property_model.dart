class PropertyModel {
  // Core property details
  final int id;
  final String propertyType;
  final String location;
  final String description;
  final double price;
  final double discount;
  final double? commission;
  final String currency;
  final String thumbnail;
  String? videoPath;
  // Structure
  final int bedrooms;
  final int baths;
  final double? sqft;
  final int units;
  final bool isActive;

  // Status
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
  final String productIMG; // primary display image
  final List<String> photoPaths; // gallery
  final List<String> insideViews; // optional inside view gallery

  // Ratings & Reviews
  final double starRating;
  final double reviews;

  // Uploader Info
  final String uploaderName;
  final String uploaderEmail;
  final String uploaderIMG;
  final int uploaderPhoneNumber;

  // Optional extra metadata
  final String? destinationTitle; // was in MoreProductViewModel

  // New fields: package and dateCreated
  final String? package; // e.g., 'basic', 'premium', etc.
  final DateTime dateCreated; // when the property was listed

  PropertyModel({
    required this.id,
    required this.propertyType,
    required this.location,
    required this.description,
    required this.price,
    required this.discount,
    required this.thumbnail,
    this.commission,
    this.videoPath,
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
    required this.uploaderPhoneNumber,
    this.destinationTitle,
    this.package, // optional package
    required this.dateCreated, // required dateCreated
  });

  /// CopyWith for updates (like EditPostModel had)
  PropertyModel copyWith({
    int? id,
    String? propertyType,
    String? location,
    String? description,
    double? price,
    double? discount,
    double? commission,
    String? currency,
    String? thumbnail,
    String? videoPath,
    int? bedrooms,
    int? baths,
    double? sqft,
    int? units,
    bool? isActive,
    String? pendingReason,
    bool? isRent,
    bool? isSale,
    bool? hasParking,
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
    String? destinationTitle,
    String? package, // added package
    DateTime? dateCreated, // added dateCreated
  }) {
    return PropertyModel(
      id: id ?? this.id,
      propertyType: propertyType ?? this.propertyType,
      location: location ?? this.location,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      commission: commission ?? this.commission,
      currency: currency ?? this.currency,
      bedrooms: bedrooms ?? this.bedrooms,
      baths: baths ?? this.baths,
      sqft: sqft ?? this.sqft,
      units: units ?? this.units,
      isActive: isActive ?? this.isActive,
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
      insideViews: insideViews ?? this.insideViews,
      starRating: starRating ?? this.starRating,
      reviews: reviews ?? this.reviews,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderEmail: uploaderEmail ?? this.uploaderEmail,
      uploaderIMG: uploaderIMG ?? this.uploaderIMG,
      uploaderPhoneNumber: uploaderPhoneNumber ?? this.uploaderPhoneNumber,
      destinationTitle: destinationTitle ?? this.destinationTitle,
      package: package ?? this.package, // copy package
      dateCreated: dateCreated ?? this.dateCreated, // copy dateCreated
    );
  }
}
