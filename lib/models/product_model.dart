class ProductModel {
  final double price;
  final int uploaderPhoneNumber;
  final String location;
  final String description;
  final String productIMG;
  final int id;
  final String uploaderIMG;
  final String uploaderName;
  final String uploaderEmail;

  ProductModel({
    required this.price,
    required this.uploaderPhoneNumber,
    required this.location,
    required this.description,
    required this.productIMG,
    required this.uploaderIMG,
    required this.id,
    required this.uploaderName,
    required this.uploaderEmail,
  });
}
