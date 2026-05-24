import 'package:bag_flow/models/expense.dart';
import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/services/expense_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final expenseLoadingProvider = StateProvider<bool>((ref) => false);

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final expenseService = ref.watch(expenseServiceProvider);

  return authAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value(<Expense>[]);
      }

      return expenseService.streamExpenses(user.uid);
    },
    loading: () => Stream.value(<Expense>[]),
    error: (_, __) => Stream.value(<Expense>[]),
  );
});