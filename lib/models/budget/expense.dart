import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
enum ExpenseCategory { food, transportation, accommodation, tickets, shopping, other }
extension ExpenseCategoryExtension on ExpenseCategory {
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.shopping:
        return Icons.shopping_cart;
      case ExpenseCategory.other:
        return Icons.more_horiz;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.tickets:
        return Icons.airplanemode_active;
    }
  }

  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return "Food";
      case ExpenseCategory.transportation:
        return "Transport";
      case ExpenseCategory.shopping:
        return "Shopping";
      case ExpenseCategory.other:
        return "Other";
      case ExpenseCategory.accommodation:
        return "Accommodation";
      case ExpenseCategory.tickets:
        return "Tickets";
    }
  }
}
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

   // Factory constructor to create a new Expense with a unique ID
  factory Expense.create({
    
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required String description,
    String? placeId,
  }) {
    return Expense(
      id: const Uuid().v4(), 
      amount: amount,
      category: category,
      date: date,
      description: description,
      placeId: placeId,
    );
  }

  factory Expense.fromMap(Map data) {
    return Expense(
      id: data['id'] ?? const Uuid().v4(),
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