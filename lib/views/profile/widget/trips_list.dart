import 'package:flutter/material.dart';
import 'package:tourism_app/views/profile/widget/trips_item.dart';

class TripList extends StatelessWidget {
  final String title;
  final List<TripItem> trips;

  const TripList({super.key, required this.title, required this.trips});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: trips,
    );
  }
}