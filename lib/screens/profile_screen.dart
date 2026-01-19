import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/budget_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final BudgetService _budgetService = BudgetService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  bool _isDarkMode = false;
  String? _selectedPersonalInfo;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getUserProfile(
        _authService.currentUser!.uid,
      );
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Profile',
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
                    // Profile Card
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
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _userProfile?['name'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userProfile?['email'] ??
                                _authService.currentUser?.email ??
                                '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Account Section
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                      child: Column(
                        children: [
                          _buildPersonalInfoDropdown(),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: Icons.email_outlined,
                            title: 'Change Email',
                            onTap: () => _showChangeEmailDialog(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Budget Settings
                    const Text(
                      'Budget & Notifications',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Monthly Budget',
                            onTap: () => _showMonthlyBudgetDialog(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Settings
                    const Text(
                      'App',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 12),

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
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.settings_outlined,
                            title: 'Preferences',
                            onTap: () => _showPreferencesDialog(),
                          ),
                          _buildDivider(),
                          _buildSettingItem(
                            icon: Icons.info_outline,
                            title: 'About',
                            onTap: () => _showAboutDialog(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _logout,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Info Footer
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Smart Expense Tracker',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFD1D5DB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(height: 1, color: const Color(0xFFE5E7EB)),
    );
  }

  Widget _buildPersonalInfoDropdown() {
    List<String> personalInfoOptions = [
      'Full Name: ${_userProfile?['name'] ?? 'Not set'}',
      'Email: ${_userProfile?['email'] ?? 'Not set'}',
      'Salary: ${_userProfile?['salary'] ?? 'Not set'}',
    ];

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Personal Info',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1F2937)),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFFD1D5DB),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedPersonalInfo,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Select to view details'),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                items: personalInfoOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(option),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPersonalInfo = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController(
      text: _userProfile?['email'] ?? _authService.currentUser?.email ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Email'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Enter new email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update email logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email updated successfully')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showPreferencesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Preferences'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dark Mode'),
                      Switch(
                        value: _isDarkMode,
                        onChanged: (bool value) {
                          setDialogState(() {
                            _isDarkMode = value;
                          });
                          setState(() {
                            _isDarkMode = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Light Mode'),
                      Switch(
                        value: !_isDarkMode,
                        onChanged: (bool value) {
                          setDialogState(() {
                            _isDarkMode = !value;
                          });
                          setState(() {
                            _isDarkMode = !value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About This App'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Expense Tracker is a simple and reliable app designed to help you take control of your personal finances. It allows you to easily record your daily income and expenses, so you always know where your money is going.\n\n'
                  'With clear categories and organized records, the app helps you understand your spending habits over time. You can track different types of expenses, monitor your budget, and make informed decisions to improve how you manage your money.\n\n'
                  'Whether you are saving for something important, trying to reduce unnecessary spending, or just want a better overview of your finances, Expense Tracker gives you a clear and convenient way to stay organized and financially aware.\n\n'
                  'This app is built to be easy to use, so you can focus on managing your money without any confusion or extra effort.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMonthlyBudgetDialog() async {
    setState(() => _isLoading = true);
    try {
      DateTime now = DateTime.now();
      Map<String, dynamic> budgetStatus = await _budgetService.getBudgetStatus(
        now,
      );

      double budget = budgetStatus['budget'];
      double spent = budgetStatus['spent'];
      double remaining = budgetStatus['remaining'];
      double percentage = budgetStatus['percentage'];
      String status = budgetStatus['status'];

      Color budgetColor = _getBudgetColor(percentage);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Monthly Budget Analysis'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Overview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Monthly Budget:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              '\$${budget.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              '\$${spent.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              '\$${remaining.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: remaining >= 0
                                    ? Color(0xFF10B981)
                                    : Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress Bar
                  Text(
                    'Spending Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${percentage.toStringAsFixed(1)}% Used',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: budgetColor,
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: budgetColor,
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
                            backgroundColor: Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              budgetColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Future Spending Suggestions
                  Text(
                    'Future Spending Suggestions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getSpendingSuggestions(percentage, remaining, budget).map(
                    (suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/budgets');
                },
                child: const Text('Manage Budget'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading budget data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getBudgetColor(double percentage) {
    if (percentage >= 100) return const Color(0xFFEF4444);
    if (percentage >= 80) return const Color(0xFFFACC15);
    return const Color(0xFF10B981);
  }

  List<String> _getSpendingSuggestions(
    double percentage,
    double remaining,
    double budget,
  ) {
    List<String> suggestions = [];

    if (percentage >= 100) {
      suggestions.add(
        'You\'ve exceeded your budget. Consider reviewing your expenses and adjusting your spending habits.',
      );
      suggestions.add(
        'Look for areas where you can cut back on non-essential expenses.',
      );
      suggestions.add(
        'Consider increasing your monthly budget or finding additional income sources.',
      );
    } else if (percentage >= 80) {
      suggestions.add(
        'You\'re approaching your budget limit. Monitor your remaining spending carefully.',
      );
      suggestions.add(
        'Prioritize essential expenses and delay non-urgent purchases.',
      );
      suggestions.add(
        'With \$${remaining.toStringAsFixed(2)} remaining, plan your spending for the rest of the month.',
      );
    } else if (percentage >= 50) {
      suggestions.add(
        'You\'re halfway through your budget. Keep tracking your expenses regularly.',
      );
      suggestions.add(
        'Consider saving some of your remaining \$${remaining.toStringAsFixed(2)} for unexpected expenses.',
      );
      suggestions.add(
        'Review your spending categories to identify areas for potential savings.',
      );
    } else {
      suggestions.add(
        'Great job staying within your budget! You have \$${remaining.toStringAsFixed(2)} remaining.',
      );
      suggestions.add(
        'Consider allocating some savings from this month\'s surplus.',
      );
      suggestions.add(
        'Continue monitoring your spending patterns to maintain financial health.',
      );
    }

    // General suggestions
    suggestions.add(
      'Track daily expenses to avoid overspending at month\'s end.',
    );
    suggestions.add(
      'Set spending limits for different categories to better control your budget.',
    );

    return suggestions;
  }
}
