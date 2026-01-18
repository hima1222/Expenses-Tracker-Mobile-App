import 'package:flutter/material.dart';

import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Function(String) onDelete;
  final Function(Transaction) onEdit;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              transaction.isIncome ? Colors.green : Colors.red,
          child: Icon(
            transaction.isIncome
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: Colors.white,
          ),
        ),
        title: Text(transaction.title),
        subtitle: Text(
          '${transaction.category.name} • ${transaction.date.toLocal().toString().split(' ')[0]}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(transaction),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  onDelete(transaction.transactionId),
            ),
          ],
        ),
      ),
    );
  }
}
