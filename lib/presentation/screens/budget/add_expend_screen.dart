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
    Key? key,
    required this.selectedCurrency,
    required this.remainingBudget,
    required this.budgetId,
    required this.tripId,
  }) : super(key: key);

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
      final tripProvider = Provider.of<TripViewModel>(context, listen: false);
      
      // Listen to the trip stream
      tripProvider.getTripByIdStream(widget.tripId).listen((trip) {
        if (trip != null && mounted) {
          setState(() {
            _trip = trip;
            // Set the default selected date to the first day of the trip
            if (trip.days.isNotEmpty) {
              _selectedDate = trip.startDate.add(Duration(days: _selectedDayIndex));
            }
          });
        }
      });
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
    return "${DateFormat('EEE').format(date)} ${DateFormat('dd/MM').format(date)}";
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

    if (_totalExpense <= 0 || _totalExpense > widget.remainingBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid amount. Ensure it's within budget."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the BudgetViewModel to add the expense directly to Firestore
      final budgetProvider = Provider.of<BudgetViewModel>(context, listen: false);
      
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
                              setState(() {
                                _selectedDayIndex = newValue;
                                _selectedDate = _trip!.startDate.add(Duration(days: newValue));
                              });
                            }
                          },
                          items: List.generate(_trip!.days.length, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: DertamColors.primary),
                                  SizedBox(width: 8),
                                  Text(
                                    _formatDayForDropdown(index),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  
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