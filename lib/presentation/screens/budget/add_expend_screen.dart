// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/budget/expend.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/presentation/widgets/dertam_textfield.dart';
import 'package:tourism_app/providers/budget_provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/theme/theme.dart';

class AddExpenseScreen extends StatefulWidget {
  final String selectedCurrency;
  final double remainingBudget;
  final String budgetId;
  final String tripId;

  const AddExpenseScreen({
    super.key,
    required this.selectedCurrency,
    required this.remainingBudget,
    required this.budgetId,
    required this.tripId,
  });

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  double _totalExpense = 0.0;
  bool _isLoading = false;
  Trip? _trip;
  int _selectedDayIndex = 0;
  DateTime _selectedDate = DateTime.now();
  double _availableBudgetForSelectedDay = 0.0;
  bool _hasShownOverBudgetWarning = false; // Track if we've shown the warning

  @override
  void initState() {
    super.initState();
    _fetchTripData();
    _peopleController.text = "1"; // Default to 1 person
    _calculateTotalExpense();
  }

  // Fetch trip data to get days
  Future<void> _fetchTripData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      
      // Listen to the trip stream
      tripProvider.getTripByIdStream(widget.tripId).listen((trip) {
        if (trip != null && mounted) {
          setState(() {
            _trip = trip;
            // Set the default selected date to the first day of the trip
            if (trip.days.isNotEmpty) {
              _selectedDate = trip.startDate.add(Duration(days: _selectedDayIndex));
              
              // Update available budget for selected day
              if (budgetProvider.selectedBudget != null) {
                _updateAvailableBudget();
              }
            }
          });
        }
      });
      
      // Start listening to budget updates
      budgetProvider.startListeningToBudget(widget.tripId);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching trip data: $e"),
            backgroundColor: DertamColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Update available budget based on selected day
  void _updateAvailableBudget() {
    if (_trip == null) return;
    
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final budget = budgetProvider.selectedBudget;
    
    if (budget == null) return;
    
    setState(() {
      // Make sure we're using the actual daily budget from the budget object
      _availableBudgetForSelectedDay = budget.dailyBudget;
      
      // If daily budget is zero but total budget exists, calculate it
      if (_availableBudgetForSelectedDay <= 0 && budget.total > 0 && _trip!.days.isNotEmpty) {
        _availableBudgetForSelectedDay = budgetProvider.calculateDailyBudget(budget.total, _trip!.days.length);
        print("Fixed zero daily budget: $_availableBudgetForSelectedDay");
      }
      
      // Debug info - remove in production
      print("Daily budget set to: ${budget.dailyBudget}");
      print("Available budget set to: $_availableBudgetForSelectedDay");
      print("Total budget: ${budget.total}");
      print("Number of days: ${_trip!.days.length}");
    });
  }

  // Calculate total expense based on expense amount and number of people
  void _calculateTotalExpense() {
    double expenseAmount = double.tryParse(_expenseController.text) ?? 0.0;
    int peopleCount = int.tryParse(_peopleController.text) ?? 1;
    double newTotal = expenseAmount * peopleCount;

    if (newTotal != _totalExpense) {
      setState(() {
        _totalExpense = newTotal;
      });
    }
  }

  // Format day for dropdown display
  String _formatDayForDropdown(int dayIndex) {
    if (_trip == null) return "Day ${dayIndex + 1}";
    
    final date = _trip!.startDate.add(Duration(days: dayIndex));
    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    
    String formattedDate = "${DateFormat('EEE').format(date)} ${DateFormat('dd/MM').format(date)}";
    
    // Add "Today" label if it's today's date
    if (isToday) {
      formattedDate += " (Today)";
    }
    
    return formattedDate;
  }

  // Get the date status (Today, Future, Past)
  String _getDateStatus(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    
    if (checkDate.isAtSameMomentAs(todayDate)) {
      return "Today";
    } else if (checkDate.isAfter(todayDate)) {
      return "Future";
    } else {
      return "Past";
    }
  }

  // Add expense logic with validation
  Future<void> _addExpense() async {
    if (_expenseController.text.isEmpty || _peopleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all required fields."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

    int peopleCount = int.tryParse(_peopleController.text) ?? 1;

    if (peopleCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Number of people must be at least 1."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }
    
    // Check if expense amount is valid
    if (_totalExpense <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid expense amount."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }
    
    // Check if expense exceeds the daily budget for the selected day
    if (_totalExpense > _availableBudgetForSelectedDay) {
      // First time warning - show dialog
      if (!_hasShownOverBudgetWarning) {
        bool shouldContinue = await _showBudgetExceededDialog();
        if (!shouldContinue) {
          return;
        }
        
        // Set flag to prevent showing the dialog again
        _hasShownOverBudgetWarning = true;
      }
    }
    
    // Check if expense exceeds total remaining budget
    if (_totalExpense > widget.remainingBudget) {
      bool shouldContinue = await _showTotalBudgetExceededDialog();
      if (!shouldContinue) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the BudgetProvider to add the expense to Firestore
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      final success = await budgetProvider.addExpense(
        budgetId: widget.budgetId,
        amount: _totalExpense,
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : "No description",
      );
      
      if (success) {
        // Return to the previous screen
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add expense. Please try again."),
            backgroundColor: DertamColors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: DertamColors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Show confirmation dialog when exceeding daily budget
  Future<bool> _showBudgetExceededDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Budget Exceeded"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("This expense exceeds your daily budget of ${widget.selectedCurrency} ${_availableBudgetForSelectedDay.toStringAsFixed(2)}"),
                SizedBox(height: 8),
                Text("Are you sure you want to continue?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Continue Anyway"),
              style: TextButton.styleFrom(
                foregroundColor: DertamColors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  // Show confirmation dialog when exceeding total budget
  Future<bool> _showTotalBudgetExceededDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Total Budget Exceeded"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("This expense exceeds your remaining total budget of ${widget.selectedCurrency} ${widget.remainingBudget.toStringAsFixed(2)}"),
                SizedBox(height: 8),
                Text("Your total budget will be negative if you continue."),
                SizedBox(height: 8),
                Text("Are you sure you want to continue?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Continue Anyway"),
              style: TextButton.styleFrom(
                foregroundColor: DertamColors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Build day dropdown with proper date handling
  Widget _buildDayDropdown() {
    if (_trip == null || _trip!.days.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Day",
          style: DertamTextStyles.body.copyWith(
            color: DertamColors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: DertamColors.greyLight),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedDayIndex,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              iconSize: 24,
              elevation: 16,
              style: DertamTextStyles.body.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  DateTime newDate = _trip!.startDate.add(Duration(days: newValue));
                  
                  setState(() {
                    _selectedDayIndex = newValue;
                    _selectedDate = newDate;
                    _updateAvailableBudget();
                  });
                }
              },
              items: List.generate(_trip!.days.length, (index) {
                DateTime date = _trip!.startDate.add(Duration(days: index));
                String dateStatus = _getDateStatus(date);
                
                return DropdownMenuItem<int>(
                  value: index,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today, 
                        size: 18, 
                        color: DertamColors.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDayForDropdown(index),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (dateStatus == "Future")
                        Text(
                          "(Future)",
                          style: TextStyle(
                            color: DertamColors.grey,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        
        // Show info text about daily budgets and available budget
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Daily budget: ${widget.selectedCurrency} ${Provider.of<BudgetProvider>(context).selectedBudget?.dailyBudget.toStringAsFixed(2) ?? '0.00'}",
                style: TextStyle(
                  fontSize: 12,
                  color: DertamColors.grey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Available for ${_getDateStatus(_selectedDate) == 'Today' ? 'today' : _getDateStatus(_selectedDate) == 'Future' ? 'future day' : 'past day'}: ${widget.selectedCurrency} ${_availableBudgetForSelectedDay.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 12,
                  color: _availableBudgetForSelectedDay > 0 ? DertamColors.green : DertamColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Expense"),
        backgroundColor: DertamColors.blueSky,
        actions: [
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _addExpense,
                  child: Text("Save", style: TextStyle(color: Colors.black)),
                ),
        ],
      ),
      body: _isLoading && _trip == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total", style: DertamTextStyles.title),
                      Text("${widget.selectedCurrency} ${_totalExpense.toStringAsFixed(2)}",
                          style: DertamTextStyles.title),
                    ],
                  ),
                  SizedBox(height: DertamSpacings.m),
                  
                  // Day Dropdown
                  if (_trip != null && _trip!.days.isNotEmpty)
                    _buildDayDropdown(),
                  
                  SizedBox(height: DertamSpacings.m),
                  
                  // Category Selection
                  ListTile(
                    leading: Icon(_selectedCategory.icon),
                    title: Text(_selectedCategory.label),
                    trailing: Icon(Icons.arrow_drop_down),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: DertamColors.greyLight),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ListView(
                            children: ExpenseCategory.values
                                .map((category) => ListTile(
                                      leading: Icon(category.icon),
                                      title: Text(category.label),
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ))
                                .toList(),
                          );
                        },
                      );
                    },
                  ),
                  
                  SizedBox(height: DertamSpacings.m),
                  
                  DertamTextfield(
                    label: "Expense Amount (${widget.selectedCurrency})",
                    controller: _expenseController,
                    keyboardType: TextInputType.number,
                    borderColor: DertamColors.greyLight,
                    onChanged: (value) => _calculateTotalExpense(),
                  ),
                  
                  SizedBox(height: DertamSpacings.s),
                  
                  DertamTextfield(
                    label: "Number of People",
                    controller: _peopleController,
                    keyboardType: TextInputType.number,
                    borderColor: DertamColors.greyLight,
                    onChanged: (value) => _calculateTotalExpense(),
                  ),
                  
                  SizedBox(height: DertamSpacings.s),
                  
                  DertamTextfield(
                    label: "Description",
                    controller: _descriptionController,
                    borderColor: DertamColors.greyLight,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _expenseController.dispose();
    _descriptionController.dispose();
    _peopleController.dispose();
    super.dispose();
  }
}