import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/models/place/place_category.dart';
import 'package:tourism_app/presentation/screens/dashboard/widgets/header.dart';
import 'package:tourism_app/theme/theme.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController entranceFeesController = TextEditingController();
  final TextEditingController openingHoursController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  PlaceCategory? selectedCategory;
  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DertamSpacings.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(),
              SizedBox(height: DertamSpacings.m),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField('Place Name', nameController),
                    _buildTextField('Description', descriptionController,
                        maxLines: 3),
                    _buildDropdown('Category', PlaceCategory.values,
                        (value) => setState(() => selectedCategory = value)),
                    _buildTextField('Entrance Fees', entranceFeesController,
                        keyboardType: TextInputType.number),
                    _buildTextField('Opening Hours', openingHoursController),
                    _buildTextField('Image URL', imageUrlController),
                    _buildTextField('Location', locationController),
                    SwitchListTile(
                      title: Text('Enabled'),
                      value: isEnabled,
                      onChanged: (value) => setState(() => isEnabled = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: _savePlace, child: Text('Save')),
                        ElevatedButton(
                          onPressed: _resetForm,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text('Reset'),
                        ),
                      ],
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

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDropdown(String label, List<PlaceCategory> items,
      ValueChanged<PlaceCategory?> onChanged) {
    return DropdownButtonFormField<PlaceCategory>(
      decoration:
          InputDecoration(labelText: label, border: OutlineInputBorder()),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _savePlace() {
    if (_formKey.currentState!.validate()) {
      final newPlace = Place(
        id: '',
        name: nameController.text,
        description: descriptionController.text,
        location: GeoPoint(0, 0),
        imageURL: [imageUrlController.text],
        category: selectedCategory ?? PlaceCategory.historical_place,
        entranceFees: double.tryParse(entranceFeesController.text),
        openingHours: openingHoursController.text,
        averageRating: 0.0,
      );
      // Save to Firestore or handle accordingly
    }
  }

  void _resetForm() {
    nameController.clear();
    descriptionController.clear();
    entranceFeesController.clear();
    openingHoursController.clear();
    imageUrlController.clear();
    locationController.clear();
    setState(() {
      selectedCategory = null;
      isEnabled = false;
    });
  }
}
