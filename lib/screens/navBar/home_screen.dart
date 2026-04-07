import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:bag_flow/screens/credentials/login_screen.dart'; 
import 'package:bag_flow/widgets/layouts/divider.dart'; 
import 'package:bag_flow/providers/auth_provider.dart';

enum TimeFilter { week, month, year }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); 
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  TimeFilter _selectedTime = TimeFilter.month; 

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider); 

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Home',
        onMenuTap: () {},
      ),
      body: userProfile.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text("No user data"));
          }

          final profile = data as Map<String, dynamic>;
          final fullName = profile['fullName'] as String? ?? 'User'; 

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, $fullName",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold, 
                      color: Colors.white, 
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Time Selection Row 
                  Row(
                    children: [
                      Expanded(
                        child: _filterButton(
                          label: "Week",
                          selected: _selectedTime == TimeFilter.week,
                          onTap: () {
                            setState(() {
                              _selectedTime = TimeFilter.week; 
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _filterButton(
                          label: "Month",
                          selected: _selectedTime == TimeFilter.month,
                          onTap: () {
                            setState(() {
                              _selectedTime = TimeFilter.month; 
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _filterButton(
                          label: "Year",
                          selected: _selectedTime == TimeFilter.year,
                          onTap: () {
                            setState(() {
                              _selectedTime = TimeFilter.year; 
                            });
                          },
                        ),
                      ), 
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Displays total spent time-based
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          // Is this valid? 
                          title: "Total Spent",
                          value: "\$0.00",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: _selectedTime == TimeFilter.week 
                            ? "This Week"
                            : _selectedTime == TimeFilter.month
                            ? "This Month"
                            : "This Year",
                          value: "\$0.00",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _sectionCard("Chart goes here"),

                  const SizedBox(height: 24),

                  _sectionCard("Pie chart goes here"),

                  const SizedBox(height: 24),

                  _recentTransactions(),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authServiceProvider).signOut(); 

                      // If widget is not in the UI and has been disposed, stop executing  
                      // Checks if HomeScreen is still on screen
                      if (!context.mounted) return; 

                      // Remove all previous screens 
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false, 
                      );
                    },
                    child: const Text("Logout"), 
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => 
        const Center(child: CircularProgressIndicator()),
        error: (e, _) => 
        Center(child: Text("Error: $e")), 
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped, 
      ), 
    );
  }

  Widget _filterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap, 
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? const Color(0xFF2563EB) : Colors.white,
          foregroundColor:
              selected ? Colors.white : Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label), 
      ),
    ); 
  }

  // Summary Card
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

  // Generic card (for chart placeholders)
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

  // Recent Transactions mock 
  Widget _recentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const  [
          ListTile(
            contentPadding: EdgeInsets.zero, 
            leading: CircleAvatar(
              child: Icon(Icons.receipt_long), 
            ),
            title: Text("Starbucks"),
            subtitle: Text("Apr 6"),
            trailing: Text("-\$8.75"),
          ),
          // AuthDivider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Icon(Icons.receipt_long),
            ),
            title: Text("Uber"),
            subtitle: Text("Apr 5"),
            trailing: Text("-\$24.10"), 
          ),
        ],
      ),
    );
  }
}