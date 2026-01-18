import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../models/category.dart';
import '../data/dummy_data.dart';
import '../services/transaction_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late Category _selectedCategory;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.transaction.title);
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _selectedCategory = widget.transaction.category;
    _isIncome = widget.transaction.isIncome;
  }

  void _updateTransaction() {
    final amount = double.tryParse(_amountController.text);

    if (_titleController.text.trim().isEmpty ||
        amount == null ||
        amount <= 0) {
      return;
    }

    final updatedTransaction = Transaction(
      transactionId: widget.transaction.transactionId,
      title: _titleController.text.trim(),
      amount: amount,
      date: widget.transaction.date,
      category: _selectedCategory,
      isIncome: _isIncome,
    );

    TransactionService.updateTransaction(updatedTransaction);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Category>(
              initialValue: _selectedCategory,
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            SwitchListTile(
              title: const Text('Is Income'),
              value: _isIncome,
              onChanged: (v) => setState(() => _isIncome = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTransaction,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
