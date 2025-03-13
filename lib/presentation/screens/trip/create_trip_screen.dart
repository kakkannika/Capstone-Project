import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:intl/intl.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _tripNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before new start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate()) return;

    final tripProvider = context.read<TripViewModel>();
    try {
      final tripId = await tripProvider.createTrip(
        tripName: _tripNameController.text,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      if (tripId != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully!')),
        );
        Navigator.pop(context, tripId);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating trip: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tripNameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  hintText: 'Enter your trip name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(_startDate == null 
                  ? 'Select start date'
                  : DateFormat('MMM dd, yyyy').format(_startDate!)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: () => _selectDate(context, true),
              ),
              if (_startDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    'Please select a start date',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(_endDate == null 
                  ? 'Select end date'
                  : DateFormat('MMM dd, yyyy').format(_endDate!)),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onTap: _startDate == null
                    ? null
                    : () => _selectDate(context, false),
              ),
              if (_endDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    'Please select an end date',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const Spacer(),
              if (tripProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    tripProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: tripProvider.isLoading
                    ? null
                    : () {
                        if (_startDate == null || _endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select both start and end dates'),
                            ),
                          );
                          return;
                        }
                        _createTrip();
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: tripProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 