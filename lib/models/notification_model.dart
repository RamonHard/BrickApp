class RequestModel {
  final String image;
  final String clientName;
  final String itemName;
  final int itemID;
  final String time;
  final double amount;
  final int phone;
  RequestModel(
      {required this.image,
      required this.clientName,
      required this.itemName,
      required this.itemID,
      required this.time,
      required this.amount,
      required this.phone});
}
