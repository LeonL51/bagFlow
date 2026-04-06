import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/screens/login_screen.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart'; // adjust path

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Optional: handle navigation here
    // Example:
    // if (index == 1) Navigator.pushNamed(context, '/spending');
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GradientAppBar(
        title: 'Home',
        onMenuTap: () {
          Scaffold.of(context).openEndDrawer();
        },
      ),
      body: userProfile.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text("No user data"));
          }

          final profile = data as Map<String, dynamic>;
          final fullName = profile['fullName'] as String? ?? 'User';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome, $fullName",
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();

                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true)
                          .pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}