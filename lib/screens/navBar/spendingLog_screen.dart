import 'package:bag_flow/screens/navBar/addExpense_screen.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:flutter/material.dart';

class SpendingLogScreen extends StatefulWidget {
  const SpendingLogScreen({super.key});

  @override
  State<SpendingLogScreen> createState() => _SpendingLogScreenState();
}

class _SpendingLogScreenState extends State<SpendingLogScreen> {
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

  // Hard-coded values of a list of expenses 
  final List<Map<String, dynamic>> _expenses = [
    {
      'category': 'Food',
      'company': 'Starbucks',
      'price': 6.45,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'category': 'Transportation',
      'company': 'Uber',
      'price': 23.20,
      'date': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'category': 'Shopping',
      'company': 'Amazon',
      'price': 28.99,
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    },
    {
      'category': 'Subscription',
      'company': 'Spotify',
      'price': 10.99,
      'date': DateTime.now().subtract(const Duration(days: 2, hours: 1)),
    },
    {
      'category': 'Bills',
      'company': 'Verizon',
      'price': 89.99,
      'date': DateTime.now().subtract(const Duration(days: 4, hours: 6)),
    },
    {
      'category': 'Education',
      'company': 'Campus Bookstore',
      'price': 42.50,
      'date': DateTime.now().subtract(const Duration(days: 6)),
    },
    {
      'category': 'Food',
      'company': 'Chipotle',
      'price': 14.75,
      'date': DateTime.now().subtract(const Duration(days: 8)),
    },
    {
      'category': 'Rent',
      'company': 'Landlord',
      'price': 800.00,
      'date': DateTime.now().subtract(const Duration(days: 12)),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Opens the Add Expense screen and handles the returned result
  Future<void> _openAddExpenseScreen() async {
    // Navigate to AddExpenseScreen and wait for data to be returned
    final newExpense = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );

    // If user canceled (no data returned), exit early
    if (newExpense == null) return;

    // Make sure widget is still in the tree before updating state
    if (!mounted) return;

    setState(() {
      // If multiple expenses were returned (List)
      if (newExpense is List) {
        for (final item in newExpense) {
          // Ensure each item is a valid expense map
          if (item is Map<String, dynamic>) {
            // Insert each expense at the top of the list
            _expenses.insert(0, Map<String, dynamic>.from(item));
          }
        }
      }
      // If a single expense was returned (Map)
      else if (newExpense is Map<String, dynamic>) {
        // Insert it at the top of the list
        _expenses.insert(0, Map<String, dynamic>.from(newExpense));
      }
    });
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Return expenses if it matches category, time range, and query 
  List<Map<String, dynamic>> _filteredExpenses() {
    final now = DateTime.now();
    final query = _searchController.text.trim().toLowerCase();

    return _expenses.where((expense) {
      // Extract values safely from the map
      final category = (expense['category'] ?? '').toString();
      final company = (expense['company'] ?? '').toString();
      final price = (expense['price'] as num).toDouble();
      final date = expense['date'] as DateTime;

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
      ..sort((a, b) {
        final aDate = a['date'] as DateTime;
        final bDate = b['date'] as DateTime;
        return bDate.compareTo(aDate);
      });
  }

  // Sums up the filtered expenses based on selected cateogry, time range, and search query  
  double _filteredTotal() {
    return _filteredExpenses().fold<double>(
      0,
      (sum, expense) => sum + (expense['price'] as num).toDouble(),
    );
  }

  // Groups filtered expenses into time-based sections (e.g., Today, Yesterday)
  Map<String, List<Map<String, dynamic>>> _groupedExpenses() {
    final filtered = _filteredExpenses();
    // Group label - "Today", List of expenses in the group 
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final expense in filtered) {
      final date = expense['date'] as DateTime;
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
    if (date.year == now.year && date.month == now.month) return 'Earlier This Month';
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
        return const Color(0xFFB77CFF);
      case 'Shopping':
        return const Color(0xFFFFA12E);
      case 'Bills':
        return const Color(0xFFE6537D);
      case 'Education':
        return const Color(0xFF1ED39A);
      case 'Rent':
        return const Color(0xFF7C83FD);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  // Displays the filter when clicked on 
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Filter transaction heading 
              const Text(
                'Filter Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              // Date range label 
              const Text(
                'Date Range',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              // Display date range options to filter by 
              Wrap(
                // Horizontal spacing between chips
                spacing: 10,
                // Vertical spacing when chips wrap to next line
                runSpacing: 5,

                // Generate a ChoiceChip for each range option
                children: _ranges.map((range) {
                  // Check if this chip is currently selected
                  final isSelected = _selectedRange == range;
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
            ],
          ),
        );
      },
    );
  }

  // UI code 
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExpenses();
    final grouped = _groupedExpenses();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(
        title: 'Spending Log',
        onMenuTap: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                    _buildSummaryCard(filtered.length),
                    const SizedBox(height: 18),
                    // If no expenses match filters, show empty state UI
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      // Loop through grouped expenses (e.g., Today, Yesterday, etc.)
                      ...grouped.entries.map((entry) {
                        // Calculate total for this section (sum of all prices in this group)
                        final sectionTotal = entry.value.fold<double>(
                          0,
                          (sum, expense) => sum + (expense['price'] as num).toDouble(),
                        );

                        // Returns the time and expenses list 
                        return Padding(
                          // Space between each section
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time  range label and total price for that range
                              Row(
                                children: [
                                  // Section header (e.g., "Today", "Earlier This Week")
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
                                _formatDate(entry.value.first['date'] as DateTime),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Loops through all expenses in a group and turns each one into a UI widget
                              // ENTRY: gives both key and value from a map -> label + expense 
                              ...entry.value.map((expense) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _transactionTile(expense),
                                  )),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "You've reached the end",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            openAddExpense: _openAddExpenseScreen,
          );
        },
      ),
    );
  }

  // Constructs the row for searching transactions and filtering time frames  
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            // Search field 
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.grey),
              decoration: const InputDecoration(
                hintText: 'Search vendor, category, or amount...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.black),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Filter by date button 
        InkWell(
          onTap: _showFilterSheet,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFFB77CFF),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  // Display a row of categories to choose from 
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        // Inserts horizontal gap between each item 
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            // Creates the containers for categories 
            child: Container(
              // Formats containers for categories based on selection state 
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white10,
                ),
              ),
              // Creates content within the row 
              child: Row(
                children: [
                  if (category != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        _iconForCategory(category),
                        size: 18,
                        color: isSelected ? Colors.white : _colorForCategory(category),
                      ),
                    ),
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int transactionCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFFB77CFF),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRANSACTIONS',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$transactionCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 70,
            color: Colors.white10,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL SPENT',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(_filteredTotal()),
                  style: const TextStyle(
                    color: Color(0xFFB77CFF),
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Creates a tile for each transaction 
  Widget _transactionTile(Map<String, dynamic> expense) {
    final company = expense['company'].toString();
    final category = expense['category'].toString();
    final price = (expense['price'] as num).toDouble();
    final date = expense['date'] as DateTime;
    final color = _colorForCategory(category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Icons container
          Container(
            width: 60,
            height: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_iconForCategory(category), color: color, size: 30),
          ),
          const SizedBox(width: 14),
          // Company and category label 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Time and Price of transaction 
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(date),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatCurrency(price),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          // ??????
          PopupMenuButton<String>(
            color: const Color(0xFF181818),
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value tapped for $company')),
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Edit', child: Text('Edit', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'Delete', child: Text('Delete', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'Duplicate', child: Text('Duplicate', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  // Display UI for no transactions found 
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: Color(0xFFB77CFF), size: 48),
          SizedBox(height: 14),
          Text(
            'No transactions found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try changing your filters or search term.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
