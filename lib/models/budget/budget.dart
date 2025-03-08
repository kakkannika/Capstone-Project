// Budget Models
import 'package:tourism_app/models/budget/expense.dart';

class Budget {
  final double total;
  final String currency;
  final List<Expense> expenses;
  final Map<ExpenseCategory, double> categoryLimits;

  Budget({
    required this.total,
    required this.currency,
    required this.expenses,
    required this.categoryLimits,
  });

  double get spentTotal => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remaining => total - spentTotal;

  factory Budget.fromMap(Map data) {
    return Budget(
      total: data['total'].toDouble(),
      currency: data['currency'],
      expenses: (data['expenses'] as List)
          .map((e) => Expense.fromMap(e))
          .toList(),
      categoryLimits: (data['categoryLimits'] as Map).map(
        (k, v) => MapEntry(
          ExpenseCategory.values[k],
          v.toDouble(),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'currency': currency,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'categoryLimits': categoryLimits.map(
        (k, v) => MapEntry(k.index, v),
      ),
    };
  }
}