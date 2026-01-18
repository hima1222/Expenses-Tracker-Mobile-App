import 'package:expense_tracker/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/report.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final report = Report(
      reportId: 'r1',
      timeRangeStart: DateTime.now().subtract(const Duration(days: 30)),
      timeRangeEnd: DateTime.now(),
      chartType: 'pie',
      transactions: currentUser.transactions,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryCard(
              'Income',
              report.getTotalIncome(currentUser.transactions),
              Colors.green,
            ),
            _summaryCard(
              'Expenses',
              report.getTotalExpenses(currentUser.transactions),
              Colors.red,
            ),
            _summaryCard(
              'Balance',
              report.getTotalIncome(currentUser.transactions) -
                  report.getTotalExpenses(currentUser.transactions),
              Colors.blue,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontSize: 18),
        ),
      ),
    );
  }
}
