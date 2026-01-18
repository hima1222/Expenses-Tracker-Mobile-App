import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/report.dart';
import '../widgets/category_pie_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = Report(
      reportId: 'rep1',
      timeRangeStart:
          DateTime.now().subtract(const Duration(days: 30)),
      timeRangeEnd: DateTime.now(),
      chartType: 'pie',
      transactions: currentUser.transactions,
    );

    final categoryData =
        report.getCategoryWiseExpenses(currentUser.transactions);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Total Income: ₹ ${report.getTotalIncome(currentUser.transactions)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Total Expense: ₹ ${report.getTotalExpenses(currentUser.transactions)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Category-wise Expenses',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            CategoryPieChart(data: categoryData),
          ],
        ),
      ),
    );
  }
}
