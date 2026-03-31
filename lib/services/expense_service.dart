Future<void> addExpense(Expense expense) async {
  await FirebaseFirestore.instance
      .collection('expenses')
      .add(expense.toMap());
}