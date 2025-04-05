import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app/data/repository/budget_repository.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:tourism_app/domain/models/budget/budget.dart';
import 'package:tourism_app/domain/models/budget/expend.dart';

class BudgetFirebaseRepository extends BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID
  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User is not logged in');
    }
  }

  // Create a new budget for a trip
  @override
  Future<String> createBudget({
    required String tripId,
    required double total,
    required String currency,
    required double dailyBudget,
  }) async {
    try {
      // Create a new budget document
      final budgetRef = _firestore.collection('budgets').doc();

      // Set the budget data
      await budgetRef.set({
        'total': total,
        'currency': currency,
        'dailyBudget': dailyBudget,
        'expenses': [],
        'categoryLimits': {},
        'tripId': tripId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update the trip with the budget ID reference
      await _firestore.collection('trips').doc(tripId).update({
        'budgetId': budgetRef.id,
      });

      return budgetRef.id;
    } catch (e) {
      throw Exception('Failed to create budget: $e');
    }
  }

  // Get a budget by ID
  @override
  Future<Budget?> getBudgetById(String budgetId) async {
    try {
      final doc = await _firestore.collection('budgets').doc(budgetId).get();

      if (doc.exists && doc.data() != null) {
        return Budget.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get budget: $e');
    }
  }

  // Get a budget by trip ID
  @override
  Future<Budget?> getBudgetByTripId(String tripId) async {
    try {
      final querySnapshot = await _firestore
          .collection('budgets')
          .where('tripId', isEqualTo: tripId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Budget.fromFirestore(querySnapshot.docs.first);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get budget by trip ID: $e');
    }
  }

  // Get a stream of a budget by trip ID
  @override
  Stream<Budget?> getBudgetByTripIdStream(String tripId) {
    return _firestore
        .collection('budgets')
        .where('tripId', isEqualTo: tripId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Budget.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  // Update a budget
  @override
  Future<void> updateBudget({
    required String budgetId,
    double? total,
    String? currency,
    double? dailyBudget,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (total != null) updates['total'] = total;
      if (currency != null) updates['currency'] = currency;
      if (dailyBudget != null) updates['dailyBudget'] = dailyBudget;

      if (updates.isNotEmpty) {
        await _firestore.collection('budgets').doc(budgetId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  // Add an expense to a budget
  @override
  Future<void> addExpense({
    required String budgetId,
    required Expense expense,
  }) async {
    try {
      // Get the current budget document
      final budgetDoc =
          await _firestore.collection('budgets').doc(budgetId).get();

      if (!budgetDoc.exists) {
        throw Exception('Budget not found');
      }

      // Get the current expenses array
      final data = budgetDoc.data() as Map<String, dynamic>;
      final List<dynamic> expenses = data['expenses'] ?? [];

      // Add the new expense
      expenses.add(expense.toMap());

      // Update the budget document with the new expenses array
      await _firestore.collection('budgets').doc(budgetId).update({
        'expenses': expenses,
      });
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // Update an expense in a budget
  @override
  Future<void> updateExpense({
    required String budgetId,
    required Expense updatedExpense,
  }) async {
    try {
      // Get the current budget document
      final budgetDoc =
          await _firestore.collection('budgets').doc(budgetId).get();

      if (!budgetDoc.exists) {
        throw Exception('Budget not found');
      }

      // Get the current expenses array
      final data = budgetDoc.data() as Map<String, dynamic>;
      final List<dynamic> expenses = List.from(data['expenses'] ?? []);

      // Find the index of the expense to update
      final expenseIndex =
          expenses.indexWhere((e) => e['id'] == updatedExpense.id);

      if (expenseIndex == -1) {
        throw Exception('Expense not found');
      }

      // Update the expense
      expenses[expenseIndex] = updatedExpense.toMap();

      // Update the budget document with the updated expenses array
      await _firestore.collection('budgets').doc(budgetId).update({
        'expenses': expenses,
      });
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // Remove an expense from a budget
  @override
  Future<void> removeExpense({
    required String budgetId,
    required String expenseId,
  }) async {
    try {
      // Get the current budget document
      final budgetDoc =
          await _firestore.collection('budgets').doc(budgetId).get();

      if (!budgetDoc.exists) {
        throw Exception('Budget not found');
      }

      // Get the current expenses array
      final data = budgetDoc.data() as Map<String, dynamic>;
      final List<dynamic> expenses = List.from(data['expenses'] ?? []);

      // Remove the expense with the matching ID
      expenses.removeWhere((e) => e['id'] == expenseId);

      // Update the budget document with the updated expenses array
      await _firestore.collection('budgets').doc(budgetId).update({
        'expenses': expenses,
      });
    } catch (e) {
      throw Exception('Failed to remove expense: $e');
    }
  }

  // Delete a budget
  @override
  Future<void> deleteBudget(String budgetId) async {
    try {
      // Get the budget to find the associated trip
      final budgetDoc =
          await _firestore.collection('budgets').doc(budgetId).get();

      if (budgetDoc.exists) {
        final data = budgetDoc.data() as Map<String, dynamic>;
        final String? tripId = data['tripId'];

        // Remove the budget reference from the trip
        if (tripId != null) {
          await _firestore.collection('trips').doc(tripId).update({
            'budgetId': FieldValue.delete(),
          });
        }
      }

      // Delete the budget document
      await _firestore.collection('budgets').doc(budgetId).delete();
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }
}
