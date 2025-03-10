import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/models/place/place_category.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/main_screen.dart';
import 'package:tourism_app/presentation/screens/dashboard/widgets/header.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/providers/placecrud.dart';
import 'package:tourism_app/theme/theme.dart';

class DestinationScreen extends StatefulWidget {
  final ScreenType screenType;
  const DestinationScreen({super.key, required this.screenType});

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
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(DertamSpacings.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                currentScreen: widget.screenType,
              ),
              SizedBox(height: DertamSpacings.m),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                text: 'Save',
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

  void _savePlace() async {
    if (_formKey.currentState!.validate()) {
      final newPlace = Place(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        location: GeoPoint(0, 0),
        imageURL: _imageURLController.text,
        category: _categoryController.text,
        entranceFees: double.tryParse(_feesController.text),
        openingHours: _hoursController.text,
        averageRating: 0.0,
      );
      await _placeCrudService.addPlace(newPlace);
    }
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _feesController.clear();
    _hoursController.clear();
    _imageURLController.clear();
    _categoryController.clear();
    _ratingController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
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
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: DertamColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

// class DropDownMenu extends StatelessWidget {
//   final String label;
//   final List<PlaceCategory> items;
//   final void Function(PlaceCategory?) onChanged;
//   final PlaceCategory? value;

//   const DropDownMenu({
//     super.key,
//     required this.label,
//     required this.items,
//     required this.onChanged,
//     this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: SizedBox(
//         width: 300, // Adjust width as needed
//         child: DropdownButtonFormField<PlaceCategory>(
//           value: value,
//           decoration: InputDecoration(
//             labelText: label,
//             labelStyle: DertamTextStyles.body.copyWith(
//               color: DertamColors.textNormal,
//             ),
//             filled: true,
//             fillColor: DertamColors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide(color: DertamColors.primary, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           ),
//           dropdownColor: Colors.white,
//           style: DertamTextStyles.body.copyWith(
//             color: DertamColors.textNormal,
//           ),
//           items: items.map((PlaceCategory category) {
//             return DropdownMenuItem<PlaceCategory>(
//               value: category,
//               child: Text(
//                 _formatCategoryName(category.name),
//                 style: DertamTextStyles.body.copyWith(
//                   color: DertamColors.textNormal,
//                 ),
//               ),
//             );
//           }).toList(),
//           selectedItemBuilder: (BuildContext context) {
//             return items.map<Widget>((PlaceCategory category) {
//               return Text(
//                 _formatCategoryName(category.name),
//                 style: DertamTextStyles.body.copyWith(
//                   color: DertamColors.textNormal,
//                   fontWeight: FontWeight.w500,
//                 ),
//               );
//             }).toList();
//           },
//           onChanged: onChanged,
//           menuMaxHeight: 300,
//         ),
//       ),
//     );
//   }

//   String _formatCategoryName(String name) {
//     return name
//         .split('_')
//         .map((word) =>
//             word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
//         .join(' ');
//   }
// }
