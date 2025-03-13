// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/screens/trip/screen/trip_planner_screen.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:intl/intl.dart';

class PlanNewTripScreen extends StatefulWidget {
  const PlanNewTripScreen({super.key});

  @override
  _PlanNewTripScreenState createState() => _PlanNewTripScreenState();
}

class _PlanNewTripScreenState extends State<PlanNewTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  DateTime? startDate;
  DateTime? returnDate;
  List<String?> selectedDestinations = [];

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    selectedDestinations.add(null);
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (startDate ?? DateTime.now())
          : (returnDate ??
              (startDate?.add(const Duration(days: 7)) ?? DateTime.now())),
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
    return _tripNameController.text.isNotEmpty &&
        startDate != null &&
        returnDate != null;
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate() || !isFormValid()) return;

    final tripProvider = context.read<TripViewModel>();
    try {
      final tripId = await tripProvider.createTrip(
        tripName: _tripNameController.text,
        startDate: startDate!,
        endDate: returnDate!,
      );

      if (tripId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to TripPlannerScreen with the created trip details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripPlannerScreen(
              tripName: _tripNameController.text,
              selectedDestinations: selectedDestinations,
              startDate: startDate!,
              returnDate: returnDate,
              tripId: tripId,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add map functionality if needed
        },
        backgroundColor: const Color(0xFF0D3E4C),
        child: const Icon(Icons.map_outlined),
      ),
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
                    TextFormField(
                      controller: _tripNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter trip name',
                        labelText: 'Trip Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.trip_origin,
                            color: Color(0xFF0D3E4C)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a trip name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(
                            () {}); // Trigger rebuild to update button state
                      },
                    ),
                    const SizedBox(height: 20),
                    // Date Selection Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Start Date
                        Column(
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
                                  color: startDate != null
                                      ? Colors.teal.withOpacity(0.1)
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      startDate != null
                                          ? formatDate(startDate)
                                          : 'Select',
                                      style: TextStyle(
                                        color: startDate != null
                                            ? Colors.black
                                            : Colors.grey[600],
                                        fontWeight: startDate != null
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: startDate != null
                                          ? Colors.teal[600]
                                          : Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),
                        // Return Date

                        Column(
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
                                  color: returnDate != null
                                      ? Colors.teal.withOpacity(0.1)
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      returnDate != null
                                          ? formatDate(returnDate)
                                          : 'Select',
                                      style: TextStyle(
                                        color: returnDate != null
                                            ? Colors.black
                                            : Colors.grey[600],
                                        fontWeight: returnDate != null
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Icon(
                                      Icons.calendar_today,
                                      color: returnDate != null
                                          ? Colors.teal[600]
                                          : Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (tripProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          tripProvider.error!,
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: tripProvider.isLoading || !isFormValid()
                          ? null
                          : _createTrip,
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
                      child: tripProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
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
                          'Please fill in all required fields',
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
            ],
          ),
        ),
      ),
    );
  }
}
