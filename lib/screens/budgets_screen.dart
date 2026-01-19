import 'package:flutter/material.dart';
import '../services/budget_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  double monthlyBudget = 2000.00;
  double spentAmount = 705.50;
  bool _isEditing = false;
  TextEditingController _budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    try {
      double budget = await _budgetService.getMonthlyBudget();
      double spent = await _budgetService.getMonthlySpent(DateTime.now());
      setState(() {
        monthlyBudget = budget;
        spentAmount = spent;
        _budgetController.text = budget.toStringAsFixed(2);
      });
    } catch (e) {
      // Handle error
      print('Error loading budget data: $e');
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Color _getBudgetColor() {
    double percentage = (spentAmount / monthlyBudget) * 100;
    if (percentage >= 100) return const Color(0xFFEF4444);
    if (percentage >= 80) return const Color(0xFFFACC15);
    return const Color(0xFF10B981);
  }

  String _getBudgetStatus() {
    double percentage = (spentAmount / monthlyBudget) * 100;
    if (percentage >= 100) return 'Budget Exceeded';
    if (percentage >= 80) return 'Nearing Limit';
    return 'On Track';
  }

  @override
  Widget build(BuildContext context) {
    double remaining = monthlyBudget - spentAmount;
    double percentage = (spentAmount / monthlyBudget) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              backgroundColor: Colors.white,
              elevation: 0.5,
              title: const Text(
                'Budget Settings',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly Budget Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Monthly Budget',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () async {
                                        if (_isEditing) {
                                          // Save the budget
                                          double? newBudget = double.tryParse(
                                            _budgetController.text,
                                          );
                                          if (newBudget != null &&
                                              newBudget > 0) {
                                            setState(() => _isLoading = true);
                                            try {
                                              await _budgetService
                                                  .updateMonthlyBudget(
                                                    newBudget,
                                                  );
                                              setState(() {
                                                monthlyBudget = newBudget;
                                                _isEditing = false;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Budget updated successfully!',
                                                  ),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error updating budget: $e',
                                                  ),
                                                ),
                                              );
                                            } finally {
                                              setState(
                                                () => _isLoading = false,
                                              );
                                            }
                                          }
                                        } else {
                                          setState(() => _isEditing = true);
                                        }
                                      },
                                child: Text(
                                  _isLoading
                                      ? 'Saving...'
                                      : (_isEditing ? 'Save' : 'Edit'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (!_isEditing)
                            Text(
                              '\$${monthlyBudget.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            )
                          else
                            TextField(
                              controller: _budgetController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                hintText: 'Enter budget',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (value) {
                                final newBudget = double.tryParse(value);
                                if (newBudget != null) {
                                  setState(() => monthlyBudget = newBudget);
                                }
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Budget Usage
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Budget Usage',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${spentAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getBudgetColor(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 12,
                              backgroundColor: const Color(0xFFE5E7EB),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getBudgetColor(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Remaining',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                              Text(
                                '\$${remaining.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: remaining >= 0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Alert Status
                    Container(
                      decoration: BoxDecoration(
                        color: _getBudgetColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getBudgetColor()),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _getBudgetColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getBudgetStatus(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _getBudgetColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Budget Tips
                    const Text(
                      'Budget Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...[
                      'Track your expenses daily to avoid overspending',
                      'Set realistic budgets based on your income',
                      'Review your spending patterns weekly',
                      'Save at least 20% of your monthly income',
                    ].asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
