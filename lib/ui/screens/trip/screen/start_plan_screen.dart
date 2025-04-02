// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD:lib/presentation/screens/trip/screen/start_plan_screen.dart
import 'package:tourism_app/presentation/screens/trip/screen/trip_planner_screen.dart';
import 'package:tourism_app/presentation/widgets/dertam_textfield.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/theme/theme.dart';
=======
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/screens/trip/screen/widget/trip_planner_screen.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/screen/start_plan_screen.dart

//this screen is used to plan a new trip. It shows the trip name, start date, and return date fields.
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
    return DateFormat('d/MMM/yyyy').format(date);
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
            colorScheme: ColorScheme.light(
              primary: DertamColors.primary,
<<<<<<< HEAD:lib/presentation/screens/trip/screen/start_plan_screen.dart
              onPrimary: DertamColors.white,
              surface: DertamColors.white,
              onSurface: DertamColors.black,
=======
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/screen/start_plan_screen.dart
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

    final tripProvider = context.read<TripProvider>();
    try {
      final tripId = await tripProvider.createTrip(
        tripName: _tripNameController.text,
        startDate: startDate!,
        endDate: returnDate!,
      );

      if (tripId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip created successfully!'),
            backgroundColor: DertamColors.green,
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
          backgroundColor: DertamColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
<<<<<<< HEAD:lib/presentation/screens/trip/screen/start_plan_screen.dart
      backgroundColor: DertamColors.backgroundAccent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
       // iconTheme: IconThemeData(color: DertamColors.black),
        title: Text(
          'Trip Planning',
          style: TextStyle(
            color: DertamColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 600,
                    minHeight: screenSize.height * 0.5,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: DertamColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: DertamColors.grey.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
=======
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
                  color: DertamColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: DertamColors.grey.withOpacity(0.1),
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
                    Text(
                      'Plan a new Trip',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: DertamColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build an itinerary and organize your\nupcoming travel plans',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: DertamColors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DertamTextfield(
                      label: 'Trip Name',
                      controller: _tripNameController,
                      keyboardType: TextInputType.text,
                      borderColor: DertamColors.grey,
                      focusedBorderColor: DertamColors.primary,
                      textColor: DertamColors.black,
                      backgroundColor: DertamColors.white,
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
                    // ...existing code...
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Start Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: DertamColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
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
                                            ? DertamColors.primary
                                            : DertamColors.grey,
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
                              Text(
                                'Return Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: DertamColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey[300]!),
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
                                              ? DertamColors.black
                                              : DertamColors.grey,
                                          fontWeight: returnDate != null
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: returnDate != null
                                            ? DertamColors.primary
                                            : DertamColors.grey,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/screen/start_plan_screen.dart
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        SizedBox(height: DertamSpacings.s-4),

                        // Title and Description
                        Text(
                          'Plan a New Trip',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: DertamColors.black,
                          ),
                        ),
<<<<<<< HEAD:lib/presentation/screens/trip/screen/start_plan_screen.dart
                        const SizedBox(height: 8),
                        Text(
                          'Build an itinerary and organize your upcoming travel plans',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: DertamColors.grey,
                          ),
=======
                      ),
                    ElevatedButton(
                      onPressed: tripProvider.isLoading || !isFormValid()
                          ? null
                          : _createTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DertamColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/screen/start_plan_screen.dart
                        ),
                        const SizedBox(height: DertamSpacings.s),
                        // Trip Name Field
                        DertamTextfield(
                          label: 'Trip Name',
                          controller: _tripNameController,
                          keyboardType: TextInputType.text,
                          borderColor: DertamColors.grey,
                          focusedBorderColor: DertamColors.primary,
                          textColor: DertamColors.black,
                          backgroundColor: DertamColors.white,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a trip name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: DertamSpacings.s),
                        // Date Selection    
                        isSmallScreen
                            ? _buildDateSelectionColumn()
                            : _buildDateSelectionRow(),
                        SizedBox(height: DertamSpacings.l),
                        // Error message if any
                        if (tripProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              tripProvider.error!,
                              style: TextStyle(
                                color: DertamColors.red,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                     
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: tripProvider.isLoading || !isFormValid()
                                ? null
                                : _createTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DertamColors.primary,
                              foregroundColor: DertamColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              disabledBackgroundColor: DertamColors.backgroundAccent,
                            ),
                            child: tripProvider.isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          DertamColors.white),
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
                        ),
                        if (!isFormValid())
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              'Please fill in all required fields',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: DertamColors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: DertamSpacings.s),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectionRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField('Start Date', true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateField('Return Date', false),
        ),
      ],
    );
  }

  Widget _buildDateSelectionColumn() {
    return Column(
      children: [
        _buildDateField('Start Date', true),
        const SizedBox(height: DertamSpacings.s),
        _buildDateField('Return Date', false),
      ],
    );
  }

  Widget _buildDateField(String label, bool isStartDate) {
    final date = isStartDate ? startDate : returnDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: DertamColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isStartDate),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: date != null
                    ? DertamColors.primary
                    : DertamColors.backgroundAccent,
              ),
              borderRadius: BorderRadius.circular(12),
              color: date != null
                  ? DertamColors.blueSky
                  : DertamColors.backgroundAccent,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: date != null
                      ? DertamColors.primary
                      : DertamColors.grey,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null ? formatDate(date) : 'Select date',
                    style: TextStyle(
                      color: date != null ? DertamColors.black : DertamColors.grey,
                      fontWeight:
                          date != null ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,//handle text overflow
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}