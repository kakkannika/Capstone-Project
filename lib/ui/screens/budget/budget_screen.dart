// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/domain/models/trips/trips.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/providers/budget_provider.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
import 'package:tourism_app/ui/screens/budget/expend_screen.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';

class BudgetScreen extends StatefulWidget {
  final String tripId;
  final String? budgetId; // Add budgetId for editing

  const BudgetScreen({
    super.key,
    required this.tripId,
    this.budgetId, // Optional for editing
  });

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _totalBudgetController = TextEditingController();
  final TextEditingController _dailyBudgetController = TextEditingController();
  final List<String> currencies = ['\$', '៛'];
  String? selectedCurrency = '\$';
  bool _isLoading = false;
  Trip? _trip;
  double _dailyBudget = 0.0;
  int _numberOfDays = 0;
  bool _dailyBudgetManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    _fetchTripData();

    // If editing, fetch the existing budget
    if (widget.budgetId != null) {
      _fetchBudgetData();
    }

    _totalBudgetController.addListener(_updateDailyBudget);
    _dailyBudgetController.addListener(() {
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

  Future<void> _fetchTripData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching trip data: $e"),
            backgroundColor: DertamColors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBudgetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      final budget = await budgetProvider.getBudgetById(widget.budgetId!);

      if (budget != null) {
        setState(() {
          _totalBudgetController.text = budget.total.toString();
          _dailyBudgetController.text = budget.dailyBudget.toString();
          selectedCurrency = budget.currency;
          _dailyBudget = budget.dailyBudget;
        });
        _updateDailyBudget();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching budget data: $e"),
            backgroundColor: DertamColors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateDailyBudget() {
    if (_trip == null || selectedCurrency == null) return;

    double totalBudget = double.tryParse(_totalBudgetController.text) ?? 0;
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    setState(() {
      _dailyBudget =
          budgetProvider.calculateDailyBudget(totalBudget, _numberOfDays);

      if (!_dailyBudgetManuallyEdited) {
        _dailyBudgetController.text =
            _dailyBudget > 0 ? _dailyBudget.toStringAsFixed(2) : '';
      }
    });
  }

  Future<void> _saveBudget() async {
    if (selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a currency."),
          backgroundColor: DertamColors.red,
        ),
      );
      return;
    }

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

    // Validation for Riel currency
    if (selectedCurrency == '៛') {
      if (totalBudget < 50000 || totalBudget % 100 != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Riel currency must be an integer and at least 50000."),
            backgroundColor: DertamColors.red,
          ),
        );
        return;
      }
    }

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
      if (widget.budgetId != null) {
        // Update existing budget
        await budgetProvider.updateBudget(
          budgetId: widget.budgetId!,
          total: totalBudget,
          currency: selectedCurrency!,
          dailyBudget: dailyBudget,
        );
        // Navigate to ExpenseScreen after updating
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseScreen(
                budgetId: widget.budgetId!,
                tripId: widget.tripId,
              ),
            ),
          );
        }
      } else {
        // Create new budget
        final budgetId = await budgetProvider.createBudget(
          tripId: widget.tripId,
          total: totalBudget,
          currency: selectedCurrency!,
          dailyBudget: dailyBudget,
        );

        if (budgetId != null && mounted) {
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
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Budget saved successfully."),
            backgroundColor: DertamColors.green,
          ),
        );
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
    String currencySymbol = selectedCurrency
            ?.split(' ')
            .last
            .replaceAll('(', '')
            .replaceAll(')', '') ??
        '';

    return Scaffold(
      backgroundColor: DertamColors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Set Your Budget",
          style: DertamTextStyles.heading.copyWith(
            color: DertamColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: DertamColors.grey),
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
                            const SizedBox(height: DertamSpacings.xl),

                            // Budget input with currency toggle
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _totalBudgetController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText:
                                          "Total Budget ${currencySymbol != '' ? '($currencySymbol)' : ''}",
                                      labelStyle:
                                          DertamTextStyles.body.copyWith(
                                        color: DertamColors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            DertamSpacings.radius),
                                        borderSide: BorderSide(
                                            color: DertamColors.greyLight,
                                            width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            DertamSpacings.radius),
                                        borderSide: BorderSide(
                                            color: DertamColors.greyLight,
                                            width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            DertamSpacings.radius),
                                        borderSide: BorderSide(
                                            color: DertamColors.primary,
                                            width: 2),
                                      ),
                                      fillColor: DertamColors.white,
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 4.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: DertamColors.greyLight
                                                .withOpacity(
                                                    0.2), // Light background
                                            borderRadius: BorderRadius.circular(
                                                12), // Rounded corners
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: selectedCurrency,
                                              icon: Icon(Icons.arrow_drop_down,
                                                  color: DertamColors.grey),
                                              dropdownColor: DertamColors
                                                  .white, // Dropdown background color
                                              borderRadius: BorderRadius.circular(
                                                  12), // Rounded dropdown corners
                                              items: currencies.map((currency) {
                                                return DropdownMenuItem<String>(
                                                  value: currency,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        currency == '\$'
                                                            ? Icons.attach_money
                                                            : Icons
                                                                .currency_exchange,
                                                        color: DertamColors
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        currency == '\$'
                                                            ? 'Dollar (\$)'
                                                            : 'Riel (៛)',
                                                        style: DertamTextStyles
                                                            .body,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    selectedCurrency = value;
                                                    _updateDailyBudget();
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                          "Daily Budget ${currencySymbol != '' ? '($currencySymbol)' : ''}",
                                      controller: _dailyBudgetController,
                                      keyboardType: TextInputType.number,
                                      borderColor: DertamColors.greyLight,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        icon: Icon(
                                          Icons.refresh,
                                          color: DertamColors
                                              .primary, // Matching turquoise color
                                          size: 18,
                                        ),
                                        label: Text(
                                          "Reset to auto-calculated",
                                          style: TextStyle(
                                            color: DertamColors
                                                .primary, // Matching turquoise color
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
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _saveBudget,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DertamColors.primary,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
