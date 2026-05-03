import 'package:bag_flow/models/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final FirebaseFirestore _firestore;

  ExpenseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addExpense(Expense expense) async {
    await _firestore
        .collection('users')
        .doc(expense.userId)
        .collection('expenses')
        .add(expense.toMap());
  }

  Future<void> addExpenses(List<Expense> expenses) async {
    if (expenses.isEmpty) return;

    final batch = _firestore.batch();

    for (final expense in expenses) {
      final docRef = _firestore
          .collection('users')
          .doc(expense.userId)
          .collection('expenses')
          .doc();

      batch.set(docRef, expense.toMap());
    }

    await batch.commit();
  }

  Future<List<Expense>> getAllExpenses(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Expense>> streamExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Expense.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}