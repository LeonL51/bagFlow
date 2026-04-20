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
enum InsightTab { pieChart, breakdown }

class _Chart {
  final String label;
  final double value;

  _Chart({
    required this.label,
    required this.value,
  });
}

class _CategoryInsight {
  final String category;
  final double amount;
  final double percentage;

  _CategoryInsight({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Default values to display
  int _currentIndex = 0;
  TimeFilter _selectedTime = TimeFilter.week;
  InsightTab _selectedInsightTab = InsightTab.pieChart;
  bool _isInsightsExpanded = false;

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
        builder: (context) => AddExpenseScreen(),
      ),
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

  // Return the most recent 7 transactions regardless of selected time frame
  List<Map<String, dynamic>> _recentTransactions() {
    final recentExpenses = List<Map<String, dynamic>>.from(_expenses);

    recentExpenses.sort((a, b) {
      final aDate = a['date'] as DateTime;
      final bDate = b['date'] as DateTime;
      return bDate.compareTo(aDate);
    });

    return recentExpenses.take(7).toList();
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

  String _selectedTimeLabelCapitalized() {
    switch (_selectedTime) {
      case TimeFilter.week:
        return 'Week';
      case TimeFilter.month:
        return 'Month';
      case TimeFilter.year:
        return 'Year';
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

  List<Map<String, dynamic>> _previousPeriodExpenses() {
    final now = DateTime.now();

    return _expenses.where((expense) {
      final expenseDate = expense['date'] as DateTime;

      switch (_selectedTime) {
        case TimeFilter.week:
          final currentStart =
              DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
          final previousStart = currentStart.subtract(const Duration(days: 7));
          final previousEnd = currentStart.subtract(const Duration(days: 1));

          final normalizedExpense =
              DateTime(expenseDate.year, expenseDate.month, expenseDate.day);

          return !normalizedExpense.isBefore(previousStart) &&
              !normalizedExpense.isAfter(previousEnd);

        case TimeFilter.month:
          final previousMonth = DateTime(now.year, now.month - 1, 1);
          return expenseDate.year == previousMonth.year &&
              expenseDate.month == previousMonth.month;

        case TimeFilter.year:
          final startYear = now.year - 13;
          final endYear = now.year - 7;
          return expenseDate.year >= startYear && expenseDate.year <= endYear;
      }
    }).toList();
  }

  double _previousPeriodTotalSpent() {
    final previous = _previousPeriodExpenses();

    return previous.fold<double>(
      0.0,
      (sum, expense) => sum + (expense['price'] as num).toDouble(),
    );
  }

  List<_CategoryInsight> _categoryInsights() {
    final filtered = _expensesTime();
    final total = _totalSpent();

    if (filtered.isEmpty || total == 0) {
      return [];
    }

    final Map<String, double> categoryTotals = {};

    for (final expense in filtered) {
      final category = (expense['category'] ?? 'Other').toString();
      final amount = (expense['price'] as num).toDouble();
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    final insights = categoryTotals.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return _CategoryInsight(
        category: entry.key,
        amount: entry.value,
        percentage: percentage,
      );
    }).toList();

    insights.sort((a, b) => b.amount.compareTo(a.amount));
    return insights;
  }

  Map<String, dynamic>? _mostSpentCategory() {
    final categoryInsights = _categoryInsights();

    if (categoryInsights.isEmpty) {
      return null;
    }

    final top = categoryInsights.first;
    return {
      'category': top.category,
      'amount': top.amount,
      'percentage': top.percentage,
    };
  }

  Map<String, dynamic>? _highestTransaction() {
    final filtered = _expensesTime();

    if (filtered.isEmpty) {
      return null;
    }

    Map<String, dynamic> highest = filtered.first;

    for (final expense in filtered) {
      final currentPrice = (expense['price'] as num).toDouble();
      final highestPrice = (highest['price'] as num).toDouble();

      if (currentPrice > highestPrice) {
        highest = expense;
      }
    }

    return highest;
  }

  String _comparisonToPreviousPeriod() {
    final current = _totalSpent();
    final previous = _previousPeriodTotalSpent();

    if (previous == 0 && current == 0) {
      return 'No spending in either this or the previous ${_selectedTimeLabel()}.';
    }

    if (previous == 0 && current > 0) {
      return 'Spending is up compared to the previous ${_selectedTimeLabel()} because there was no spending in that period.';
    }

    final difference = current - previous;
    final percent = ((difference.abs()) / previous) * 100;

    if (difference > 0) {
      return 'Spending is up ${percent.toStringAsFixed(1)}% compared to the previous ${_selectedTimeLabel()}.';
    } else if (difference < 0) {
      return 'Spending is down ${percent.toStringAsFixed(1)}% compared to the previous ${_selectedTimeLabel()}.';
    } else {
      return 'Spending is unchanged compared to the previous ${_selectedTimeLabel()}.';
    }
  }

  List<PieChartSectionData> _pieChartSections() {
    final categoryInsights = _categoryInsights();

    if (categoryInsights.isEmpty) {
      return [];
    }

    final List<Color> sectionColors = [
      Colors.cyanAccent,
      Colors.lightBlueAccent,
      Colors.deepPurpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.greenAccent,
      Colors.amberAccent,
    ];

    return List.generate(categoryInsights.length, (index) {
      final item = categoryInsights[index];
      final isHighest = index == 0;

      return PieChartSectionData(
        value: item.amount,
        title: '${item.percentage.toStringAsFixed(0)}%',
        radius: isHighest ? 62 : 54,
        color: sectionColors[index % sectionColors.length],
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    });
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
                    isCurved: false,
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

  Widget _buildInsightsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _isInsightsExpanded = !_isInsightsExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      _selectedTimeLabelCapitalized(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    _isInsightsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildInsightTabSwitcher(),
                  const SizedBox(height: 16),
                  _selectedInsightTab == InsightTab.pieChart
                      ? _buildPieChartTab()
                      : _buildBreakdownTab(),
                ],
              ),
            ),
            crossFadeState: _isInsightsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedInsightTab = InsightTab.pieChart;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedInsightTab == InsightTab.pieChart
                      ? Colors.white.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Pie Chart',
                  style: TextStyle(
                    color: _selectedInsightTab == InsightTab.pieChart
                        ? Colors.white
                        : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedInsightTab = InsightTab.breakdown;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedInsightTab == InsightTab.breakdown
                      ? Colors.white.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Breakdown',
                  style: TextStyle(
                    color: _selectedInsightTab == InsightTab.breakdown
                        ? Colors.white
                        : Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartTab() {
    final categoryInsights = _categoryInsights();

    if (categoryInsights.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No spending insights available for this time period.',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }

    final highest = categoryInsights.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 46,
              sections: _pieChartSections(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.35)),
          ),
          child: Text(
            'Highest spending category: ${highest.category} (${_formatCurrency(highest.amount)})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...categoryInsights.map((item) {
          final isHighest = item.category == highest.category;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isHighest ? Colors.cyanAccent.withOpacity(0.45) : Colors.white10,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: isHighest ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  _formatCurrency(item.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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

  Widget _buildBreakdownTab() {
    final mostSpent = _mostSpentCategory();
    final highestTransaction = _highestTransaction();
    final totalTransactions = _expensesTime().length;
    final comparison = _comparisonToPreviousPeriod();

    return Column(
      children: [
        _buildBreakdownCard(
          title: 'Most spent category',
          value: mostSpent == null
              ? 'No data'
              : '${mostSpent['category']} • ${_formatCurrency((mostSpent['amount'] as num).toDouble())}',
        ),
        const SizedBox(height: 10),
        _buildBreakdownCard(
          title: 'Highest single transaction',
          value: highestTransaction == null
              ? 'No data'
              : '${_formatCurrency((highestTransaction['price'] as num).toDouble())} • ${highestTransaction['company']}',
        ),
        const SizedBox(height: 10),
        _buildBreakdownCard(
          title: 'Total number of transactions',
          value: totalTransactions.toString(),
        ),
        const SizedBox(height: 10),
        _buildBreakdownCard(
          title: 'Compared to previous ${_selectedTimeLabel()}',
          value: comparison,
        ),
      ],
    );
  }

  Widget _buildBreakdownCard({
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    // Retrieve the recent 7 expenses regardless of selected time frame
    final filtered = _recentTransactions();

    if (filtered.isEmpty) {
      return const Text(
        'No recent transactions available',
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
          _buildInsightsSection(),
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