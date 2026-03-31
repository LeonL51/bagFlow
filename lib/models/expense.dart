class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final bool isRecurring;
  final DateTime date;
  final DateTime? createdAt;

  Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isRecurring = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Build a new object from raw materials 
  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id, 
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(), 
      isRecurring: map['isRecurring'] ?? false,
      createdAt: map['createdAt'] != null 
        ? DateTime.tryParse(map['createdAt'])
        : null, 
    );
  }

  // Create a new object based on an existing one, with some changes
  // Does not modify original objects 
  // Expense = expense.copyWith(title: "Dinner"); 
  Expense copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    bool? isRecurring,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
