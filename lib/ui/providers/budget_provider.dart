import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tourism_app/data/repository/budget_repository.dart';
import 'package:tourism_app/data/repository/firebase/budget_firebase_repository.dart';
import 'package:tourism_app/data/repository/firebase/trip_firebase_repository.dart';
import 'package:tourism_app/models/budget/budget.dart';
import 'package:tourism_app/models/budget/expend.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetRepository _budgetService = BudgetFirebaseRepository();

  final TripProvider _tripProvider = TripProvider(TripFirebaseRepository());

  Budget? _selectedBudget;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Budget?>? _budgetSubscription;

  // Use static to ensure it persists across instances and rebuilds
  static bool _hasShownOverBudgetWarning = false;

  Budget? get selectedBudget => _selectedBudget;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasShownOverBudgetWarning => _hasShownOverBudgetWarning;

  // Method to set the flag when warning has been shown
  void setOverBudgetWarningShown(bool value) {
    _hasShownOverBudgetWarning = value;
    // No need to notify listeners since this doesn't affect UI directly
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  // Calculate daily budget based on total budget and number of days
  double calculateDailyBudget(double totalBudget, int numberOfDays) {
    if (numberOfDays <= 0) numberOfDays = 1; // Avoid division by zero

    // Debug information - remove in production

    return totalBudget / numberOfDays;
  }

  // Get the available budget for today
  double getAvailableBudgetForToday(Trip trip, Budget budget) {
    if (trip.days.isEmpty) return 0.0;

    // Find which day of the trip today is
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final tripStartDate =
        DateTime(trip.startDate.year, trip.startDate.month, trip.startDate.day);

    // Calculate days since trip started
    final difference = todayDate.difference(tripStartDate).inDays;

    // If today is before trip starts or after trip ends, no budget available
    if (difference < 0 || difference >= trip.days.length) {
      return 0.0;
    }

    // Return daily budget for today
    return budget.dailyBudget;
  }

  // Get the available budget for a specific day
  double getAvailableBudgetForDay(Trip trip, Budget budget, int dayIndex) {
    // Check if day index is valid
    if (trip.days.isEmpty || dayIndex < 0 || dayIndex >= trip.days.length) {
      return 0.0;
    }

    // For all days, return the daily budget
    return budget.dailyBudget;
  }

  // Check if a day's budget is available (e.g., if the day has arrived)
  bool isDayBudgetAvailable(Trip trip, int dayIndex) {
    // Check if day index is valid
    if (trip.days.isEmpty || dayIndex < 0 || dayIndex >= trip.days.length) {
      return false;
    }

    // All days are now available
    return true;
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

  // Add a method to reset the warning flag (useful for testing)
  void resetOverBudgetWarning() {
    _hasShownOverBudgetWarning = false;
    _setError("Over budget warning flag has been reset");
  }

  // Start listening to a budget stream for a specific trip
  void startListeningToBudget(String tripId) {
    _setLoading(true);
    _error = null;

    // Cancel any existing subscription
    _budgetSubscription?.cancel();

    // Don't reset the warning flag - we want it to persist across all trips in a session
    // _hasShownOverBudgetWarning = false; - removing this line

    // Start a new subscription
    _budgetSubscription = _budgetService.getBudgetByTripIdStream(tripId).listen(
      (budget) {
        _selectedBudget = budget;

        // Debug information - remove in production
        if (budget != null) {
          // Check if daily budget needs to be recalculated
          if (budget.dailyBudget <= 0 && budget.total > 0) {
            _fixDailyBudget(tripId, budget);
          }
        } else {
          _setError("Error fixing daily budget: $tripId");
        }

        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setLoading(false);
        _setError('Error listening to budget: $error');
      },
    );
  }

  // Fix a budget with zero daily budget
  Future<void> _fixDailyBudget(String tripId, Budget budget) async {
    try {
      // Get the trip to calculate days
      await _tripProvider.selectTrip(tripId);
      final trip = _tripProvider.selectedTrip;

      if (trip != null && trip.days.isNotEmpty) {
        // Calculate correct daily budget
        final correctDailyBudget =
            calculateDailyBudget(budget.total, trip.days.length);
        _setError("Fixing daily budget to: $correctDailyBudget");
        // Update the budget with the correct daily budget
        await updateBudget(
          budgetId: budget.id,
          dailyBudget: correctDailyBudget,
        );
      }
    } catch (e) {
      _setError("Error fixing daily budget: $e");
    }
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

      // Ensure daily budget is never zero
      double finalDailyBudget = dailyBudget;
      if (finalDailyBudget <= 0 && total > 0) {
        // Get the trip to calculate days
        await _tripProvider.selectTrip(tripId);
        final trip = _tripProvider.selectedTrip;

        if (trip != null && trip.days.isNotEmpty) {
          finalDailyBudget = calculateDailyBudget(total, trip.days.length);
        } else {
          finalDailyBudget = total; // Default to total if can't calculate
        }
      }

      // Debug information - remove in production

      final budgetId = await _budgetService.createBudget(
        tripId: tripId,
        total: total,
        currency: currency,
        dailyBudget: finalDailyBudget,
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