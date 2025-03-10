import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/admin/screen/main_screen.dart';
import 'package:tourism_app/admin/service/place_crud_service.dart';
import 'package:tourism_app/admin/widget/header.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/theme/theme.dart';

class DestinationScreen extends StatefulWidget {
  final ScreenType screenType;
  const DestinationScreen({super.key, required this.screenType});

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
  final PlaceCrudService _placeCrudService = PlaceCrudService();

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
              Header(
                currentScreen: widget.screenType,
              ),
              SizedBox(height: DertamSpacings.m),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputTextField(
                        label: 'Place Name', controller: nameController),
                    InputTextField(
                        label: 'Description',
                        controller: descriptionController,
                        maxLines: 3),
                    DropDownMenu(
                      label: 'Category',
                      items: PlaceCategory.values,
                      onChanged: (value) =>
                          setState(() => selectedCategory = value),
                      value: selectedCategory,
                    ),
                    InputTextField(
                        label: 'Entrance Fees',
                        controller: entranceFeesController),
                    InputTextField(
                        label: 'Opening Hours',
                        controller: openingHoursController),
                    InputTextField(
                        label: 'Image URL', controller: imageUrlController),
                    InputTextField(
                        label: 'Location', controller: locationController),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: DertamColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: isEnabled,
                                activeColor: DertamColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) =>
                                    setState(() => isEnabled = value ?? false),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Enabled',
                              style: DertamTextStyles.body
                                  .copyWith(color: DertamColors.textNormal),
                            ),
                          ],
                        ),
                      ),
                    ),
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
        name: nameController.text,
        description: descriptionController.text,
        location: GeoPoint(0, 0),
        imageURL: imageUrlController.text,
        category: selectedCategory?.name ?? PlaceCategory.historical_place.name,
        entranceFees: double.tryParse(entranceFeesController.text) ?? 0,
        openingHours: openingHoursController.text,
        averageRating: 0.0,
      );
      await _placeCrudService.addPlace(newPlace);

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
        ),
      ),
    );
  }
}

class DropDownMenu extends StatelessWidget {
  final String label;
  final List<PlaceCategory> items;
  final void Function(PlaceCategory?) onChanged;
  final PlaceCategory? value;

  const DropDownMenu({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<PlaceCategory>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: DertamTextStyles.body.copyWith(
            color: DertamColors.textNormal,
          ),
          filled: true,
          fillColor: DertamColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: DertamColors.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: DertamColors.iconNormal),
        isExpanded: true,
        style: DertamTextStyles.body.copyWith(
          color: DertamColors.textNormal,
        ),

        // Customize dropdown items
        items: items.map((PlaceCategory category) {
          return DropdownMenuItem<PlaceCategory>(
            value: category,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatCategoryName(category.name),
                      style: DertamTextStyles.body.copyWith(
                        color: DertamColors.textNormal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((PlaceCategory category) {
            return Row(
              children: [
                SizedBox(width: 12),
                Text(
                  _formatCategoryName(category.name),
                  style: DertamTextStyles.body.copyWith(
                    color: DertamColors.textNormal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList();
        },

        onChanged: onChanged,
        menuMaxHeight: 300,
      ),
    );
  }

  String _formatCategoryName(String name) {
    return name
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
