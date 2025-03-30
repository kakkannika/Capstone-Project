import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/presentation/widgets/dertam_textfield.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/theme/theme.dart';

/// This screen is used to edit a trip. It allows the user to update the trip name, start date, and end date.
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
    return DateFormat('d/MMM/yyyy').format(date);
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
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      
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
          SnackBar(
            content: Text('Trip updated successfully!'),
            backgroundColor: DertamColors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating trip: $e'),
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: DertamColors.backgroundAccent,
      appBar: AppBar(
        title: Text(
          'Edit Trip',
          style: TextStyle(
            color: DertamColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          'Edit Trip Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: DertamColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update your trip information',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: DertamColors.grey,
                          ),
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
                        const SizedBox(height: 32),
                        // Update button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !_hasChanges) ? null : _updateTrip,
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
                            child: _isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          DertamColors.white),
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
                        ),
                        const SizedBox(height: 16),
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
          child: _buildDateField('End Date', false),
        ),
      ],
    );
  }

  Widget _buildDateSelectionColumn() {
    return Column(
      children: [
        _buildDateField('Start Date', true),
        const SizedBox(height: DertamSpacings.s),
        _buildDateField('End Date', false),
      ],
    );
  }

  Widget _buildDateField(String label, bool isStartDate) {
    final date = isStartDate ? _startDate : _endDate;
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
                color: DertamColors.primary,
              ),
              borderRadius: BorderRadius.circular(12),
              color: DertamColors.blueSky,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: DertamColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDate(date!),
                    style: TextStyle(
                      color: DertamColors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
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