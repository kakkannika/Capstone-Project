import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/screens/budget/expense_screen.dart';
import 'package:tourism_app/presentation/widgets/dertam_textfield.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/providers/budget_provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/theme/theme.dart';

class SetBudgetScreen extends StatefulWidget {
  final String selectedCurrency;
  final String tripId;

  const SetBudgetScreen({
    super.key, 
    required this.selectedCurrency,
    required this.tripId,
  });

  @override
  _SetBudgetScreenState createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final TextEditingController _totalBudgetController = TextEditingController();
  final TextEditingController _dailyBudgetController = TextEditingController();
  bool _isLoading = false;

  void _navigateToExpenseScreen(String budgetId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseScreen(
          budgetId: budgetId,
          tripId: widget.tripId,
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (_totalBudgetController.text.trim().isEmpty ||
        _dailyBudgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter both budget fields"),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

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

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the budget in Firestore
      final budgetProvider = Provider.of<BudgetViewModel>(context, listen: false);
      final tripProvider = Provider.of<TripViewModel>(context, listen: false);
      
      final budgetId = await budgetProvider.createBudget(
        tripId: widget.tripId,
        total: totalBudget,
        currency: widget.selectedCurrency,
        dailyBudget: dailyBudget,
      );
      
      if (budgetId != null) {
        // Update the trip with the budget ID
        await tripProvider.updateTripBudgetId(
          tripId: widget.tripId,
          budgetId: budgetId,
        );
        
        // Navigate to the expense screen
        _navigateToExpenseScreen(budgetId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to create budget"),
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
                keyboardType: TextInputType.number,
                borderColor: DertamColors.greyLight,
              ),
              const SizedBox(height: DertamSpacings.s),
              DertamTextfield(
                label: "Daily Budget (${widget.selectedCurrency})",
                controller: _dailyBudgetController,
                keyboardType: TextInputType.number,
                borderColor: DertamColors.greyLight,
              ),
              const SizedBox(height: DertamSpacings.xxl),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : DertamButton(
                        text: "Continue",
                        buttonType: ButtonType.primary,
                        onPressed: _saveBudget,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
