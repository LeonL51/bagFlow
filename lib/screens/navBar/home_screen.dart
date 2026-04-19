import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:bag_flow/screens/navBar/addExpense_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum TimeFilter { week, month, year }
enum InsightDropdownOption { overview, pieChartInsights }

class _Chart {
  final String label;
  final double value;

  _Chart({
    required this.label,
    required this.value,
  });
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Default values to display
  int _currentIndex = 0;
  TimeFilter _selectedTime = TimeFilter.month;
  InsightDropdownOption _selectedInsight = InsightDropdownOption.overview;

  // Set recent hard coded transactions from recent
  final List<Map<String, dynamic>> _expenses = [
    {
      'category': 'Food',
      'company': 'Starbucks',
      'price': 8.75,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'category': 'Transportation',
      'company': 'Uber',
      'price': 123.00,
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'category': 'Shopping',
      'company': 'Target',
      'price': 64.25,
      'date': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'category': 'Bills',
      'company': 'Verizon',
      'price': 89.99,
      'date': DateTime.now().subtract(const Duration(days: 40)),
    },
  ];

  // Acquire new expenses from the Add Expense screen
  Future<void> _openAddExpenseScreen() async {
    final newExpense = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  AddExpenseScreen(),
      )
    );

    if (newExpense != null) {
      setState(() {
        _expenses.add(newExpense);
      });
    }
  }

  // Return all expenses in a certain time frame
  List<Map<String, dynamic>> _expensesTime() {
    // Acquire current date
    final now = DateTime.now();

    // Return all expenses based on selected time frame
    return _expenses.where((expense) {
      final expenseDate = expense['date'] as DateTime;

      switch (_selectedTime) {
        case TimeFilter.week:
          final weekAgo =
              DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

          // Removes the hours, minutes, seconds of expense date
          final normalizedExpense =
              DateTime(expenseDate.year, expenseDate.month, expenseDate.day);

          // Return expenses within the last 7 days(including today)
          return !normalizedExpense.isBefore(weekAgo) &&
              !normalizedExpense.isAfter(DateTime(now.year, now.month, now.day));

        // Return expenses within the current month
        case TimeFilter.month:
          return expenseDate.year == now.year && expenseDate.month == now.month;

        // Return expenses within the last 7 year(including this year)
        case TimeFilter.year:
          final sevenYearsAgo = now.year - 6;
          return expenseDate.year >= sevenYearsAgo && expenseDate.year <= now.year;
      }
    }).toList();
  }

  // Sums all the expenses from a chosen time frame
  double _totalSpent() {
    // Retrieve all the expenses for a chosen time frame
    final filtered = _expensesTime();

    return filtered.fold<double>(
      0.0,
      (sum, expense) => sum + (expense['price'] as num).toDouble(),
    );
  }

  // Formats currency
  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$').format(amount);
  }

  // Helps modify the time displayed for total spent
  String _selectedTimeLabel() {
    switch (_selectedTime) {
      case TimeFilter.week:
        return 'week';
      case TimeFilter.month:
        return 'month';
      case TimeFilter.year:
        return 'year';
    }
  }

  // Acquire the expenses from each time frame
  List<_Chart> _chartData() {
    final now = DateTime.now();

    switch (_selectedTime) {
      case TimeFilter.week:
        final start =
            DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        final List<_Chart> dataPoints = [];

        // Add expenses for the past 7 days
        for (int i = 0; i < 7; i++) {
          final day = start.add(Duration(days: i));
          double total = 0;

          for (final expense in _expenses) {
            final expenseDate = expense['date'] as DateTime;

            if (expenseDate.year == day.year &&
                expenseDate.month == day.month &&
                expenseDate.day == day.day) {
              total += (expense['price'] as num).toDouble();
            }
          }

          dataPoints.add(
            _Chart(
              label: DateFormat('M/d').format(day),
              value: total,
            ),
          );
        }

        return dataPoints;

      // Add expenses for each month from January to December
      case TimeFilter.month:
        final List<_Chart> dataPoints = [];

        for (int month = 1; month <= 12; month++) {
          double total = 0;

          for (final expense in _expenses) {
            final expenseDate = expense['date'] as DateTime;

            if (expenseDate.year == now.year && expenseDate.month == month) {
              total += (expense['price'] as num).toDouble();
            }
          }

          dataPoints.add(
            _Chart(
              label: DateFormat('MMM').format(DateTime(now.year, month, 1)),
              value: total,
            ),
          );
        }

        return dataPoints;

      // Add expenses for the past 7 years
      case TimeFilter.year:
        final List<_Chart> dataPoints = [];
        final startYear = now.year - 6;

        for (int i = 0; i < 7; i++) {
          final year = startYear + i;
          double total = 0;

          for (final expense in _expenses) {
            final expenseDate = expense['date'] as DateTime;

            if (expenseDate.year == year) {
              total += (expense['price'] as num).toDouble();
            }
          }

          dataPoints.add(
            _Chart(
              label: year.toString(),
              value: total,
            ),
          );
        }

        return dataPoints;
    }
  }

  // Add the chart title
  FlTitlesData _chartTitles(List<_Chart> chartPoints) {
    return FlTitlesData(
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();

            if (index < 0 || index >= chartPoints.length) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                chartPoints[index].label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Add the chart widget
  Widget _buildExpenseChart() {
    final chartPoints = _chartData();

    final maxVal = chartPoints.isEmpty
        ? 10.0
        : chartPoints.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final maxY = (maxVal * 1.25).clamp(10.0, double.infinity);

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: _selectedTime == TimeFilter.week
          ? LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white12,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: _chartTitles(chartPoints),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.cyanAccent,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.cyanAccent.withOpacity(0.15),
                    ),
                    spots: List.generate(
                      chartPoints.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        chartPoints[index].value,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white12,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: _chartTitles(chartPoints),
                barGroups: List.generate(
                  chartPoints.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: chartPoints[index].value,
                        width: _selectedTime == TimeFilter.month ? 12 : 18,
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.lightBlueAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return DefaultTabController(
      length: 3,
      initialIndex: TimeFilter.month.index,
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'Home',
          onMenuTap: () {},
        ),
        body: userProfile.when(
          data: (data) {
            // Type cast data
            final profile = data as Map<String, dynamic>;

            // Get the first name from the full name
            final firstName =
                (profile['fullName'] ?? 'User').toString().split(' ').first;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    _buildTotalSpentSection(),
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            );
          },

          // Display spinner as data is being fetched
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => Center(
            child: Text("Error: $e"),
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
      ),
    );
  }

  Widget _buildRecentTransactions() {
    // Retrieve all the expenses from a certain time
    final filtered = _expensesTime();

    if (filtered.isEmpty) {
      return const Text(
        'No expenses for this time period',
        style: TextStyle(color: Colors.white70),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.map((expense) {
          final company = expense['company'];
          final category = expense['category'];
          final price = (expense['price'] as num).toDouble();
          final date = expense['date'] as DateTime;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              // Displays elements on opposite ends
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$category • ${date.month}/${date.day}/${date.year}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(price),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Total spent summary
  Widget _buildTotalSpentSection() {
    final total = _totalSpent();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text(
            'Total spent this ${_selectedTimeLabel()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(total),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildExpenseChart(),
        ],
      ),
    );
  }

  // Constructs the entirety of time frame selection
  Widget _timeSelectionRow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildTab("Week", TimeFilter.week),
          _divider(),
          _buildTab("Month", TimeFilter.month),
          _divider(),
          _buildTab("Year", TimeFilter.year),
        ],
      ),
    );
  }

  // Time frame
  Widget _buildTab(String label, TimeFilter value) {
    final isSelected = _selectedTime == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTime = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const SizedBox(
      height: 30,
      child: VerticalDivider(
        color: Colors.white24,
        thickness: 1,
      ),
    );
  }
}