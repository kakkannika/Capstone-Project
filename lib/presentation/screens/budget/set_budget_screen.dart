import 'package:flutter/material.dart';
import 'package:tourism_app/models/budget/budget.dart';
import 'package:tourism_app/presentation/screens/budget/expense_screen.dart';
import 'package:tourism_app/presentation/widgets/dertam_textfield.dart';
import 'package:tourism_app/presentation/theme/theme.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';

class SetBudgetScreen extends StatefulWidget {
  final String selectedCurrency;

  const SetBudgetScreen({super.key, required this.selectedCurrency});

  @override
  _SetBudgetScreenState createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final TextEditingController _totalBudgetController = TextEditingController();
  final TextEditingController _dailyBudgetController = TextEditingController();

  void _navigateToExpenseScreen() {
  if (_totalBudgetController.text.trim().isNotEmpty &&
      _dailyBudgetController.text.trim().isNotEmpty) {
    double totalBudget = double.tryParse(_totalBudgetController.text) ?? 0;
    double dailyBudget = double.tryParse(_dailyBudgetController.text) ?? 0;

    if (totalBudget <= 0 || dailyBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter valid budget values"),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

    // Create a `Budget` instance with dailyBudget
    Budget budget = Budget(
      total: totalBudget,
      currency: widget.selectedCurrency,
      dailyBudget: dailyBudget, // Pass the dailyBudget here
      expenses: [], // Initially empty, can be set later
      categoryLimits: {}, // Initially empty, can be set later
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseScreen(budget: budget),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Please enter both budget fields"),
        backgroundColor: DertamColors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.blueSky,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DertamSpacings.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Set Your Budget",
                  style: DertamTextStyles.heading.copyWith(
                    color: DertamColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: DertamSpacings.xl),
              Text(
                "Define your total and daily budget in ${widget.selectedCurrency}.",
                style: DertamTextStyles.body.copyWith(
                  color: DertamColors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: DertamSpacings.m),
              DertamTextfield(
                label: "Total Budget (${widget.selectedCurrency})",
                controller: _totalBudgetController,
                //icon: Icons.attach_money,
                borderColor: DertamColors.greyLight,
              ),
              const SizedBox(height: DertamSpacings.s),
              DertamTextfield(
                label: "Daily Budget (${widget.selectedCurrency})",
                controller: _dailyBudgetController,
                //icon: Icons.calendar_today,
                borderColor: DertamColors.greyLight,
              ),
              const SizedBox(height: DertamSpacings.xxl),
              Center(
                child: DertamButton(
                  text: "Continue",
                  buttonType: ButtonType.primary,
                  onPressed: _navigateToExpenseScreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
