class Budget {
  final String budgetId;
  final String userId;
  final String categoryId;
  DateTime period;
  double limitAmount;
  double spentAmount;

  Budget({
    required this.budgetId,
    required this.userId,
    required this.categoryId,
    required this.period,
    required this.limitAmount,
    this.spentAmount = 0,
  });

  bool isExceeded() {
    return spentAmount > limitAmount;
  }
}
