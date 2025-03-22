// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/budget/budget.dart';
import 'package:tourism_app/models/budget/expend.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/presentation/screens/budget/add_expend_screen.dart';
import 'package:tourism_app/presentation/screens/budget/widget/budget_card.dart';
import 'package:tourism_app/providers/budget_provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/theme/theme.dart';

class ExpenseScreen extends StatefulWidget {
  final String budgetId;
  final String tripId;

  const ExpenseScreen({
    super.key, 
    required this.budgetId,
    required this.tripId,
  });

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Set to track removed expense IDs
  final Set<String> _removedExpenseIds = {};
  Trip? _trip;
  String _selectedFilter = 'all'; // Default filter: all, today, other dates
  
  @override
  void initState() {
    super.initState();
    // Start listening to the budget stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false)
          .startListeningToBudget(widget.tripId);
      // Get trip data
      _fetchTripData();
    });
  }
  
  // Fetch trip data
  void _fetchTripData() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.getTripByIdStream(widget.tripId).listen((trip) {
      if (mounted && trip != null) {
        setState(() {
          _trip = trip;
        });
      }
    });
  }

  void _navigateToAddExpense(Budget budget) async {
    // Navigate to AddExpenseScreen and wait for the result
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          selectedCurrency: budget.currency,
          remainingBudget: budget.remaining,
          budgetId: budget.id,
          tripId: widget.tripId,
        ),
      ),
    );
  }

  void _navigateToEditExpense(Budget budget, Expense expense) async {
    // Navigate to AddExpenseScreen in edit mode
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          selectedCurrency: budget.currency,
          remainingBudget: budget.remaining + expense.amount, // Add back this expense's amount
          budgetId: budget.id,
          tripId: widget.tripId,
          expense: expense, // Pass the expense for editing
          isEditing: true,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format date as "Day of week dd/MM" (e.g., "Mon 01/04")
    return "${DateFormat('EEE').format(date)} ${DateFormat('dd/MM').format(date)}";
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("It's pretty empty here...", style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 8),
          Text("Enter your\n1st expense", textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Handle expense removal
  void _removeExpense(Budget budget, Expense expense) {
    // Store expense details for potential undo
    // Add to removed expenses set
    setState(() {
      _removedExpenseIds.add(expense.id);
    });
    
    // Show snackbar with undo option before removing from Firestore
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('item removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Remove from the removed set to restore in UI
            setState(() {
              _removedExpenseIds.remove(expense.id);
            });
            // Cancel the snackbar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 3),
        onVisible: () {
          // When snackbar is visible, start a timer to remove from Firestore
          Future.delayed(const Duration(seconds: 3), () {
            // Only remove from Firestore if still in removed set
            if (_removedExpenseIds.contains(expense.id)) {
              Provider.of<BudgetProvider>(context, listen: false).removeExpense(
                budgetId: budget.id,
                expenseId: expense.id,
              ).then((success) {
                if (!success) {
                  // If removal failed, show error and restore in UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove expense. Please try again.'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // Remove from removed expenses set
                  setState(() {
                    _removedExpenseIds.remove(expense.id);
                  });
                }
              });
            }
          });
        },
      ),
    );
  }

  // Build the date filter buttons
  Widget _buildDateFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildFilterButton('all', 'All'),
          const SizedBox(width: 8),
          _buildFilterButton('today', 'Today'),
          const SizedBox(width: 8),
          _buildFilterButton('past', 'Past'),
          const SizedBox(width: 8),
          _buildFilterButton('future', 'Future'),
        ],
      ),
    );
  }

  // Build an individual filter button
  Widget _buildFilterButton(String value, String label) {
    final isSelected = _selectedFilter == value;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? DertamColors.primary : DertamColors.greyLight,
        foregroundColor: isSelected ? Colors.white : DertamColors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(label),
    );
  }

  // Check if expense matches the current filter
  bool _expenseMatchesFilter(Expense expense) {
    if (_selectedFilter == 'all') return true;
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
    
    if (_selectedFilter == 'today') {
      return expenseDate.isAtSameMomentAs(todayDate);
    } else if (_selectedFilter == 'past') {
      return expenseDate.isBefore(todayDate);
    } else if (_selectedFilter == 'future') {
      return expenseDate.isAfter(todayDate);
    }
    
    return false;
  }

  // Check if an expense is from today
  bool _isExpenseFromToday(Expense expense) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
    return expenseDate.isAtSameMomentAs(todayDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.white,
      appBar: AppBar(
        backgroundColor: DertamColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DertamColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Budget & Expenses",
          style: TextStyle(color: DertamColors.black),
        ),
      ),
      body: StreamBuilder<Budget?>(
        stream: Provider.of<BudgetProvider>(context).getBudgetByTripIdStream(widget.tripId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final budget = snapshot.data;
          if (budget == null) {
            return const Center(child: Text('Budget not found'));
          }

          // Print budget information to debug
          print("Budget in UI: Total=${budget.total}, Daily=${budget.dailyBudget}, Spent=${budget.spentTotal}");
          
          double totalBudgetValue = budget.total;
          double totalSpent = budget.spentTotal;
          double dailyBudget = budget.dailyBudget;
          
          // If daily budget is 0 but total budget exists, recalculate
          if (dailyBudget <= 0 && totalBudgetValue > 0) {
            // Get trip info to calculate daily budget
            final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
            
            // Use trip days to recalculate daily budget (this is a temporary UI fix)
            if (_trip != null && _trip!.days.isNotEmpty) {
              dailyBudget = budgetProvider.calculateDailyBudget(totalBudgetValue, _trip!.days.length);
              print("Recalculated daily budget: $dailyBudget");
            }
          }
          
          // Filter out removed expenses
          List<Expense> expenses = budget.expenses
              .where((expense) => !_removedExpenseIds.contains(expense.id))
              .toList();
          
          // Calculate today's expenses for daily budget
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);
          
          // Filter today's expenses only
          List<Expense> todayExpenses = expenses.where((expense) {
            final expenseDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
            return expenseDate.isAtSameMomentAs(todayDate);
          }).toList();
          
          // Calculate total spent today
          double todaySpent = todayExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
          print("Today's expenses: $todaySpent");
          
          // Sort expenses by date (newest first)
          expenses.sort((a, b) => b.date.compareTo(a.date));
          
          // Filter expenses based on selected filter
          List<Expense> filteredExpenses = expenses
              .where((expense) => _expenseMatchesFilter(expense))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BudgetCard(
                      title: 'Total', 
                      spent: totalSpent, 
                      budget: totalBudgetValue,
                      currency: budget.currency,
                      
                    ),
                    SizedBox(width: DertamSpacings.s),
                    BudgetCard(
                      title: 'Daily Budget', 
                      spent: todaySpent, 
                      budget: dailyBudget,
                      currency: budget.currency,
                      
                    ),
                  ],
                ),
              ),
              SizedBox(height: DertamSpacings.m),
              
              // Date filter buttons
              _buildDateFilters(),
              
              SizedBox(height: DertamSpacings.m),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expense list',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Remaining: ${budget.currency} ${budget.remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: budget.remaining > 0 ? DertamColors.primary : DertamColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: DertamColors.grey),
                            SizedBox(height: 16),
                            Text(
                              "No expenses found",
                              style: TextStyle(color: DertamColors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredExpenses.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          final isToday = _isExpenseFromToday(expense);
                          
                          return Dismissible(
                            key: Key(expense.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _removeExpense(budget, expense);
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: isToday ? Colors.white : Colors.white.withOpacity(0.7),
                              child: ListTile(
                                onTap: () => _navigateToEditExpense(budget, expense),
                                leading: CircleAvatar(
                                  backgroundColor: isToday 
                                      ? DertamColors.primary.withOpacity(0.2)
                                      : DertamColors.grey.withOpacity(0.2),
                                  child: Icon(
                                    expense.category.icon,
                                    color: isToday ? DertamColors.primary : DertamColors.grey,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${expense.amount} ${budget.currency}', 
                                        style: DertamTextStyles.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isToday ? DertamColors.black : DertamColors.grey,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isToday 
                                            ? DertamColors.primary.withOpacity(0.1)
                                            : DertamColors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _formatDate(expense.date),
                                        style: TextStyle(
                                          color: isToday ? DertamColors.primary : DertamColors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  expense.description,
                                  style: DertamTextStyles.label.copyWith(
                                    color: isToday ? null : DertamColors.grey.withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: StreamBuilder<Budget?>(
        stream: Provider.of<BudgetProvider>(context).getBudgetByTripIdStream(widget.tripId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          
          final budget = snapshot.data!;
          
          return FloatingActionButton(
            onPressed: () => _navigateToAddExpense(budget),
            backgroundColor: DertamColors.primary,
            child: Icon(Icons.add, color: DertamColors.white),
          );
        },
      ),
    );
  }
}