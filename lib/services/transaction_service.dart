import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  // Add a new transaction
  Future<void> addTransaction({
    required String type, // 'income' or 'expense'
    required String category,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .add({
            'type': type,
            'category': category,
            'amount': amount,
            'date': Timestamp.fromDate(date),
            'notes': notes ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Get all transactions for current user
  Stream<QuerySnapshot> getTransactions() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get transactions for a specific month
  Stream<QuerySnapshot> getTransactionsForMonth(DateTime date) {
    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Update a transaction
  Future<void> updateTransaction(
    String transactionId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Get total income for current month
  Future<double> getMonthlyIncome(DateTime date) async {
    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .where('type', isEqualTo: 'income')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data() as Map<String, dynamic>)['amount'] as double;
    }
    return total;
  }

  // Get total expenses for current month
  Future<double> getMonthlyExpenses(DateTime date) async {
    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .where('type', isEqualTo: 'expense')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data() as Map<String, dynamic>)['amount'] as double;
    }
    return total;
  }

  // Get expenses by category for reports
  Future<Map<String, double>> getExpensesByCategory(DateTime date) async {
    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .where('type', isEqualTo: 'expense')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .get();

    Map<String, double> categoryTotals = {};

    for (var doc in snapshot.docs) {
      String category = doc['category'];
      double amount = doc['amount'];
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }
}
