class BudgetModel {
  final int? id;
  final String category;
  final double limitAmount;
  final String month;

  BudgetModel({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
  });
}
