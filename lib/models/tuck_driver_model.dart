class TruckDriverModel {
  final String name;
  final String email;
  final String phone;
  final String profileImg;
  final String location;
  final String truckImg;
  final int startingPrice;
  bool? isFavorite;
  TruckDriverModel(
      {required this.name,
      required this.email,
      required this.phone,
      required this.profileImg,
      required this.location,
      required this.truckImg,
      required this.startingPrice,
      this.isFavorite});
}
