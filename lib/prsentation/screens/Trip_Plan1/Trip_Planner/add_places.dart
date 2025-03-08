 import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/Trip_Plan1/Start_Plan/search_screen.dart';
import 'package:tourism_app/prsentation/screens/Trip_Plan1/Trip_Planner/DetailedSearchScreen.dart';

class AddPlaceWidget extends StatelessWidget {
  final VoidCallback onAddPlace;
  final VoidCallback onNotes;
  final VoidCallback onList;

  const AddPlaceWidget({
    Key? key,
    required this.onAddPlace,
    required this.onNotes,
    required this.onList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.place, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => DetailedSearchScreen()));
              },
              child: const Text(
                'Add a place',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.note, color: Colors.grey),
            onPressed: onNotes,
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Colors.grey),
            onPressed: onList,
          ),
        ],
      ),
    );
  }
}