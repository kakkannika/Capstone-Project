import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
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
  bool _isLoading = false;
  Trip? _trip;
  double _dailyBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTripData();

    // Add listener to total budget controller to update daily budget
    _totalBudgetController.addListener(_updateDailyBudget);
  }

  @override
  void dispose() {
    _totalBudgetController.removeListener(_updateDailyBudget);
    _totalBudgetController.dispose();
    super.dispose();
  }

  // Fetch trip data to calculate number of days
  Future<void> _fetchTripData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripProvider = Provider.of<TripViewModel>(context, listen: false);
      
      // Listen to the trip stream
      tripProvider.getTripByIdStream(widget.tripId).listen((trip) {
        if (trip != null) {
          setState(() {
            _trip = trip;
            _updateDailyBudget();
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching trip data: $e"),
          backgroundColor: DertamColors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calculate daily budget based on total budget and trip duration
  void _updateDailyBudget() {
    if (_trip == null) return;
    
    double totalBudget = double.tryParse(_totalBudgetController.text) ?? 0;
    
    // Calculate number of days in the trip
    int numberOfDays = _trip!.days.length;
    
    // If there are no days or invalid number, default to 1 to avoid division by zero
    if (numberOfDays <= 0) numberOfDays = 1;
    
    // Calculate daily budget
    setState(() {
      _dailyBudget = totalBudget / numberOfDays;
    });
  }

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
    if (_totalBudgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a total budget"),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

    double totalBudget = double.tryParse(_totalBudgetController.text) ?? 0;

    if (totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid budget value"),
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
        dailyBudget: _dailyBudget,
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
      body: _isLoading && _trip == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                      "Define your total budget in ${widget.selectedCurrency}.",
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
                    
                    const Spacer(),
                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : DertamButton(
                              text: "Continue",
                              buttonType: ButtonType.primary,
                              onPressed: _saveBudget,
                            ),
                    ),
                    const SizedBox(height: DertamSpacings.m),
                  ],
                ),
              ),
            ),
    );
  }
}
