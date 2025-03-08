import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/theme/theme.dart';
import 'package:tourism_app/presentation/widgets/dertam_textfield.dart';

enum ExpenseCategory { food, transport, shopping, other }

extension ExpenseCategoryExtension on ExpenseCategory {
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.fastfood;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.shopping:
        return Icons.shopping_cart;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return "Food";
      case ExpenseCategory.transport:
        return "Transport";
      case ExpenseCategory.shopping:
        return "Shopping";
      case ExpenseCategory.other:
        return "Other";
    }
  }
}

class AddExpenseScreen extends StatefulWidget {
  final String selectedCurrency;
  final double remainingBudget;

  const AddExpenseScreen({
    Key? key,
    required this.selectedCurrency,
    required this.remainingBudget,
  }) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  double _totalExpense = 0.0;

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

  // Add expense logic with validation
  void _addExpense() {
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

    Navigator.pop(context, {
      "amount": "${widget.selectedCurrency} ${_totalExpense.toStringAsFixed(2)}",
      "description": _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : "No description",
      "date": _selectedDate.toString(),
      "category": _selectedCategory.label,
      "people": _peopleController.text.isNotEmpty ? _peopleController.text : "1",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add Expense"),
        backgroundColor: DertamColors.blueSky,
        actions: [
          TextButton(
            onPressed: _addExpense,
            child: Text("Save", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("${_selectedDate.toLocal()}".split(' ')[0]),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(_selectedCategory.icon),
              title: Text(_selectedCategory.label),
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
            DertamTextfield(
              label: "Expense Amount (${widget.selectedCurrency})",
              controller: _expenseController,
              keyboardType: TextInputType.number,
              borderColor: DertamColors.greyLight,
              focusedBorderColor: DertamColors.primary,
              onChanged: (value) => _calculateTotalExpense(),
            ),
    
            DertamTextfield(
              label: "Number of People",
              controller: _peopleController,
              keyboardType: TextInputType.number,
              borderColor: DertamColors.greyLight,
              focusedBorderColor: DertamColors.primary,
              onChanged: (value) => _calculateTotalExpense(),
            ),
            
            DertamTextfield(
              label: "Description",
              controller: _descriptionController,
              borderColor: DertamColors.greyLight,
              focusedBorderColor: DertamColors.primary,
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