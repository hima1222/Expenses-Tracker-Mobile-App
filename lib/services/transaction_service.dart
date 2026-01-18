import '../models/transaction.dart';
import '../data/dummy_data.dart';
import 'budget_service.dart';

class TransactionService {
  static void addTransaction(Transaction tx) {
    currentUser.addTransaction(tx);
    BudgetService.handleTransaction(tx);
  }

  static void deleteTransaction(String id) {
    currentUser.deleteTransaction(id);
  }

  static void updateTransaction(Transaction tx) {
    currentUser.updateTransaction(tx);
  }
}
