// Budget Models
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/budget/expense.dart';

class Budget {
  final String id;
  final double total;
  final String currency;
  final double dailyBudget; 
  final List<Expense> expenses;
  final Map<ExpenseCategory, double> categoryLimits;
  final String tripId;

  Budget({
    required this.id,
    required this.total,
    required this.currency,
    required this.expenses,
    required this.dailyBudget,
    required this.categoryLimits,
    required this.tripId,
  });

  double get spentTotal => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remaining => total - spentTotal;

  factory Budget.fromMap(Map<String, dynamic> data, String id) {
    return Budget(
      id: id,
      total: (data['total'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'USD',
      dailyBudget: (data['dailyBudget'] ?? 0).toDouble(),
      expenses: data['expenses'] != null 
          ? (data['expenses'] as List).map((e) => Expense.fromMap(e)).toList()
          : [],
      categoryLimits: data['categoryLimits'] != null 
          ? (data['categoryLimits'] as Map).map(
              (k, v) => MapEntry(
                ExpenseCategory.values[int.parse(k.toString())],
                v.toDouble(),
              ),
            )
          : {},
      tripId: data['tripId'] ?? '',
    );
  }

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Budget.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'currency': currency,
      'dailyBudget': dailyBudget,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'categoryLimits': categoryLimits.map(
        (k, v) => MapEntry(k.index.toString(), v),
      ),
      'tripId': tripId,
    };
  }
}