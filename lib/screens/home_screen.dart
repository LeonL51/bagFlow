import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/screens/add_expense_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
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
                  },

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                      );
                    },
                    child: const Text("Add Expense"),
                  ),
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

