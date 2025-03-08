import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/prsentation/screens/Trip_Plan1/Start_Plan/search_screen.dart' as search;
import 'package:tourism_app/prsentation/screens/Trip_Plan1/Trip_Planner/trip_plan_test.dart';

class PlanNewTripScreen extends StatefulWidget {
  const  PlanNewTripScreen({Key? key}) : super(key: key);

  @override
  _PlanNewTripScreenState createState() => _PlanNewTripScreenState();
}

class _PlanNewTripScreenState extends State<PlanNewTripScreen> {
  DateTime? startDate;
  DateTime? returnDate;
  List<String?> selectedDestinations = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    selectedDestinations.add(null); 
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (returnDate ?? (startDate?.add(const Duration(days: 7)) ?? DateTime.now())),
      firstDate: isStartDate ? DateTime.now() : (startDate ?? DateTime.now()),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D3E4C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (returnDate != null && returnDate!.isBefore(picked)) {
            returnDate = null;
          }
        } else {
          returnDate = picked;
        }
      });
    }
  }

  bool isFormValid() {
    return selectedDestinations.any((destination) => destination != null && destination.isNotEmpty) &&
        startDate != null &&
        returnDate != null;
  }

  void _removeDestination(int index) {
    if (selectedDestinations.length > 1) {
      setState(() {
        selectedDestinations.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Plan a new Trip',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3E4C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Build an itinerary and organize your\nupcoming travel plans',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Destination Input
                    Column(
                      children: selectedDestinations.asMap().entries.map((entry) {
                        int index = entry.key;
                        String? destination = entry.value;
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const search.DetailedSearchScreen(),
                                        ),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          selectedDestinations[index] = result;
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextField(
                                        enabled: false, // Disable direct input
                                        decoration: InputDecoration(
                                          hintText: destination ?? 'Where to go?\n(e.g., Royal Palaces, Koh Rong)',
                                          hintStyle: TextStyle(
                                            color: destination != null ? Colors.black : Colors.grey[600],
                                            fontSize: 14,
                                            fontWeight: destination != null ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          prefixIcon: Icon(Icons.place, color: Colors.teal[600]),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                          filled: destination != null,
                                          fillColor: destination != null ? Colors.teal.withOpacity(0.1) : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (selectedDestinations.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey),
                                    onPressed: () => _removeDestination(index),
                                  ),
                              ],
                            ),
                            if (index == selectedDestinations.length - 1)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selectedDestinations.add(null);
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D3E4C)),
                                label: const Text(
                                  'Add another destination',
                                  style: TextStyle(color: Color(0xFF0D3E4C), fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Date Selection Row
                    Row(
                      children: [
                        // Start Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0D3E4C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: startDate != null ? Colors.teal.withOpacity(0.1) : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        startDate != null ? formatDate(startDate) : 'Select',
                                        style: TextStyle(
                                          color: startDate != null ? Colors.black : Colors.grey[600],
                                          fontWeight: startDate != null ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: startDate != null ? Colors.teal[600] : Colors.grey[600],
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Return Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Return Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0D3E4C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: returnDate != null ? Colors.teal.withOpacity(0.1) : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        returnDate != null ? formatDate(returnDate) : 'Optional',
                                        style: TextStyle(
                                          color: returnDate != null ? Colors.black : Colors.grey[600],
                                          fontWeight: returnDate != null ? FontWeight.w500 : FontWeight.normal,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: returnDate != null ? Colors.teal[600] : Colors.grey[600],
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Start Planning Button
                    ElevatedButton(
  onPressed: isFormValid() ? () async {
    if (_formKey.currentState!.validate()) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripPlannerScreen(
            selectedDestinations: selectedDestinations,
            startDate: startDate!,
            returnDate: returnDate, // Pass the return date here
          ),
        ),
      );
      if (result != null) {
        setState(() {
          selectedDestinations.add(result);
        });
      }
    }
  } : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0D3E4C),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
    disabledBackgroundColor: Colors.grey[300],
  ),
  child: const Text(
    'START PLANNING',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),
),
       if (!isFormValid())
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please select at least one destination and both dates',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[400],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Travel Tips Container
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.teal[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
