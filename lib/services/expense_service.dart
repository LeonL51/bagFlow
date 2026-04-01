import 'package:bag_flow/models/expense.dart'; 

class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore}) 
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // addExpense method 
  // Firestore structure: users/{uid}/expenses/{expenseId}
  Future<void> addExpense(Expense expense) async {
    await _firestore
      .collection('users')
      .doc(expense.userId)
      .collection('expenses')
      .add(expense.toMap());
  }
}