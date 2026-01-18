import 'package:expense_tracker/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  void _deleteTransaction(String id) {
    TransactionService.deleteTransaction(id);
    setState(() {});
  }

  void _editTransaction(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditTransactionScreen(transaction: transaction),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final List<Transaction> transactions = currentUser.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (ctx, index) {
                return TransactionTile(
                  transaction: transactions[index],
                  onDelete: _deleteTransaction,
                  onEdit: _editTransaction,
                );
              },
            ),
    );
  }
}
