import 'package:flutter/material.dart';

class HeaderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          "lib/assets/trip_plan_images/indepenence_monument.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}