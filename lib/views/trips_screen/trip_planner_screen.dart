import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/views/trips_screen/plan_trip_detail.dart';

class TripPlannerScreen extends StatefulWidget {
  final List<String?> selectedDestinations;
  final DateTime startDate;
  final DateTime? returnDate;
  final String tripName;
  final String? tripId;
  
  const TripPlannerScreen({
    Key? key,
    required this.selectedDestinations,
    required this.startDate,
    this.returnDate,
    required this.tripName,
    this.tripId,
  }) : super(key: key);
  
  @override
  _TripPlannerScreenState createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  @override
  void initState() {
    super.initState();
    // If coming from profile screen, ensure trip is loaded
    if (widget.tripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TripViewModel>().selectTrip(widget.tripId!);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Simple app bar with back button and trip name
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.tripName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Itinerary page takes up the rest of the space
            Expanded(
              child: ItineraryPage(tripId: widget.tripId),
            ),
          ],
        ),
      ),
    );
  }
}