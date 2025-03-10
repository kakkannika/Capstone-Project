import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourism_app/admin/screen/main_screen.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/admin/service/place_crud_service.dart';

class AddPlaceTestScreen extends StatefulWidget {
  const AddPlaceTestScreen({super.key, required ScreenType screenType});

  @override
  State<AddPlaceTestScreen> createState() => _AddPlaceTestScreenState();
}

class _AddPlaceTestScreenState extends State<AddPlaceTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final PlaceCrudService _placeCrudService = PlaceCrudService();
  
  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageURLController = TextEditingController();
  final _categoryController = TextEditingController();
  final _ratingController = TextEditingController(text: "4.5");
  final _feesController = TextEditingController(text: "10.0");
  final _hoursController = TextEditingController(text: "9AM - 5PM");
  final _latitudeController = TextEditingController(text: "13.4125");
  final _longitudeController = TextEditingController(text: "103.8667");
  
  bool _isLoading = false;
  String _resultMessage = '';
  String? _createdPlaceId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageURLController.dispose();
    _categoryController.dispose();
    _ratingController.dispose();
    _feesController.dispose();
    _hoursController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _addPlace() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _resultMessage = 'Adding place to Firestore...';
        _createdPlaceId = null;
      });

      try {
        // Create Place object
        final newPlace = Place(
          id: '', // Empty ID since Firestore will generate one
          name: _nameController.text,
          description: _descriptionController.text,
          location: GeoPoint(
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
          ),
          imageURL: _imageURLController.text,
          category: _categoryController.text,
          averageRating: double.parse(_ratingController.text),
          entranceFees: double.parse(_feesController.text),
          openingHours: _hoursController.text,
        );

        // Add place to Firestore
        final placeId = await _placeCrudService.addPlace(newPlace);

        setState(() {
          _isLoading = false;
          if (placeId != null) {
            _createdPlaceId = placeId;
            _resultMessage = 'Place added successfully! ID: $placeId';
          } else {
            _resultMessage = 'Failed to add place';
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _resultMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Add Place to Firebase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Place',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Place Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Image URL
              TextFormField(
                controller: _imageURLController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. historical_place, natural_attraction, etc.'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Rating, Fees, Hours
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating (0-5)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 5) {
                          return 'Invalid rating';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _feesController,
                      decoration: const InputDecoration(
                        labelText: 'Entrance Fee',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid fee';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Opening Hours
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Opening Hours',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 9AM - 5PM'
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter opening hours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _addPlace,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('ADD PLACE TO FIREBASE'),
              ),
              const SizedBox(height: 16),
              
              // Result Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _createdPlaceId != null 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Result:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _createdPlaceId != null ? Colors.green : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(_resultMessage),
                    if (_createdPlaceId != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: SelectableText(
                              _createdPlaceId!,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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