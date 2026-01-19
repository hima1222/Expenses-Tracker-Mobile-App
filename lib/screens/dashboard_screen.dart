import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isEditingIncome = false;
  late TextEditingController _incomeController;
  
  final List<Map<String, dynamic>> _expenses = [
    {
      'category': 'Food',
      'amount': 45.50,
      'date': '2024-01-15',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'type': 'expense',
    },
    {
      'category': 'Travel',
      'amount': 120.00,
      'date': '2024-01-14',
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'type': 'expense',
    },
    {
      'category': 'Salary',
      'amount': 3000.00,
      'date': '2024-01-10',
      'icon': Icons.attach_money,
      'color': Colors.green,
      'type': 'income',
    },
  ];

  @override
  void initState() {
    super.initState();
    double income = _expenses
        .where((e) => e['type'] == 'income')
        .fold(0, (sum, e) => sum + e['amount']);
    _incomeController = TextEditingController(text: income.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double income = _expenses
        .where((e) => e['type'] == 'income')
        .fold(0, (sum, e) => sum + e['amount']);
    
    double totalExpenses = _expenses
        .where((e) => e['type'] == 'expense')
        .fold(0, (sum, e) => sum + e['amount']);
    
    double remaining = income - totalExpenses;

    return Scaffold(
      body: CustomScrollView(
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
                    colors: [
                      Color(0xFF10B981),
                      Color(0xFF3B82F6),
                    ],
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    setState(() => _isEditingIncome = !_isEditingIncome);
                                  },
                                  child: Text(
                                    _isEditingIncome ? 'Save' : 'Edit Income',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.trending_up, size: 16, color: Color(0xFF10B981)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Income',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if (!_isEditingIncome)
                                        Text(
                                          '\$${_incomeController.text}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        )
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFF10B981)),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: TextField(
                                            controller: _incomeController,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              prefix: Text('\$'),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.trending_down, size: 16, color: Color(0xFFEF4444)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Expenses',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${totalExpenses.toStringAsFixed(2)}',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Remaining',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${(double.tryParse(_incomeController.text) ?? 0 - totalExpenses).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: (double.tryParse(_incomeController.text) ?? 0) >= totalExpenses
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
                    ..._expenses.map((expense) {
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
                                color: (expense['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  expense['icon'],
                                  color: expense['color'],
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense['category'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    expense['date'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${expense['type'] == 'income' ? '+' : '-'}\$${expense['amount'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: expense['type'] == 'income'
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
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
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, color: _selectedIndex == 1 ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart, color: _selectedIndex == 2 ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: _selectedIndex == 3 ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
