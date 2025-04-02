// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/ui/screens/budget/expend_screen.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/ui/providers/budget_provider.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
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
  Trip? _trip;
  double _dailyBudget = 0.0;
  int _numberOfDays = 0;
  bool _dailyBudgetManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    _fetchTripData();

    // Add listener to total budget controller to update daily budget
    _totalBudgetController.addListener(_updateDailyBudget);

    // Add listener to daily budget controller to track manual edits
    _dailyBudgetController.addListener(() {
      // Mark as manually edited if the value differs from the calculated one
      if (!_dailyBudgetManuallyEdited) {
        double manualValue = double.tryParse(_dailyBudgetController.text) ?? 0;
        if (manualValue != _dailyBudget && manualValue > 0) {
          setState(() {
            _dailyBudgetManuallyEdited = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _totalBudgetController.removeListener(_updateDailyBudget);
    _totalBudgetController.dispose();
    _dailyBudgetController.dispose();
    super.dispose();
  }

  // Fetch trip data to calculate number of days
  Future<void> _fetchTripData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // Listen to the trip stream
      tripProvider.getTripByIdStream(widget.tripId).listen((trip) {
        if (trip != null) {
          setState(() {
            _trip = trip;
            _numberOfDays = trip.days.length;
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

    // Use the budget provider to calculate daily budget
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    // Only update the controller if the user hasn't manually edited it
    setState(() {
      _dailyBudget =
          budgetProvider.calculateDailyBudget(totalBudget, _numberOfDays);

      if (!_dailyBudgetManuallyEdited) {
        _dailyBudgetController.text =
            _dailyBudget > 0 ? _dailyBudget.toStringAsFixed(2) : '';
      }
    });
  }

  // Save the budget to Firestore
  Future<void> _saveBudget() async {
    if (_totalBudgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a total budget."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

    double totalBudget = double.tryParse(_totalBudgetController.text) ?? 0;
    double dailyBudget = double.tryParse(_dailyBudgetController.text) ?? 0;

    if (totalBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid budget amount."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

    if (dailyBudget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid daily budget amount."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);

      // Debug information - remove in production
      print("Creating budget with:");
      print("Total budget: $totalBudget");
      print("Daily budget: $dailyBudget");
      print("Number of days: $_numberOfDays");

      final budgetId = await budgetProvider.createBudget(
        tripId: widget.tripId,
        total: totalBudget,
        currency: widget.selectedCurrency,
        dailyBudget: dailyBudget,
      );

      if (budgetId != null) {
        if (mounted) {
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to set budget. Please try again."),
              backgroundColor: DertamColors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
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
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
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
                              label:
                                  "Total Budget (${widget.selectedCurrency})",
                              controller: _totalBudgetController,
                              keyboardType: TextInputType.number,
                              borderColor: DertamColors.greyLight,
                            ),
                            if (_trip != null && _trip!.days.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: DertamSpacings.m),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Trip Duration: $_numberOfDays days",
                                      style: DertamTextStyles.body.copyWith(
                                        color: DertamColors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    DertamTextfield(
                                      label:
                                          "Daily Budget (${widget.selectedCurrency})",
                                      controller: _dailyBudgetController,
                                      keyboardType: TextInputType.number,
                                      borderColor: DertamColors.greyLight,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        icon: Icon(
                                          Icons.refresh,
                                          color: DertamColors.primary,
                                          size: 18,
                                        ),
                                        label: Text(
                                          "Reset to auto-calculated",
                                          style: TextStyle(
                                            color: DertamColors.primary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _dailyBudgetManuallyEdited = false;
                                            _updateDailyBudget();
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Note: Daily budget is automatically calculated but you can adjust it manually if needed.",
                                      style: DertamTextStyles.body.copyWith(
                                        color: DertamColors.grey,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
