import '../models/transaction.dart';
import '../models/notification_manager.dart';
import '../data/dummy_data.dart';

class BudgetService {
  static void handleTransaction(Transaction tx) {
    if (tx.isIncome) return;

    for (final budget in currentUser.budgets) {
      if (budget.categoryId == tx.category.categoryId) {
        budget.spentAmount += tx.amount;

        if (budget.isExceeded()) {
          NotificationManager(
            notificationId: DateTime.now().toString(),
            userId: currentUser.userId,
            message:
                'Budget exceeded for ${tx.category.name}',
            sentAt: DateTime.now(),
            budgetId: budget.budgetId,
          ).sendBudgetAlert();
        }
      }
    }
  }
}
