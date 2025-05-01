class TruckDriverModel {
  final String name;
  final String email;
  final String phone;
  final String profileImg;
  final String location;
  final String truckImg;
  final int startingPrice;
  final int starRating;
  final int trips;
  bool? isFavorite;
  TruckDriverModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImg,
    required this.location,
    required this.truckImg,
    required this.startingPrice,
    required this.starRating,
    required this.trips,
    this.isFavorite,
  });
}
