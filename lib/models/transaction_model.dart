class TransactionModel {
  final int? id;
  final double amount;
  final String type;
  final String category;
  final String note;
  final String date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
  });
}
