class NotificationManager {
  final String notificationId;
  final String userId;
  String message;
  DateTime sentAt;
  String budgetId;

  NotificationManager({
    required this.notificationId,
    required this.userId,
    required this.message,
    required this.sentAt,
    required this.budgetId,
  });

  void sendBudgetAlert() {
    print("Budget Alert for $userId: $message");
  }

  void sendReminder() {
    print("Reminder for $userId: $message");
  }
}
