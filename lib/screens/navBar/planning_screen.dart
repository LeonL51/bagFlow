import 'package:bag_flow/models/expense.dart';
import 'package:bag_flow/providers/expense_provider.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  int _currentIndex = 3;
  bool _showAllCategories = false;

  // Temporary in-screen value until you save budget settings to Firestore
  double _monthlyBudget = 1000.00;

  // Temporary in-screen category limits until you save category budgets to Firestore
  final Map<String, double> _categoryBudgets = {
    'Food': 350.00,
    'Transportation': 120.00,
    'Education': 200.00,
    'Shopping': 180.00,
    'Subscription': 80.00,
    'Bills': 200.00,
    'Rent': 900.00,
  };

  // User-added savings goals for this session until you build a real Goals Firestore collection
  final List<_SavingsGoal> _savingsGoals = [];

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  List<Expense> _expensesThisMonth(List<Expense> expenses) {
    final now = DateTime.now();

    return expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();
  }

  double _spentThisMonth(List<Expense> expenses) {
    return _expensesThisMonth(expenses).fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  int _daysRemainingInMonth() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;

    return (lastDay - now.day).clamp(1, 31);
  }

  // Returns how much money is left
  double _remaining(List<Expense> expenses) {
    return _monthlyBudget - _spentThisMonth(expenses);
  }

  // Returns how much of the budget is used
  double _budgetProgress(List<Expense> expenses) {
    if (_monthlyBudget == 0) return 0;
    return (_spentThisMonth(expenses) / _monthlyBudget).clamp(0.0, 1.0);
  }

  // Finds safe amount to spend today to prevent exceeding budget long-term
  double _safeToSpendToday(List<Expense> expenses) {
    return _remaining(expenses) / _daysRemainingInMonth();
  }

  // Projects end-of-month spending based on average daily spending so far
  double _projectedEndOfMonthSpend(List<Expense> expenses) {
    final now = DateTime.now();
    final spent = _spentThisMonth(expenses);

    if (now.day <= 0) return spent;

    final averagePerDay = spent / now.day;
    final lastDay = DateTime(now.year, now.month + 1, 0).day;

    return averagePerDay * lastDay;
  }

  // Returns projected remaining money by end of month
  double _projectedRemaining(List<Expense> expenses) {
    return _monthlyBudget - _projectedEndOfMonthSpend(expenses);
  }

  List<_BudgetCategory> _categoryData(List<Expense> expenses) {
    final monthlyExpenses = _expensesThisMonth(expenses);
    final Map<String, double> spentByCategory = {};

    for (final expense in monthlyExpenses) {
      spentByCategory[expense.category] =
          (spentByCategory[expense.category] ?? 0) + expense.amount;
    }

    final categories = _categoryBudgets.entries.map((entry) {
      return _BudgetCategory(
        title: entry.key,
        spent: spentByCategory[entry.key] ?? 0,
        budget: entry.value,
        icon: _iconForCategory(entry.key),
        color: _colorForCategory(entry.key),
      );
    }).toList();

    // Sorts categories by highest spending first
    categories.sort((a, b) => b.spent.compareTo(a.spent));

    return categories;
  }

  // Shows only the top 4 spending categories on the main Planning page
  List<_BudgetCategory> _topCategoryData(List<Expense> expenses) {
    return _categoryData(expenses).take(4).toList();
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transportation':
        return Icons.directions_bus_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Subscription':
        return Icons.subscriptions_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Rent':
        return Icons.home_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFF9F67FF);
      case 'Transportation':
        return const Color(0xFF3C93FF);
      case 'Education':
        return const Color(0xFF1ED39A);
      case 'Shopping':
        return const Color(0xFFFFA12E);
      case 'Subscription':
        return const Color(0xFFB77CFF);
      case 'Bills':
        return const Color(0xFFFF6B6B);
      case 'Rent':
        return const Color(0xFFFACC15);
      default:
        return const Color(0xFF93C5FD);
    }
  }

  Future<void> _showSetBudgetPopup() async {
    final controller = TextEditingController(
      text: _monthlyBudget.toStringAsFixed(2),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Set Monthly Budget',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Budget',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Enter monthly budget',
                    hintStyle: TextStyle(color: Colors.black54),
                    prefixText: '\$',
                    prefixStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());

                if (value == null || value <= 0) return;

                Navigator.pop(context, value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      _monthlyBudget = result;
    });
  }

  Future<void> _showCreateGoalPopup() async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final savedController = TextEditingController();

    final result = await showDialog<_SavingsGoal>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Create Savings Goal',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Goal Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Emergency fund, laptop, trip...',
                    hintStyle: TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Target Amount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Enter target amount',
                    hintStyle: TextStyle(color: Colors.black54),
                    prefixText: '\$',
                    prefixStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Amount Already Saved',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: savedController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Enter amount saved so far',
                    hintStyle: TextStyle(color: Colors.black54),
                    prefixText: '\$',
                    prefixStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text.trim());
                final saved =
                    double.tryParse(savedController.text.trim()) ?? 0.0;

                if (name.isEmpty || target == null || target <= 0) return;
                if (saved < 0) return;

                Navigator.pop(
                  context,
                  _SavingsGoal(
                    name: name,
                    target: target,
                    saved: saved,
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      _savingsGoals.add(result);
    });
  }

  Future<void> _showAddMoneyToGoalPopup(int index) async {
    final controller = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Add to ${_savingsGoals[index].name}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount to Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(color: Colors.black54),
                    prefixText: '\$',
                    prefixStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());

                if (value == null || value <= 0) return;

                Navigator.pop(context, value);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      final current = _savingsGoals[index];

      _savingsGoals[index] = current.copyWith(
        saved: current.saved + result,
      );
    });
  }

  Future<void> _showAdjustLimitsPopup() async {
    final controllers = <String, TextEditingController>{};

    for (final entry in _categoryBudgets.entries) {
      controllers[entry.key] = TextEditingController(
        text: entry.value.toStringAsFixed(2),
      );
    }

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Adjust Category Limits',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _categoryBudgets.keys.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controllers[category],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            hintText: 'Enter category limit',
                            hintStyle: TextStyle(color: Colors.black54),
                            prefixText: '\$',
                            prefixStyle: TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updated = <String, double>{};

                for (final entry in controllers.entries) {
                  final value = double.tryParse(entry.value.text.trim());

                  if (value == null || value < 0) return;

                  updated[entry.key] = value;
                }

                Navigator.pop(context, updated);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      _categoryBudgets
        ..clear()
        ..addAll(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(
        title: _showAllCategories ? 'Category Limits' : 'Planning',
        onMenuTap: () {},
      ),
      body: SafeArea(
        child: expensesAsync.when(
          data: (expenses) {
            if (_showAllCategories) {
              return _buildAllCategoriesPage(expenses);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan ahead. Stay in control.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildOverviewCard(expenses),
                  const SizedBox(height: 18),
                  _buildSectionHeader(
                    'Category Budgets',
                    actionText: 'View All',
                  ),
                  const SizedBox(height: 10),
                  _buildTopCategoryBudgetCard(expenses),
                  const SizedBox(height: 18),
                  _buildSavingsGoalsSection(),
                  const SizedBox(height: 18),
                  _buildForecastCard(expenses),
                  const SizedBox(height: 18),
                  _buildSectionHeader('Quick Actions'),
                  const SizedBox(height: 10),
                  _buildQuickActionsColumn(),
                  const SizedBox(height: 16),
                  _buildPlanningTipCard(expenses),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error loading planning data: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          await handleBottomNavTap(
            context: context,
            index: index,
            currentIndex: _currentIndex,
            setIndex: (i) => setState(() => _currentIndex = i),
          );
        },
      ),
    );
  }

  Widget _buildAllCategoriesPage(List<Expense> expenses) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _showAllCategories = false;
              });
            },
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to Planning'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'All Category Limits',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the card below or use Adjust to change category limits.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          _buildAllCategoryBudgetCard(expenses),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: _showAdjustLimitsPopup,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Adjust Category Limits'),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the first thing that users can easily see for budgeting
  Widget _buildOverviewCard(List<Expense> expenses) {
    final spent = _spentThisMonth(expenses);
    final remaining = _remaining(expenses);
    final progress = _budgetProgress(expenses);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.10),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBubble(
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF9F67FF),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _metricColumn(
                        'MONTHLY BUDGET',
                        _formatCurrency(_monthlyBudget),
                        Colors.white,
                      ),
                    ),
                    Expanded(
                      child: _metricColumn(
                        'SPENT SO FAR',
                        _formatCurrency(spent),
                        const Color(0xFF9F67FF),
                      ),
                    ),
                    Expanded(
                      child: _metricColumn(
                        'REMAINING',
                        _formatCurrency(remaining),
                        remaining >= 0
                            ? const Color(0xFF1ED39A)
                            : const Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(
                progress >= 1
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF9F67FF),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Percentage of budget used
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}% Used',
              style: const TextStyle(
                color: Color(0xFFB77CFF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Motivational Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFFB77CFF),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    remaining >= 0
                        ? 'Safe to spend today: ${_formatCurrency(_safeToSpendToday(expenses))}'
                        : 'You are over budget. Slow down spending where possible.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoryBudgetCard(List<Expense> expenses) {
    return _buildCategoryBudgetCard(_topCategoryData(expenses));
  }

  Widget _buildAllCategoryBudgetCard(List<Expense> expenses) {
    return GestureDetector(
      onTap: _showAdjustLimitsPopup,
      child: _buildCategoryBudgetCard(_categoryData(expenses)),
    );
  }

  // Builds the category budgets section
  Widget _buildCategoryBudgetCard(List<_BudgetCategory> categories) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: categories.map((category) {
          final progress = category.budget == 0
              ? 0.0
              : (category.spent / category.budget).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category icon
                _iconBubble(icon: category.icon, color: category.color),
                const SizedBox(width: 12),

                // Progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Category name
                        category.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Shows money spent and budget limit
                      Text(
                        '${_formatCurrency(category.spent)} / ${_formatCurrency(category.budget)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation(category.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Shows percentage
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: category.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(), // map() returns iterable widget, but Column needs list widget
      ),
    );
  }

  Widget _buildSavingsGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Savings Goals', actionText: 'Add'),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showCreateGoalPopup,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white10),
            ),
            child: _savingsGoals.isEmpty
                ? const Text(
                    'No savings goals yet. Tap here to create one.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  )
                : Column(
                    children: List.generate(_savingsGoals.length, (index) {
                      final goal = _savingsGoals[index];
                      final progress = goal.target == 0
                          ? 0.0
                          : (goal.saved / goal.target).clamp(0.0, 1.0);

                      return InkWell(
                        onTap: () => _showAddMoneyToGoalPopup(index),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              _iconBubble(
                                icon: Icons.track_changes_rounded,
                                color: const Color(0xFF1ED39A),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatCurrency(goal.saved)} / ${_formatCurrency(goal.target)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.08),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                          Color(0xFF1ED39A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Color(0xFF1ED39A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        ),
      ],
    );
  }

  // Builds the forecast section
  Widget _buildForecastCard(List<Expense> expenses) {
    final projectedRemaining = _projectedRemaining(expenses);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Budget Forecast'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBubble(
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF9F67FF),
              ),
              const SizedBox(height: 14),
              const Text(
                "You're projected to have",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatCurrency(projectedRemaining),
                style: TextStyle(
                  color: projectedRemaining >= 0
                      ? const Color(0xFF9F67FF)
                      : const Color(0xFFFF6B6B),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'left by the end of the month',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Added explanation for the chart
              const Text(
                "Spending Trend",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Solid = spent so far • Dotted = projected spending",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                width: double.infinity,
                child: CustomPaint(
                  painter: _ForecastLinePainter(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'SAFE TO SPEND TODAY',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(_safeToSpendToday(expenses)),
                style: const TextStyle(
                  color: Color(0xFF1ED39A),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Gets the different quick actions to help the user plan their budget
  Widget _buildQuickActionsColumn() {
    return Column(
      children: [
        // Allows user to set a budget
        _quickActionTile(
          icon: Icons.calculate_rounded,
          label: 'Set Budget',
          subtitle: 'Update monthly budget',
          color: const Color(0xFF9F67FF),
          onTap: _showSetBudgetPopup,
        ),
        const SizedBox(height: 12),

        // Allow user to define how much to limit their spending on certain categories
        _quickActionTile(
          icon: Icons.tune_rounded,
          label: 'Adjust Category Limits',
          subtitle: 'Change category spending limits',
          color: const Color(0xFFFFA12E),
          onTap: _showAdjustLimitsPopup,
        ),
      ],
    );
  }

  // Gives user a common general tip
  Widget _buildPlanningTipCard(List<Expense> expenses) {
    final safe = _safeToSpendToday(expenses);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFB77CFF),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              safe >= 0
                  ? 'Planning Tip\nTry to stay near ${_formatCurrency(safe)} per day for the rest of the month.\n\nThis helps you avoid going over budget.'
                  : 'Planning Tip\nYou are currently over budget.\n\nFocus on essentials only and reduce spending where possible.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Labels the sections and lets users see all the bills
  Widget _buildSectionHeader(String title, {String? actionText}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: () {
              if (title == 'Category Budgets') {
                setState(() {
                  _showAllCategories = true;
                });
              } else if (title == 'Savings Goals') {
                _showCreateGoalPopup();
              }
            },
            child: Text(
              actionText,
              style: const TextStyle(
                color: Color(0xFFB77CFF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // Builds the budget, amount spent so far, remaining section
  Widget _metricColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // Creates the container for the quick action tiles
  Widget _iconBubble({required IconData icon, required Color color}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  // Creates the layout for each tile
  Widget _quickActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            _iconBubble(icon: icon, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}

// Creates a class type for budget in each category to get the necessary info
class _BudgetCategory {
  final String title;
  final double spent;
  final double budget;
  final IconData icon;
  final Color color;

  const _BudgetCategory({
    required this.title,
    required this.spent,
    required this.budget,
    required this.icon,
    required this.color,
  });
}

// Creates a class type for savings goals to get the necessary info
class _SavingsGoal {
  final String name;
  final double target;
  final double saved;

  const _SavingsGoal({
    required this.name,
    required this.target,
    required this.saved,
  });

  _SavingsGoal copyWith({
    String? name,
    double? target,
    double? saved,
  }) {
    return _SavingsGoal(
      name: name ?? this.name,
      target: target ?? this.target,
      saved: saved ?? this.saved,
    );
  }
}

class _ForecastLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the bottom baseline (like an axis line)
    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;

    // Paint for the solid line (actual/past spending)
    final linePaint = Paint()
      ..color = const Color(0xFF9F67FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Paint for the dashed line (projected/future spending)
    final dashedPaint = Paint()
      ..color = const Color(0xFF9F67FF).withOpacity(0.75)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Paint for the gradient fill under the solid line
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x339F67FF), // light purple (top)
          Color(0x009F67FF), // transparent (bottom)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draws the horizontal baseline at the bottom of the chart
    canvas.drawLine(
      Offset(0, size.height - 18),
      Offset(size.width, size.height - 18),
      gridPaint,
    );

    // Solid path = past spending (smooth curved line)
    final solidPath = Path()
      // starting point (left side)
      ..moveTo(8, size.height * 0.30)
      // curve to middle point (this defines the shape)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.42,
        size.width * 0.44,
        size.height * 0.56,
      );

    // Dashed path = projected future spending
    final dashedPath = Path()
      // starts where solid line ends
      ..moveTo(size.width * 0.44, size.height * 0.56)
      // curves toward the right (future projection)
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.70,
        size.width - 8,
        size.height - 24,
      );

    // Area under the solid line (used for gradient fill)
    final areaPath = Path.from(solidPath)
      // go down to bottom right
      ..lineTo(size.width * 0.44, size.height - 18)
      // go across bottom to left
      ..lineTo(8, size.height - 18)
      // close the shape
      ..close();

    // Draw the filled area (background gradient)
    canvas.drawPath(areaPath, fillPaint);

    // Draw the solid line (past data)
    canvas.drawPath(solidPath, linePaint);

    // Settings for dashed line pattern
    const dashWidth = 7.0; // length of each dash
    const dashSpace = 5.0; // space between dashes

    // Loop through the dashed path and draw small segments to simulate dashes
    for (final metric in dashedPath.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          dashedPaint,
        );

        distance += dashWidth + dashSpace;
      }
    }

    // Point where solid line meets dashed line (current moment / "today")
    final point = Offset(size.width * 0.44, size.height * 0.56);

    // Paint for the main dot
    final pointPaint = Paint()..color = const Color(0xFF9F67FF);

    // Draw small solid circle (core point)
    canvas.drawCircle(point, 6, pointPaint);

    // Draw larger faded circle (glow effect)
    canvas.drawCircle(
      point,
      11,
      Paint()..color = const Color(0x449F67FF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}