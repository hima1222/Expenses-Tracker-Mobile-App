import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/budget.dart';
import '../models/category.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  Category _selectedCategory = categories.first;
  final _limitController = TextEditingController();

  void _addBudget() {
    final limit = double.tryParse(_limitController.text);
    if (limit == null || limit <= 0) return;

    final budget = Budget(
      budgetId: DateTime.now().toString(),
      userId: currentUser.userId,
      categoryId: _selectedCategory.categoryId,
      period: DateTime.now(),
      limitAmount: limit,
    );

    currentUser.budgets.add(budget);

    _limitController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 8),
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Budget Limit'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addBudget,
              child: const Text('Add Budget'),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: currentUser.budgets.length,
                itemBuilder: (ctx, i) {
                  final b = currentUser.budgets[i];
                  return ListTile(
                    title: Text('Category ID: ${b.categoryId}'),
                    subtitle: Text(
                        '₹ ${b.spentAmount} / ₹ ${b.limitAmount}'),
                    trailing: b.isExceeded()
                        ? const Icon(Icons.warning, color: Colors.red)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
