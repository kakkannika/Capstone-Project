import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/models/place/place_category.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/providers/placecrud.dart';
import 'package:tourism_app/theme/theme.dart';

class DestinationScreen extends StatefulWidget {
  final Place? place; // Optional place parameter for editing

  const DestinationScreen({
    super.key,
    this.place,
  });

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final PlaceCrudService _placeCrudService = PlaceCrudService();

  // Text controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageURLController = TextEditingController();
  final _categoryController = TextEditingController();
  final _ratingController = TextEditingController();
  final _feesController = TextEditingController();
  final _hoursController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  PlaceCategory? selectedCategory;

  bool _isLoading = false;
  String? _createdPlaceId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.place != null;
    if (_isEditing) {
      // Populate form fields with existing place data
      _nameController.text = widget.place!.name;
      _descriptionController.text = widget.place!.description;
      _imageURLController.text = widget.place!.imageURL;
      _categoryController.text = widget.place!.category;
      _ratingController.text = widget.place!.averageRating?.toString() ?? '';
      _feesController.text = widget.place!.entranceFees?.toString() ?? '';
      _hoursController.text = widget.place!.openingHours ?? '';
      _latitudeController.text = widget.place!.location.latitude.toString();
      _longitudeController.text = widget.place!.location.longitude.toString();
    }
  }

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

  Future<void> _savePlace() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final place = Place(
          id: _isEditing ? widget.place!.id : '',
          name: _nameController.text,
          description: _descriptionController.text,
          location: GeoPoint(
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
          ),
          imageURL: _imageURLController.text,
          category: _categoryController.text,
          entranceFees: double.tryParse(_feesController.text),
          openingHours: _hoursController.text,
          averageRating: double.tryParse(_ratingController.text),
        );

        if (_isEditing) {
          await _placeCrudService.updatePlace(place);
        } else {
          await _placeCrudService.addPlace(place);
        }

        // Reset form after successful save
        if (!_isEditing) {
          _resetForm();
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Place updated successfully!'
                : 'Place added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error ${_isEditing ? 'updating' : 'adding'} place: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DertamSpacings.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: DertamSpacings.m),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: DertamSpacings.m),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: DertamSpacings.s),
                        Text(
                          _isEditing ? 'Edit Place' : 'Add New Place',
                          style: DertamTextStyles.heading,
                        ),
                      ],
                    ),
                    SizedBox(height: DertamSpacings.m),
                    InputTextField(
                        label: 'Place Name', controller: _nameController),
                    InputTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        maxLines: 3),
                    InputTextField(
                        label: 'Entrance Fees', controller: _feesController),
                    InputTextField(
                        label: 'Opening Hours', controller: _hoursController),
                    InputTextField(
                        label: 'Image URL', controller: _imageURLController),
                    Row(
                      children: [
                        Expanded(
                          child: InputTextField(
                              label: 'Latitude',
                              controller: _latitudeController),
                        ),
                        SizedBox(width: DertamSpacings.m),
                        Expanded(
                          child: InputTextField(
                              label: 'Longitude',
                              controller: _longitudeController),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: InputTextField(
                                label: 'Category',
                                controller: _categoryController)),
                        SizedBox(width: DertamSpacings.m),
                        Expanded(
                          child: InputTextField(
                              label: 'Average Rating',
                              controller: _ratingController),
                        ),
                      ],
                    ),
                    SizedBox(height: DertamSpacings.m),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: DertamButton(
                                onPressed: _savePlace,
                                text: _isEditing ? 'Update' : 'Save',
                                buttonType: ButtonType.primary,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: DertamButton(
                                onPressed: _resetForm,
                                text: 'Reset',
                                buttonType: ButtonType.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  void _resetForm() {
    if (_isEditing && widget.place != null) {
      // Reset to original values if editing
      _nameController.text = widget.place!.name;
      _descriptionController.text = widget.place!.description;
      _imageURLController.text = widget.place!.imageURL;
      _categoryController.text = widget.place!.category;
      _ratingController.text = widget.place!.averageRating?.toString() ?? '';
      _feesController.text = widget.place!.entranceFees?.toString() ?? '';
      _hoursController.text = widget.place!.openingHours ?? '';
      _latitudeController.text = widget.place!.location.latitude.toString();
      _longitudeController.text = widget.place!.location.longitude.toString();
    } else {
      // Clear all fields if adding new
      _nameController.clear();
      _descriptionController.clear();
      _feesController.clear();
      _hoursController.clear();
      _imageURLController.clear();
      _categoryController.clear();
      _ratingController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
    }
    setState(() {
      selectedCategory = null;
    });
  }
}

class InputTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int? maxLines;
  const InputTextField(
      {super.key,
      required this.label,
      required this.controller,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: DertamTextStyles.body.copyWith(
              color: DertamColors.textNormal,
            ),
            filled: true,
            fillColor: DertamColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: DertamColors.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
