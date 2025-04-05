// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/domain/models/place/place_category.dart';
import 'package:tourism_app/domain/models/trips/trips.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/screens/trip/screen/widget/trip_planner_screen.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';

class PlanNewTripScreen extends StatefulWidget {
  final Trip? trip;
  const PlanNewTripScreen({super.key, this.trip});

  @override
  _PlanNewTripScreenState createState() => _PlanNewTripScreenState();
}

class _PlanNewTripScreenState extends State<PlanNewTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tripNameController;
  DateTime? startDate;
  DateTime? returnDate;
  List<String?> selectedDestinations = [];
  String? selectedProvince; // Add selected province
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tripNameController = TextEditingController();

    if (widget.trip != null) {
      // Edit mode - populate fields with existing trip data
      _tripNameController.text = widget.trip!.tripName;
      startDate = widget.trip!.startDate;
      returnDate = widget.trip!.endDate;
      selectedProvince = widget.trip!.province;
      _tripNameController.addListener(_checkForChanges);
    } else {
      // Create mode - initialize with defaults
      startDate = DateTime.now();
      selectedDestinations.add(null);
    }
  }

  @override
  void dispose() {
    if (widget.trip != null) {
      _tripNameController.removeListener(_checkForChanges);
    }
    _tripNameController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    if (widget.trip == null) return;

    final nameChanged = _tripNameController.text != widget.trip!.tripName;
    final startDateChanged = startDate != widget.trip!.startDate;
    final endDateChanged = returnDate != widget.trip!.endDate;
    final provincesChanged = selectedProvince != widget.trip!.province;

    final newHasChanges =
        nameChanged || startDateChanged || endDateChanged || provincesChanged;

    if (newHasChanges != _hasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
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
            colorScheme: ColorScheme.light(
              primary: DertamColors.primary,
              onPrimary: DertamColors.white,
              surface: DertamColors.white,
              onSurface: DertamColors.black,
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
            returnDate = startDate!.add(const Duration(days: 1));
          }
        } else {
          returnDate = picked;
        }
        _checkForChanges();
      });
    }
  }

  bool isFormValid() {
    return _tripNameController.text.isNotEmpty &&
        startDate != null &&
        returnDate != null &&
        selectedProvince != null; // Add province validation
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate() || !isFormValid()) return;

    final tripProvider = context.read<TripProvider>();
    try {
      if (widget.trip == null) {
        // Create new trip
        final tripId = await tripProvider.createTrip(
          tripName: _tripNameController.text,
          startDate: startDate!,
          endDate: returnDate!,
          province: selectedProvince,
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
                province: selectedProvince,
              ),
            ),
          );
        }
      } else {
        final String? newName =
            _tripNameController.text != widget.trip!.tripName
                ? _tripNameController.text
                : null;
        final DateTime? newStartDate =
            startDate != widget.trip!.startDate ? startDate : null;
        final DateTime? newEndDate =
            returnDate != widget.trip!.endDate ? returnDate : null;
        final String? newProvince =
            selectedProvince != widget.trip!.province ? selectedProvince : null;

        await tripProvider.updateTrip(
          tripId: widget.trip!.id,
          tripName: newName,
          startDate: newStartDate,
          endDate: newEndDate,
          province: newProvince,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Trip updated successfully!'),
              backgroundColor: DertamColors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error ${widget.trip == null ? "creating" : "updating"} trip: $e'),
            backgroundColor: DertamColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();

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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new),
                        ),
                        Expanded(
                          child: Text(
                            widget.trip == null ? 'Plan a new Trip' : 'Edit Trip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: DertamColors.primary,
                            ),
                          ),
                        ),
                      ],
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

                    // Province Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Province',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DertamColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: selectedProvince != null
                                ? Colors.teal.withOpacity(0.1)
                                : null,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text('Select a province'),
                              value: selectedProvince,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: selectedProvince != null
                                    ? DertamColors.primary
                                    : DertamColors.grey,
                              ),
                              elevation: 16,
                              style: TextStyle(
                                color: DertamColors.black,
                                fontSize: 16,
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedProvince = value;
                                });
                              },
                              items:
                                  Province.values.map<DropdownMenuItem<String>>(
                                (Province province) {
                                  return DropdownMenuItem<String>(
                                    value: province.displayName,
                                    child: Text(province.displayName),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date Selection Row
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
                            color: DertamColors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // In the build method, update the ElevatedButton
                    ElevatedButton(
                      onPressed: tripProvider.isLoading ||
                              (widget.trip == null && !isFormValid()) ||
                              (widget.trip != null &&
                                  (!isFormValid() || !_hasChanges))
                          ? null
                          : _createTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DertamColors.primary,
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
                          : Text(
                              widget.trip == null
                                  ? 'START PLANNING'
                                  : 'UPDATE TRIP',
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
