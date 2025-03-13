import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/providers/trip_provider.dart';



class EditTripScreen extends StatefulWidget {
  final Trip trip;

  const EditTripScreen({
    super.key,
    required this.trip,
  });

  @override
  _EditTripScreenState createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tripNameController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tripNameController = TextEditingController(text: widget.trip.tripName);
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    
    // Listen for changes to detect if form has been modified
    _tripNameController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _tripNameController.removeListener(_checkForChanges);
    _tripNameController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    final nameChanged = _tripNameController.text != widget.trip.tripName;
    final startDateChanged = _startDate != widget.trip.startDate;
    final endDateChanged = _endDate != widget.trip.endDate;
    
    final newHasChanges = nameChanged || startDateChanged || endDateChanged;
    
    if (newHasChanges != _hasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate! : _endDate!,
      firstDate: isStartDate ? DateTime.now() : _startDate!,
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
          _startDate = picked;
          // If end date is before new start date, update end date
          if (_endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
        _checkForChanges();
      });
    }
  }

  Future<void> _updateTrip() async {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tripProvider = Provider.of<TripViewModel>(context, listen: false);
      
      // Only update fields that have changed
      final String? newName = _tripNameController.text != widget.trip.tripName ? _tripNameController.text : null;
      final DateTime? newStartDate = _startDate != widget.trip.startDate ? _startDate : null;
      final DateTime? newEndDate = _endDate != widget.trip.endDate ? _endDate : null;
      
      await tripProvider.updateTrip(
        tripId: widget.trip.id,
        tripName: newName,
        startDate: newStartDate,
        endDate: newEndDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating trip: $e'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: const Text(
          'Edit Trip',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                      'Edit Trip Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3E4C),
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
                        prefixIcon: const Icon(Icons.trip_origin, color: Color(0xFF0D3E4C)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a trip name';
                        }
                        return null;
                      },
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
                                    color: Colors.teal.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(_startDate!),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.teal[600],
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
                                'End Date',
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
                                    color: Colors.teal.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(_endDate!),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.teal[600],
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
                    ElevatedButton(
                      onPressed: (_isLoading || !_hasChanges) ? null : _updateTrip,
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
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _hasChanges ? 'UPDATE TRIP' : 'NO CHANGES',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
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