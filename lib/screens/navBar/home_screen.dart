import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:bag_flow/screens/credentials/login_screen.dart';
import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/screens/navBar/addExpense_screen.dart';
import 'package:bag_flow/screens/navBar/spendingLog_screen.dart';
import 'package:bag_flow/screens/navBar/planning_screen.dart';
import 'package:bag_flow/screens/navBar/more_screen.dart';

enum TimeFilter { week, month, year }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  TimeFilter _selectedTime = TimeFilter.month;

  // TODO: Remove hardcoded var 
  final List<Map<String, dynamic>> _expenses = [
    {
      'category': 'Food',
      'vendor': 'Starbucks',
      'price': 8.75,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'category': 'Transportation',
      'vendor': 'Uber',
      'price': 24.10,
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
  ];

  // Link functionalities between home and add expense screens
  Future<void> _openAddExpenseScreen() async { 
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    // If there is a String/dynamic pair, add new expense to top of the list 
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _expenses.insert(0, result);
      });
    }
  }

  // Navigate to certain screens based on the icons 
  void _onTabTapped(int index) async {
    if (index == _currentIndex) return; 

    setState(() {
      _currentIndex = index; 
    });

    if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SpendingLogScreen(),
        ),
      );
    } else if (index == 2) {
      await _openAddExpenseScreen();
    } else if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlanningScreen(),
        ),
      );
    } else if (index == 4) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MoreScreen(),
        ),
      );
    }

    if (!mounted) return; 

    setState(() {
      _currentIndex = 0; // Default back to home when returning 
    });
  }

  List<Map<String, dynamic>> get _filteredExpenses {
    final now = DateTime.now();

    return _expenses.where((expense) {
      final date = expense['date'] as DateTime;

      switch (_selectedTime) {
        case TimeFilter.week:
          return now.difference(date).inDays < 7;
        case TimeFilter.month:
          return date.year == now.year && date.month == now.month;
        case TimeFilter.year:
          return date.year == now.year;
      }
    }).toList();
  }

  double get _totalSpentValue {
    return _filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + ((expense['price'] as num).toDouble()),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Rent':
        return Icons.home;
      case 'Transportation':
        return Icons.directions_car;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return DefaultTabController(
      length: 3,
      initialIndex: TimeFilter.month.index,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: GradientAppBar(
          title: 'Home',
          onMenuTap: () {},
        ),
        body: userProfile.when(
          data: (data) {
            if (data == null) {
              return const Center(
                child: Text(
                  "No user data",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final profile = data as Map<String, dynamic>;
            final fullName = profile['fullName']?.toString() ?? 'User';
            final firstName = fullName.split(' ').first;

            return Stack(
              children: [
                // Base green background
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF064E3B),
                          Color(0xFF065F46),
                          Color(0xFF022C22),
                        ],
                      ),
                    ),
                  ),
                ),

                // Soft radial highlight behind content
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.2,
                        colors: [
                          Color(0x332563EB),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // This is the layer that smooths the white app bar into the body
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 170,
                  child: IgnorePointer(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.45, 1.0],
                          colors: [
                            Color(0xB3FFFFFF),
                            Color(0x40FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, $firstName",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),
                        _timeSelectionRow(),

                        const SizedBox(height: 24),
                        _totalSpent(),

                        const SizedBox(height: 24),
                        _sectionCard("Chart goes here"),

                        const SizedBox(height: 24),
                        _sectionCard("Pie chart goes here"),

                        const SizedBox(height: 24),
                        _recentTransactions(),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _openAddExpenseScreen,
                            child: const Text("Add Expense"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (e, _) => Center(
            child: Text(
              "Error: $e",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  // Clarify the time frame on total spent 
  Widget _totalSpent() {
    return _summaryCard(
      title: _selectedTime == TimeFilter.week
          ? "Total spent this week"
          : _selectedTime == TimeFilter.month
              ? "Total spent this month"
              : "Total spent this year",
      value: _formatCurrency(_totalSpentValue),
    );
  }

  Widget _timeSelectionRow() {
    return TabBar(
      onTap: (index) {
        setState(() {
          _selectedTime = TimeFilter.values[index];
        });
      },
      indicatorColor: const Color(0xFF2563EB),
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      tabs: const [
        Tab(text: "Week"),
        Tab(text: "Month"),
        Tab(text: "Year"),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String text) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text(text)),
    );
  }

  Widget _recentTransactions() {
    final recentExpenses = [..._expenses]
      ..sort((a, b) {
        final aDate = a['date'] as DateTime;
        final bDate = b['date'] as DateTime;
        return bDate.compareTo(aDate);
      });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Transactions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Divider(
            color: Colors.white24,
            thickness: 1,
          ),
          const SizedBox(height: 12),
          if (recentExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No transactions yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ...recentExpenses.take(5).map((expense) {
              final vendor = expense['vendor'] as String? ?? 'Unknown';
              final category = expense['category'] as String? ?? 'Other';
              final price = (expense['price'] as num).toDouble();
              final date = expense['date'] as DateTime;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Icon(_categoryIcon(category)),
                ),
                title: Text(
                  vendor,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _formatDate(date),
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  '-${_formatCurrency(price)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}