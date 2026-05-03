import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:bag_flow/screens/navBar/addExpense_screen.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  int _currentIndex = 3;

  final double _monthlyBudget = 1000.00;
  final double _spentSoFar = 657.82;
  final int _daysRemaining = 18;

  final List<_BudgetCategory> _categories = const [
    _BudgetCategory(
      title: 'Food',
      spent: 268.40,
      budget: 350.00,
      icon: Icons.restaurant_rounded,
      color: Color(0xFF9F67FF),
    ),
    _BudgetCategory(
      title: 'Transportation',
      spent: 96.20,
      budget: 120.00,
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF3C93FF),
    ),
    _BudgetCategory(
      title: 'Education',
      spent: 45.00,
      budget: 200.00,
      icon: Icons.school_rounded,
      color: Color(0xFF1ED39A),
    ),
    _BudgetCategory(
      title: 'Shopping',
      spent: 102.15,
      budget: 180.00,
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFFA12E),
    ),
  ];

  final List<_UpcomingBill> _upcomingBills = const [
    _UpcomingBill(
      title: 'Rent',
      subtitle: 'Apr 28 • 5 days left',
      amount: 800.00,
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF9F67FF),
    ),
    _UpcomingBill(
      title: 'Spotify',
      subtitle: 'May 01 • 13 days left',
      amount: 10.99,
      icon: Icons.music_note_rounded,
      color: Color(0xFF3C93FF),
    ),
    _UpcomingBill(
      title: 'Internet',
      subtitle: 'May 07 • 19 days left',
      amount: 49.99,
      icon: Icons.wifi_rounded,
      color: Color(0xFF1ED39A),
    ),
  ];

  Future<void> _openAddExpenseScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Returns how much money is left 
  double get _remaining => _monthlyBudget - _spentSoFar;

  // Returns how much of the budget is used 
  double get _budgetProgress {
    if (_monthlyBudget == 0) return 0;
    return (_spentSoFar / _monthlyBudget).clamp(0.0, 1.0);
  }

  // Finds safe amount to spend today to prevent exceeding budget long-term 
  double get _safeToSpendToday {
    if (_daysRemaining <= 0) return 0;
    return _remaining / _daysRemaining;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(
        title: 'Planning',
        onMenuTap: () {},
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildOverviewCard(),
              const SizedBox(height: 18),
              _buildSectionHeader('Category Budgets', actionText: 'View All'),
              const SizedBox(height: 10),
              _buildCategoryBudgetCard(),
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUpcomingBillsCard(),
                  const SizedBox(height: 18),
                  _buildForecastCard(),
                ],
              ),
              const SizedBox(height: 18),
              _buildSectionHeader('Quick Actions'),
              const SizedBox(height: 10),
              _buildQuickActionsRow(),
              const SizedBox(height: 16),
              _buildPlanningTipCard(),
            ],
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
            openAddExpense: _openAddExpenseScreen,
          );
        },
      ),
    );
  }

  // Builds the first thing that users can easily see for budgeting 
  Widget _buildOverviewCard() {
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
                        'APRIL BUDGET',
                        _formatCurrency(_monthlyBudget),
                        Colors.white,
                      ),
                    ),
                    Expanded(
                      child: _metricColumn(
                        'SPENT SO FAR',
                        _formatCurrency(_spentSoFar),
                        const Color(0xFF9F67FF),
                      ),
                    ),
                    Expanded(
                      child: _metricColumn(
                        'REMAINING',
                        _formatCurrency(_remaining),
                        const Color(0xFF1ED39A),
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
              value: _budgetProgress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF9F67FF)),
            ),
          ),
          const SizedBox(height: 10),
          // Percentage of budget used 
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(_budgetProgress * 100).toStringAsFixed(0)}% Used',
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
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, color: Color(0xFFB77CFF)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You're on track! Keep it up to reach your goals.",
                    style: TextStyle(
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

  // Builds the category budgets section 
  Widget _buildCategoryBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: _categories.map((category) {
          final progress = (category.spent / category.budget).clamp(0.0, 1.0);
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
                const SizedBox(width: 6),
                // Shows the right arrow icon 
                const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ],
            ),
          );
        }).toList(), // map() returns iterable widget, but Column needs list widget 
      ),
    );
  }

  // Builds upcoming bill card
  Widget _buildUpcomingBillsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Upcoming Bills', actionText: 'See All'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: _upcomingBills.map((bill) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    // Display icon
                    _iconBubble(icon: bill.icon, color: bill.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // What the bill is for 
                          Text(
                            bill.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Shows deadline and days remaining
                          Text(
                            bill.subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Shows how much the cost for the upcoming bills would be 
                    Text(
                      _formatCurrency(bill.amount),
                      style: TextStyle(
                        color: bill.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Builds the forecast section 
  Widget _buildForecastCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Budget Forecast'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16), // ✅ REMOVED fixed height to prevent overflow
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
                _formatCurrency(_remaining),
                style: const TextStyle(
                  color: Color(0xFF9F67FF),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'left on Apr 30',
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

              // 🔥 TWEAK: Reduced height so chart isn't stretched vertically
              SizedBox(
                height: 90, // ⬅️ changed from 200 → prevents weird tall curve
                width: double.infinity, // ⬅️ ensures it fills horizontally
                child: CustomPaint(
                  painter: _ForecastLinePainter(),
                ),
              ),

              const SizedBox(height: 8),

              // Labels under the graph
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Start",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    "Today",
                    style: TextStyle(
                      color: Color(0xFFB77CFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Projected",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // SAFE TO SPEND TODAY
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
                _formatCurrency(_safeToSpendToday),
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
  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          // Allows user to set a budget
          child: _quickActionTile(
            icon: Icons.calculate_rounded,
            label: 'Set Budget',
            subtitle: 'Update monthly budget',
            color: const Color(0xFF9F67FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          // Allows user to create a savings goal 
          child: _quickActionTile(
            icon: Icons.track_changes_rounded,
            label: 'Create Goal',
            subtitle: 'Start saving',
            color: const Color(0xFF1ED39A),
          ),
        ),
        const SizedBox(width: 12),
        // Allow user to track additionall bills
        Expanded(
          child: _quickActionTile(
            icon: Icons.calendar_month_rounded,
            label: 'Plan Bills',
            subtitle: 'Add & track',
            color: const Color(0xFF3C93FF),
          ),
        ),
        const SizedBox(width: 12),
        // Allow user to define how much to limit their spending on certain categories 
        Expanded(
          child: _quickActionTile(
            icon: Icons.tune_rounded,
            label: 'Adjust',
            subtitle: 'Category limits',
            color: const Color(0xFFFFA12E),
          ),
        ),
      ],
    );
  }

  // Gives user a common general tip 
  Widget _buildPlanningTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFB77CFF),
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Planning Tip\n'
              'Try the 50/30/20 rule as a starting point:\n'
              '50% Needs, 30% Wants, 20% Savings.\n\n'
              'This is a general guideline—adjust based on your situation.',
              style: TextStyle(
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
          Text(
            actionText,
            style: const TextStyle(
              color: Color(0xFFB77CFF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
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
      width: 30,
      height: 25,
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  // Creates the layout for each tile
  Widget _quickActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBubble(icon: icon, color: color),
          const SizedBox(height: 16),
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

// Creates a class type for bills to get the necessary info 
class _UpcomingBill {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color color;

  const _UpcomingBill({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
  });
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