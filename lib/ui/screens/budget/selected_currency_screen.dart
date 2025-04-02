// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tourism_app/ui/screens/budget/set_budget_screen.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/theme/theme.dart';

class SelectCurrencyScreen extends StatefulWidget {
  final String tripId;

  const SelectCurrencyScreen({
    super.key,
    required this.tripId,
  });

  @override
  _SelectCurrencyScreenState createState() => _SelectCurrencyScreenState();
}

class _SelectCurrencyScreenState extends State<SelectCurrencyScreen> {
  final List<String> currencies = ['USD (\$)', 'KHR (៛)',];
  String? selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/background_budget.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DertamSpacings.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Select your home Currency",
                    style: DertamTextStyles.heading.copyWith(
                      color: DertamColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: DertamSpacings.xl),
                Text(
                  "Usually it's the currency of your bank account",
                  style: DertamTextStyles.body.copyWith(
                    color: DertamColors.black.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: DertamSpacings.m),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DertamSpacings.s,
                    vertical: DertamSpacings.s / 2,
                  ),
                  decoration: BoxDecoration(
                    color: DertamColors.white,
                    borderRadius: BorderRadius.circular(DertamSpacings.radius),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: InputBorder.none),
                    value: selectedCurrency,
                    hint: Text(
                      "Home Currency",
                      style: DertamTextStyles.body.copyWith(
                        color: DertamColors.grey,
                      ),
                    ),
                    items: currencies
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency, style: DertamTextStyles.body),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedCurrency = value),
                  ),
                ),
                const SizedBox(height: DertamSpacings.xxl),
                Center(
                  child: DertamButton(
                    text: "Continue",
                    buttonType: ButtonType.primary,
                    onPressed: selectedCurrency != null
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SetBudgetScreen(
                                  selectedCurrency: selectedCurrency!,
                                  tripId: widget.tripId,
                                ),
                              ),
                            );
                          }
                        : () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}