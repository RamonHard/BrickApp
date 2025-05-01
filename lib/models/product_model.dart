class ProductModel {
  final double price;
  final int uploaderPhoneNumber;
  final String location;
  final String description;
  final String productIMG;
  final int id;
  final int unitsNum;
  final String uploaderIMG;
  final String uploaderName;
  final String uploaderEmail;
  final String houseType;
  final int bedRoomNum;
  final double starRating;
  final double reviews;
  final double sqft;
  final bool isActive;

  ProductModel({
    required this.price,
    required this.uploaderPhoneNumber,
    required this.location,
    required this.description,
    required this.productIMG,
    required this.uploaderIMG,
    required this.id,
    required this.unitsNum,
    required this.uploaderName,
    required this.uploaderEmail,
    required this.houseType,
    required this.bedRoomNum,
    required this.starRating,
    required this.reviews,
    required this.sqft,
    required this.isActive,
  });
}
