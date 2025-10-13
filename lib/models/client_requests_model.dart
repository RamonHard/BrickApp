class ClientHistoryModel {
  final String image;
  final String clientName;
  final String itemName;
  final int itemID;
  final String time;
  final double amount;
  final String transactionType;
  final String duration;
  final String paymentMethod;
  final DateTime transactionDate;
  final DateTime dueDate;
  final double depositAmount;
  final double taxAmount;
  final String transactionId;
  ClientHistoryModel({
    required this.image,
    required this.clientName,
    required this.itemName,
    required this.itemID,
    required this.time,
    required this.amount,
    required this.transactionType,
    required this.duration,
    required this.paymentMethod,
    required this.transactionDate,
    required this.dueDate,
    required this.depositAmount,
    required this.taxAmount,
    required this.transactionId,
  });
}
