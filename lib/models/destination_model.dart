import 'package:brickapp/models/product_model.dart';

class MoreProductViewModel {
  final ProductModel product;
  final String img;
  final String destinationTitle;

  MoreProductViewModel({
    required this.product,
    required this.img,
    required this.destinationTitle,
  });

  // You can create getters for easier access to frequently used fields
  double get price => product.price;
  int get id => product.id;
  String get description => product.description;
  String get location => product.location;
  int get contact => product.uploaderPhoneNumber;
  String get houseType => product.houseType;
  int get bedRoomNum => product.bedRoomNum;
  double get starRating => product.starRating;
  double get reviews => product.reviews;
  double get sqft => product.sqft;
  int get unitsNum => product.unitsNum;
  bool get isActive => product.isActive;
}
