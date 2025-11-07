import 'transaction.dart';

class Report {
  final String reportId;
  final List<Transaction> transactions;
  DateTime timeRangeStart;
  DateTime timeRangeEnd;
  String chartType;

  Report({
    required this.reportId,
    required this.timeRangeStart,
    required this.timeRangeEnd,
    required this.chartType,
    required this.transactions,
  });

  double getTotalExpenses(List<Transaction> transactions) {
    return transactions
        .where((t) => !t.isIncome)
        .map((t) => t.amount)
        .fold(0, (a, b) => a + b);
  }

  double getTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.isIncome)
        .map((t) => t.amount)
        .fold(0, (a, b) => a + b);
  }

  List<Transaction> getRecentTransactions(List<Transaction> transactions, int limit) {
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions.take(limit).toList();
  }

  Map<String, double> getCategoryWiseExpenses(List<Transaction> transactions) {
    Map<String, double> result = {};
    for (var t in transactions.where((t) => !t.isIncome)) {
      result[t.category.name] = (result[t.category.name] ?? 0) + t.amount;
    }
    return result;
  }
}
