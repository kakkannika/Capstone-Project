class Expense {
  String expenseId;
  String itineraryId;
  double amount;
  String category;
  DateTime date;
  String description;

  Expense({
    required this.expenseId,
    required this.itineraryId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['expenseId'] ?? '',
      itineraryId: json['itineraryId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'itineraryId': itineraryId,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
