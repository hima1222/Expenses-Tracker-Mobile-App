import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();

  bool _isEditingIncome = false;
  late TextEditingController _incomeController;
  double _monthlyIncome = 0.0;
  double _monthlyExpenses = 0.0;
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController(text: '0.00');
    _loadInitialData();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadInitialData() async {
    try {
      DateTime now = DateTime.now();
      double income = await _transactionService.getMonthlyIncome(now);
      double expenses = await _transactionService.getMonthlyExpenses(now);
      Map<String, dynamic> budget = await _budgetService.getBudgetStatus(now);

      setState(() {
        _monthlyIncome = income;
        _monthlyExpenses = expenses;
        _budgetStatus = budget;
        _incomeController.text = income.toStringAsFixed(2);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading initial data: $e');
      setState(() {
        _incomeController.text = '0.00';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMonthlyTotals() async {
    try {
      DateTime now = DateTime.now();
      double income = await _transactionService.getMonthlyIncome(now);
      double expenses = await _transactionService.getMonthlyExpenses(now);

      setState(() {
        _monthlyIncome = income;
        _monthlyExpenses = expenses;
        if (!_isEditingIncome) {
          _incomeController.text = income.toStringAsFixed(2);
        }
      });
    } catch (e) {
      print('Error updating monthly totals: $e');
    }
  }

  Future<void> _saveIncome() async {
    try {
      double newIncome = double.tryParse(_incomeController.text) ?? 0.0;
      DateTime now = DateTime.now();

      // Check if there's already an income transaction for this month
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      QuerySnapshot existingIncome = await FirebaseFirestore.instance
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .collection('transactions')
          .where('type', isEqualTo: 'income')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      if (existingIncome.docs.isNotEmpty) {
        // Update existing income transaction
        String docId = existingIncome.docs.first.id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_authService.currentUser!.uid)
            .collection('transactions')
            .doc(docId)
            .update({
              'amount': newIncome,
              'date': Timestamp.fromDate(now),
              'notes': 'Monthly income update',
            });
      } else {
        // Add new income transaction
        await _transactionService.addTransaction(
          type: 'income',
          category: 'Salary',
          amount: newIncome,
          date: now,
          notes: 'Monthly income update',
        );
      }

      // Update local state and refresh data
      await _updateMonthlyTotals();

      setState(() {
        _isEditingIncome = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating income: $e')));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app resumes (user returns from another screen)
      _updateMonthlyTotals();
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Map<String, dynamic> _getCategoryData(String category) {
    final categoryMap = {
      'Food': {'icon': Icons.restaurant, 'color': Colors.orange},
      'Travel': {'icon': Icons.directions_car, 'color': Colors.blue},
      'Bills': {'icon': Icons.receipt, 'color': Colors.red},
      'Entertainment': {'icon': Icons.movie, 'color': Colors.purple},
      'Salary': {'icon': Icons.attach_money, 'color': Colors.green},
      'Other': {'icon': Icons.category, 'color': Colors.grey},
    };

    return categoryMap[category] ?? categoryMap['Other']!;
  }

  @override
  Widget build(BuildContext context) {
    double remaining = _monthlyIncome - _monthlyExpenses;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'John',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Monthly Balance',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (_isEditingIncome) {
                                            _saveIncome();
                                          } else {
                                            setState(
                                              () => _isEditingIncome = true,
                                            );
                                          }
                                        },
                                        child: Text(
                                          _isEditingIncome
                                              ? 'Save'
                                              : 'Edit Income',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.trending_up,
                                                  size: 16,
                                                  color: Color(0xFF10B981),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Income',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            if (!_isEditingIncome)
                                              Text(
                                                '\$${_monthlyIncome.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF10B981),
                                                ),
                                              )
                                            else
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF10B981,
                                                    ),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                child: TextField(
                                                  controller: _incomeController,
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  decoration:
                                                      const InputDecoration(
                                                        prefix: Text('\$'),
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.trending_down,
                                                size: 16,
                                                color: Color(0xFFEF4444),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Expenses',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${_monthlyExpenses.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Remaining',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${remaining.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: remaining >= 0
                                                  ? const Color(0xFF3B82F6)
                                                  : const Color(0xFFEF4444),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFFF9FAFB),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<QuerySnapshot>(
                            stream: _transactionService.getTransactions(),
                            builder: (context, snapshot) {
                              // Update monthly totals when transactions change
                              if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.active &&
                                  !_isLoading) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _updateMonthlyTotals();
                                });
                              }

                              if (snapshot.hasError) {
                                return const Text('Error loading transactions');
                              }

                              if (snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  _isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final transactions = snapshot.data?.docs ?? [];

                              if (transactions.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(32),
                                  child: const Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No transactions yet',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        'Add your first transaction',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: transactions.take(5).map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final category = data['category'] as String;
                                  final amount = data['amount'] as double;
                                  final type = data['type'] as String;
                                  final date = (data['date'] as Timestamp)
                                      .toDate();

                                  // Get icon and color based on category
                                  final categoryData = _getCategoryData(
                                    category,
                                  );

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: categoryData['color']
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              categoryData['icon'],
                                              color: categoryData['color'],
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                category,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                              Text(
                                                '${date.day}/${date.month}/${date.year}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF9CA3AF),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${type == 'income' ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: type == 'income'
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-expense');
        },
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 0) {
              // Home
            } else if (index == 1) {
              Navigator.pushNamed(context, '/add-expense');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/reports');
            } else if (index == 3) {
              Navigator.pushNamed(context, '/profile');
            }
          },
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle,
                color: _selectedIndex == 1
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.pie_chart,
                color: _selectedIndex == 2
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: _selectedIndex == 3
                    ? const Color(0xFF10B981)
                    : const Color(0xFF9CA3AF),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
