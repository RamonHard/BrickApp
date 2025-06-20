// models/truck_driver.dart
class TruckDriver {
  final String id;
  final String name;
  final String truckType;
  final String truckNumber;
  final double rating;
  final double distance; // in km
  final double price;
  final int eta; // in minutes
  final String imageUrl;

  TruckDriver({
    required this.id,
    required this.name,
    required this.truckType,
    required this.truckNumber,
    required this.rating,
    required this.distance,
    required this.price,
    required this.eta,
    required this.imageUrl,
  });
}
