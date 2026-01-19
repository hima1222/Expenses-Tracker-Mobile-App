import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  // Get user's monthly budget
  Future<double> getMonthlyBudget() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_userId)
          .get();
      return (doc.data() as Map<String, dynamic>)['monthlyBudget'] ?? 2000.0;
    } catch (e) {
      return 2000.0; // Default budget
    }
  }

  // Update monthly budget
  Future<void> updateMonthlyBudget(double budget) async {
    try {
      await _firestore.collection('users').doc(_userId).update({
        'monthlyBudget': budget,
      });
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  // Get spent amount for current month
  Future<double> getMonthlySpent(DateTime date) async {
    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .where('type', isEqualTo: 'expense')
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Timestamp timestamp = data['date'] as Timestamp;
      DateTime transactionDate = timestamp.toDate();
      if (transactionDate.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          ) &&
          transactionDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        total += data['amount'] as double;
      }
    }
    return total;
  }

  // Get budget status
  Future<Map<String, dynamic>> getBudgetStatus(DateTime date) async {
    double budget = await getMonthlyBudget();
    double spent = await getMonthlySpent(date);
    double remaining = budget - spent;
    double percentage = (spent / budget) * 100;

    String status;
    if (percentage >= 100) {
      status = 'Budget Exceeded';
    } else if (percentage >= 80) {
      status = 'Nearing Limit';
    } else {
      status = 'On Track';
    }

    return {
      'budget': budget,
      'spent': spent,
      'remaining': remaining,
      'percentage': percentage,
      'status': status,
    };
  }

  // Stream of budget changes
  Stream<DocumentSnapshot> getBudgetStream() {
    return _firestore.collection('users').doc(_userId).snapshots();
  }
}
