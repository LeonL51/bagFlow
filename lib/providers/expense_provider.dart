import 'pacakge:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/models/expense.dart';
import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/services/expense_service.dart'; 

final expenseServiceProvider = 
    Provider<ExpenseService>((ref) {
        return ExpenseService(); 
    });

final expenseLoadingProvider = StateProvider.autoDispose<bool>((ref) => false); 

final expensesProvider = StreamProvider<List<Expense>>((ref) {
    final authService = ref.watch(authServiceProvider);
    final expenseService = ref.watch(expenseServiceProvider);

    final user = authService.currentUSer;
    if (user == null) {
        return const Stream.empty();
    }

    return expenseService.streamExpenses(user.uid);
});