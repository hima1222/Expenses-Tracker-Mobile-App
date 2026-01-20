import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  // Get expense breakdown by category for a specific period
  Future<List<Map<String, dynamic>>> getCategoryBreakdown(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .where('type', isEqualTo: 'expense')
          .get();

      Map<String, double> categoryTotals = {};
      double totalExpenses = 0;

      for (var doc in snapshot.docs) {
        DateTime transactionDate = (doc.data() as Map<String, dynamic>)['date']
            .toDate();
        if (transactionDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            transactionDate.isBefore(endDate.add(const Duration(days: 1)))) {
          String category = doc['category'];
          double amount = (doc['amount'] as num).toDouble();
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
          totalExpenses += amount;
        }
      }

      List<Map<String, dynamic>> breakdown = [];
      categoryTotals.forEach((category, amount) {
        double percentage = totalExpenses > 0
            ? (amount / totalExpenses) * 100
            : 0;
        breakdown.add({
          'category': category,
          'amount': amount,
          'percentage': percentage.round(),
        });
      });

      // Sort by amount descending
      breakdown.sort((a, b) => b['amount'].compareTo(a['amount']));

      return breakdown;
    } catch (e) {
      print('Error getting category breakdown: $e');
      return [];
    }
  }

  // Get weekly expense data for charts
  Future<List<Map<String, dynamic>>> getWeeklyExpenses(DateTime month) async {
    try {
      List<Map<String, dynamic>> weeklyData = [];

      for (int week = 1; week <= 4; week++) {
        DateTime weekStart = _getWeekStart(month, week);
        DateTime weekEnd = _getWeekEnd(month, week);

        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('transactions')
            .where('type', isEqualTo: 'expense')
            .get();

        double total = 0.0;
        for (var doc in snapshot.docs) {
          DateTime transactionDate = (doc['date'] as Timestamp).toDate();
          if (transactionDate.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              transactionDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
            total += (doc['amount'] as num).toDouble();
          }
        }

        weeklyData.add({
          'week': 'Week $week',
          'amount': total,
          'startDate': weekStart,
          'endDate': weekEnd,
        });
      }

      return weeklyData;
    } catch (e) {
      print('Error getting weekly expenses: $e');
      return [];
    }
  }

  // Get monthly expense trend for the past 6 months
  Future<List<Map<String, dynamic>>> getMonthlyTrend() async {
    try {
      List<Map<String, dynamic>> trend = [];
      DateTime now = DateTime.now();

      for (int i = 5; i >= 0; i--) {
        DateTime month = DateTime(now.year, now.month - i, 1);
        DateTime startOfMonth = DateTime(month.year, month.month, 1);
        DateTime endOfMonth = DateTime(
          month.year,
          month.month + 1,
          0,
          23,
          59,
          59,
        );

        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(_userId)
            .collection('transactions')
            .where('type', isEqualTo: 'expense')
            .get();

        double total = 0.0;
        for (var doc in snapshot.docs) {
          DateTime transactionDate = (doc['date'] as Timestamp).toDate();
          if (transactionDate.isAfter(
                startOfMonth.subtract(const Duration(days: 1)),
              ) &&
              transactionDate.isBefore(
                endOfMonth.add(const Duration(days: 1)),
              )) {
            total += (doc['amount'] as num).toDouble();
          }
        }

        trend.add({
          'month': _getMonthName(month.month),
          'year': month.year,
          'amount': total,
        });
      }

      return trend;
    } catch (e) {
      print('Error getting monthly trend: $e');
      return [];
    }
  }

  // Get income vs expense comparison
  Future<Map<String, double>> getIncomeVsExpense(DateTime month) async {
    try {
      DateTime startOfMonth = DateTime(month.year, month.month, 1);
      DateTime endOfMonth = DateTime(
        month.year,
        month.month + 1,
        0,
        23,
        59,
        59,
      );

      // Get income
      QuerySnapshot incomeSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .where('type', isEqualTo: 'income')
          .get();

      double totalIncome = 0.0;
      for (var doc in incomeSnapshot.docs) {
        DateTime transactionDate = (doc['date'] as Timestamp).toDate();
        if (transactionDate.isAfter(
              startOfMonth.subtract(const Duration(days: 1)),
            ) &&
            transactionDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          totalIncome += (doc['amount'] as num).toDouble();
        }
      }

      // Get expenses
      QuerySnapshot expenseSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .where('type', isEqualTo: 'expense')
          .get();

      double totalExpenses = 0.0;
      for (var doc in expenseSnapshot.docs) {
        DateTime transactionDate = (doc['date'] as Timestamp).toDate();
        if (transactionDate.isAfter(
              startOfMonth.subtract(const Duration(days: 1)),
            ) &&
            transactionDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          totalExpenses += (doc['amount'] as num).toDouble();
        }
      }

      return {
        'income': totalIncome,
        'expenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      print('Error getting income vs expense: $e');
      return {'income': 0.0, 'expenses': 0.0, 'balance': 0.0};
    }
  }

  // Helper methods
  DateTime _getWeekStart(DateTime month, int week) {
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int daysToAdd = (week - 1) * 7;
    DateTime weekStart = firstDayOfMonth.add(Duration(days: daysToAdd));

    // If weekStart is in next month, adjust to last day of current month
    if (weekStart.month != month.month) {
      return DateTime(month.year, month.month + 1, 0);
    }

    return weekStart;
  }

  DateTime _getWeekEnd(DateTime month, int week) {
    DateTime weekStart = _getWeekStart(month, week);
    DateTime weekEnd = weekStart.add(const Duration(days: 6));

    // If weekEnd is in next month, adjust to last day of current month
    if (weekEnd.month != month.month) {
      weekEnd = DateTime(month.year, month.month + 1, 0);
    }

    return DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
