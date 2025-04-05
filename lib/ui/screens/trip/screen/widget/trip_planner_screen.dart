import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/screens/trip/screen/trip_detail_screen.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';

class TripPlannerScreen extends StatefulWidget {
  final List<String?> selectedDestinations;
  final DateTime startDate;
  final DateTime? returnDate;
  final String tripName;
  final String? tripId;

  const TripPlannerScreen({
    super.key,
    required this.selectedDestinations,
    required this.startDate,
    this.returnDate,
    required this.tripName,
    this.tripId,
  });

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
        context.read<TripProvider>().selectTrip(widget.tripId!);
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
              color: DertamColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new, color: DertamColors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.tripName,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: DertamColors.black,
                          
                        ),
                      
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Itinerary page takes up the rest of the space
            Expanded(
              child: widget.tripId != null
                  ? StreamBuilder<List<Trip>>(
                      stream: Provider.of<TripProvider>(context, listen: false)
                          .getTripsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final trips = snapshot.data ?? [];
                        trips.firstWhere(
                          (t) => t.id == widget.tripId,
                          orElse: () => Trip(
                            id: widget.tripId!,
                            userId: '',
                            tripName: widget.tripName,
                            startDate: widget.startDate,
                            endDate: widget.returnDate ??
                                widget.startDate.add(const Duration(days: 7)),
                            days: [],
                          ),
                        );

                        return ItineraryPage(tripId: widget.tripId);
                      },
                    )
                  : ItineraryPage(tripId: widget.tripId),
            ),
          ],
        ),
      ),
    );
  }
}
