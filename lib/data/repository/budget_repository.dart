import 'package:tourism_app/domain/models/budget/budget.dart';
import 'package:tourism_app/domain/models/budget/expend.dart';

abstract class BudgetRepository {
  Future<String> createBudget({
    required String tripId,
    required double total,
    required String currency,
    required double dailyBudget,
  });

  Future<Budget?> getBudgetById(String budgetId);

  Future<Budget?> getBudgetByTripId(String tripId);

  Stream<Budget?> getBudgetByTripIdStream(String tripId);

  Future<void> updateBudget({
    required String budgetId,
    double? total,
    String? currency,
    double? dailyBudget,
  });

  Future<void> addExpense({
    required String budgetId,
    required Expense expense,
  });

  Future<void> updateExpense({
    required String budgetId,
    required Expense updatedExpense,
  });

  Future<void> removeExpense({
    required String budgetId,
    required String expenseId,
  });
  Future<void> deleteBudget(String budgetId);

  
}
