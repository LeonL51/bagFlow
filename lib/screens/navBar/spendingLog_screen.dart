import 'package:bag_flow/models/expense.dart';
import 'package:bag_flow/providers/expense_provider.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpendingLogScreen extends ConsumerStatefulWidget {
  const SpendingLogScreen({super.key});

  @override
  ConsumerState<SpendingLogScreen> createState() => _SpendingLogScreenState();
}

class _SpendingLogScreenState extends ConsumerState<SpendingLogScreen> {
  int _currentIndex = 1;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedRange = 'This Month';

  // A list of categories
  final List<String> _categories = const [
    'All',
    'Food',
    'Transportation',
    'Subscription',
    'Shopping',
    'Bills',
    'Education',
    'Rent',
  ];

  // Filter expenses by date range
  final List<String> _ranges = const [
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Return expenses if it matches category, time range, and query
  List<Expense> _filteredExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final query = _searchController.text.trim().toLowerCase();

    return expenses.where((expense) {
      // Extract values safely from the object
      final category = expense.category;
      final company = expense.title;
      final price = expense.amount;
      final date = expense.date;

      // Check if category matches selected filter
      final matchesCategory =
          _selectedCategory == 'All' || category == _selectedCategory;

      // Check if date falls within selected range
      bool matchesRange = true;

      switch (_selectedRange) {
        case 'Today':
          matchesRange =
              date.year == now.year && date.month == now.month && date.day == now.day;
          break;

        case 'This Week':
          final weekStart =
              DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
          final normalizedDate = DateTime(date.year, date.month, date.day);

          matchesRange = !normalizedDate.isBefore(weekStart) &&
              !normalizedDate.isAfter(DateTime(now.year, now.month, now.day));
          break;

        case 'This Month':
          matchesRange = date.year == now.year && date.month == now.month;
          break;

        case 'This Year':
          matchesRange = date.year == now.year;
          break;
      }

      // Check if search query matches company, category, or price
      final matchesQuery = query.isEmpty ||
          company.toLowerCase().contains(query) ||
          category.toLowerCase().contains(query) ||
          price.toStringAsFixed(2).contains(query);

      return matchesCategory && matchesRange && matchesQuery;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Sums up the filtered expenses based on selected cateogry, time range, and search query
  double _filteredTotal(List<Expense> expenses) {
    return _filteredExpenses(expenses).fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  // Groups filtered expenses into time-based sections (e.g., Today, Yesterday)
  Map<String, List<Expense>> _groupedExpenses(List<Expense> expenses) {
    final filtered = _filteredExpenses(expenses);

    // Group label - "Today", List of expenses in the group
    final Map<String, List<Expense>> grouped = {};

    for (final expense in filtered) {
      final date = expense.date;
      final label = _groupLabelForDate(date);

      // If time label is not added, add the label and the expense
      grouped.putIfAbsent(label, () => []).add(expense);
    }

    return grouped;
  }

  // Labels for time section
  String _groupLabelForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    // Converts differences to number of days
    final difference = today.difference(target).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference <= 6) return 'Earlier This Week';
    if (date.year == now.year && date.month == now.month) {
      return 'Earlier This Month';
    }

    return '${_monthName(date.month)} ${date.year}';
  }

  // Converts numbers from DateTime to actual months
  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  // Formats date
  String _formatDate(DateTime date) {
    return '${_monthShort(date.month)} ${date.day}, ${date.year}';
  }

  // Shortens date
  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // Formats the time in hours, minutes, and PM/AM
  String _formatTime(DateTime date) {
    // Finds the hour(1-12)
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // Tailors icon based on category
  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transportation':
        return Icons.directions_car_filled_rounded;
      case 'Subscription':
        return Icons.subscriptions_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Rent':
        return Icons.home_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  // Tailors color based on category
  Color _colorForCategory(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFF9F67FF);
      case 'Transportation':
        return const Color(0xFF3C93FF);
      case 'Subscription':
        return const Color(0xFF1ED39A);
      case 'Shopping':
        return const Color(0xFFFFA12E);
      case 'Bills':
        return const Color(0xFFFF6B6B);
      case 'Education':
        return const Color(0xFF22C55E);
      case 'Rent':
        return const Color(0xFFFACC15);
      default:
        return const Color(0xFF93C5FD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(
        title: 'Spending Log',
        onMenuTap: () {},
      ),
      body: SafeArea(
        child: expensesAsync.when(
          data: (expenses) {
            final filtered = _filteredExpenses(expenses);
            final grouped = _groupedExpenses(expenses);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Track. Filter. Take control.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildSearchRow(),
                  const SizedBox(height: 14),
                  _buildCategoryChips(),
                  const SizedBox(height: 18),
                  _buildSummaryCard(expenses, filtered.length),
                  const SizedBox(height: 18),

                  // If no expenses match filters, show empty state UI
                  if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    // Loop through grouped expenses (e.g. Today, Yesterday, etc.)
                    ...grouped.entries.map((entry) {
                      // Calculate total for this section (sum of all prices in this group)
                      final sectionTotal = entry.value.fold<double>(
                        0,
                        (sum, expense) => sum + expense.amount,
                      );

                      // Returns the time and expenses list
                      return Padding(
                        // Space between each section
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time range label and total price for that range
                            Row(
                              children: [
                                // Section header (e.g. "Today", "Earlier This Week")
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                // Total amount spent in this section
                                Text(
                                  _formatCurrency(sectionTotal),
                                  style: const TextStyle(
                                    color: Color(0xFFB77CFF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Insert exact date
                            Text(
                              _formatDate(entry.value.first.date),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...entry.value.map(_expenseTile),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error loading expenses: $e',
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

  Widget _buildSearchRow() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Search expenses',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) => setState(() => _selectedCategory = category),
            selectedColor: const Color(0xFF8B5CF6),
            backgroundColor: Colors.white.withOpacity(0.06),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Expense> expenses, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryColumn(
              'FILTERED TOTAL',
              _formatCurrency(_filteredTotal(expenses)),
            ),
          ),
          Expanded(
            child: _summaryColumn(
              'ITEMS',
              count.toString(),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: _showRangePicker,
              child: _summaryColumn(
                'RANGE',
                _selectedRange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryColumn(String label, String value) {
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  void _showRangePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _ranges.map((range) {
              final isSelected = range == _selectedRange;

              return ChoiceChip(
                label: Text(range),
                selected: isSelected,

                // When user taps a chip, update selected range and rebuild UI
                onSelected: (_) {
                  setState(() => _selectedRange = range);

                  // Close the bottom sheet after selection
                  Navigator.pop(context);
                },
                selectedColor: const Color(0xFF8B5CF6),

                // Background color when not selected
                backgroundColor: Colors.white.withOpacity(0.06),

                // Text styling based on selection state
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w600,
                ),

                // Border styling
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _expenseTile(Expense expense) {
    final color = _colorForCategory(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          _iconBubble(
            icon: _iconForCategory(expense.category),
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${expense.category} • ${_formatTime(expense.date)}',
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(expense.amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBubble({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: Colors.white54,
            size: 46,
          ),
          SizedBox(height: 10),
          Text(
            'No expenses found',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try changing your search, category, or range.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}