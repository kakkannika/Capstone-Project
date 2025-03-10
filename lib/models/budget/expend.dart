import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseCategory { food, transportation, accommodation, tickets, shopping, other }

class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String description;
  final String? placeId;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.placeId,
  });

  factory Expense.fromFirestore(DocumentSnapshot data) {
    return Expense(
      id: data['id'],
      amount: data['amount'].toDouble(),
      category: ExpenseCategory.values[data['category']],
      date: data['date'].toDate(),
      description: data['description'],
      placeId: data['placeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.index,
      'date': date,
      'description': description,
      'placeId': placeId,
    };
  }
}