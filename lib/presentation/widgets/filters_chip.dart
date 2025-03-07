import 'package:flutter/material.dart';
import 'package:tourism_app/theme/theme.dart';

class FiltersChip extends StatefulWidget {
  final String lable;
  const FiltersChip({super.key, required this.lable});

  @override
  State<FiltersChip> createState() => _FiltersChipState();
}

class _FiltersChipState extends State<FiltersChip> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(widget.lable),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            isSelected = !isSelected;
          });
        },
        backgroundColor: isSelected ? DertamColors.primary : Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
