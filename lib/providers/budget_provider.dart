import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tourism_app/repository/firebase/budget_firebase_repository.dart';
import 'package:tourism_app/models/budget/budget.dart';
import 'package:tourism_app/models/budget/expend.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetFirebaseRepository _budgetService = BudgetFirebaseRepository();

  Budget? _selectedBudget;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Budget?>? _budgetSubscription;

  Budget? get selectedBudget => _selectedBudget;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  // Get a budget by trip ID
  Future<Budget?> getBudgetByTripId(String tripId) async {
    try {
      _setLoading(true);
      _error = null;

      final budget = await _budgetService.getBudgetByTripId(tripId);

      if (budget != null) {
        _selectedBudget = budget;
      }

      _setLoading(false);
      return budget;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to get budget: $e');
      return null;
    }
  }

  // Get a stream of a budget by trip ID
  Stream<Budget?> getBudgetByTripIdStream(String tripId) {
    return _budgetService.getBudgetByTripIdStream(tripId);
  }

  // Start listening to a budget stream for a specific trip
  void startListeningToBudget(String tripId) {
    _setLoading(true);
    _error = null;

    // Cancel any existing subscription
    _budgetSubscription?.cancel();

    // Start a new subscription
    _budgetSubscription = _budgetService.getBudgetByTripIdStream(tripId).listen(
      (budget) {
        _selectedBudget = budget;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setLoading(false);
        _setError('Error listening to budget: $error');
      },
    );
  }

  // Create a new budget for a trip
  Future<String?> createBudget({
    required String tripId,
    required double total,
    required String currency,
    required double dailyBudget,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      final budgetId = await _budgetService.createBudget(
        tripId: tripId,
        total: total,
        currency: currency,
        dailyBudget: dailyBudget,
      );

      _setLoading(false);
      return budgetId;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to create budget: $e');
      return null;
    }
  }

  // Update a budget
  Future<bool> updateBudget({
    required String budgetId,
    double? total,
    String? currency,
    double? dailyBudget,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _budgetService.updateBudget(
        budgetId: budgetId,
        total: total,
        currency: currency,
        dailyBudget: dailyBudget,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update budget: $e');
      return false;
    }
  }

  // Add an expense to a budget
  Future<bool> addExpense({
    required String budgetId,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required String description,
    String? placeId,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final expense = Expense.create(
        amount: amount,
        category: category,
        date: date,
        description: description,
        placeId: placeId,
      );

      await _budgetService.addExpense(
        budgetId: budgetId,
        expense: expense,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to add expense: $e');
      return false;
    }
  }

  // Update an expense in a budget
  Future<bool> updateExpense({
    required String budgetId,
    required Expense updatedExpense,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _budgetService.updateExpense(
        budgetId: budgetId,
        updatedExpense: updatedExpense,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update expense: $e');
      return false;
    }
  }

  // Remove an expense from a budget
  Future<bool> removeExpense({
    required String budgetId,
    required String expenseId,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _budgetService.removeExpense(
        budgetId: budgetId,
        expenseId: expenseId,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to remove expense: $e');
      return false;
    }
  }

  // Delete a budget
  Future<bool> deleteBudget(String budgetId) async {
    try {
      _setLoading(true);
      _error = null;

      await _budgetService.deleteBudget(budgetId);

      if (_selectedBudget?.id == budgetId) {
        _selectedBudget = null;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to delete budget: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _budgetSubscription?.cancel();
    super.dispose();
  }
}
