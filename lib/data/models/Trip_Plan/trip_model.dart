// models/trip_model.dart
import 'package:flutter/material.dart';

class TripModel {
  final List<String?> selectedDestinations;
  final DateTime startDate;
  final DateTime? returnDate;

  TripModel({
    required this.selectedDestinations,
    required this.startDate,
    this.returnDate,
  });

  String get primaryDestination {
    for (String? destination in selectedDestinations) {
      if (destination != null && destination.isNotEmpty) {
        return destination;
      }
    }
    return 'Unknown';
  }

  int get tripDuration {
    if (returnDate == null) return 2;
    return returnDate!.difference(startDate).inDays;
  }
}