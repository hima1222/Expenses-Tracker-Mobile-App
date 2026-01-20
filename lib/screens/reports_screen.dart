import 'package:flutter/material.dart';
import '../services/reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportsService _reportsService = ReportsService();
  bool _isWeekly = true;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startDate = _isWeekly
        ? now.subtract(Duration(days: now.weekday - 1))
        : DateTime(now.year, now.month, 1);
    DateTime endDate = _isWeekly
        ? startDate.add(const Duration(days: 6))
        : DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 0,
                backgroundColor: Colors.white,
                elevation: 0.5,
                title: const Text(
                  'Reports',
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
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    key: ValueKey(
                      '${startDate.toIso8601String()}-${endDate.toIso8601String()}',
                    ),
                    future: _reportsService.getCategoryBreakdown(
                      startDate,
                      endDate,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading reports'),
                        );
                      }

                      final categoryExpenses = snapshot.data ?? [];
                      final totalExpenses = categoryExpenses.fold(
                        0.0,
                        (sum, item) => sum + item['amount'],
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // View Toggle
                          Container(
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
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isWeekly = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isWeekly
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _isWeekly
                                              ? const Color(0xFF10B981)
                                              : Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Weekly',
                                          style: TextStyle(
                                            color: _isWeekly
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF9CA3AF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isWeekly = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: !_isWeekly
                                            ? const Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: !_isWeekly
                                              ? const Color(0xFF10B981)
                                              : Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Monthly',
                                          style: TextStyle(
                                            color: !_isWeekly
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF9CA3AF),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Total Expenses Card
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${totalExpenses.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${_isWeekly ? 'This week' : 'This month'}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Category Breakdown Title
                          const Text(
                            'Breakdown by Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Category List
                          if (categoryExpenses.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.pie_chart,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No expenses to show',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...categoryExpenses.map((item) {
                              final percentage = item['percentage'] as int;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['category'],
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        Text(
                                          '\$${((item['amount'] as num).toDouble()).toStringAsFixed(2)} ($percentage%)',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        minHeight: 8,
                                        backgroundColor: const Color(
                                          0xFFE5E7EB,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              _getCategoryColor(
                                                item['category'],
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
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Travel':
        return Colors.blue;
      case 'Bills':
        return Colors.red;
      case 'Entertainment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
