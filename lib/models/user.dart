import 'transaction.dart';
import 'budget.dart';


class User {
  final String userId;
  String name;
  String email;
  String password;
  String reEnterPassword;
  List<Transaction> transactions = [];
  List<Budget> budgets = [];

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
    required this.reEnterPassword,
  });

  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
  }

  void deleteTransaction(String transactionId) {
    transactions.removeWhere((t) => t.transactionId == transactionId);
  }

  void updateTransaction(Transaction updated) {
    int index = transactions.indexWhere(
      (t) => t.transactionId == updated.transactionId,
    );
    if (index != -1) transactions[index] = updated;
  }

  List<Transaction> getTransactionsByDate(DateTime date) {
    return transactions.where((t) => t.date == date).toList();
  }
}
