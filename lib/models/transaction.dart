import 'category.dart';

class Transaction {
  final String transactionId;
  String title;
  double amount;
  DateTime date;
  Category category;
  String notes;
  String receiptImageUrl;
  bool isIncome;

  Transaction({
    required this.transactionId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes = '',
    this.receiptImageUrl = '',
    this.isIncome = false,
  });
}
