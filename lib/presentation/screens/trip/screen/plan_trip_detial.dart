// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/models/trips/trip_days.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/presentation/screens/budget/budget_screen.dart';
import 'package:tourism_app/presentation/screens/budget/expend_screen.dart';
import 'package:tourism_app/presentation/screens/trip/screen/search_place_screen.dart';
import 'package:tourism_app/providers/budget_provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tourism_app/theme/theme.dart';

//this is the itinerary page that shows the details of a trip, including the selected day and places to visit.
class ItineraryPage extends StatefulWidget {
  final String? tripId;

  const ItineraryPage({
    super.key,
    this.tripId,
  });

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  int _selectedDayIndex = 0; // Track the selected day tab
  Day? _selectedDay; // Track the currently selected day
  bool _isLoadingBudget = false;

  @override
  void initState() {
    super.initState();
    // If tripId is provided, load the trip data
    if (widget.tripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TripProvider>().selectTrip(widget.tripId!);
      });
    }
  }

  // Navigate to budget screen based on whether the trip has a budget or not
  void _navigateToBudgetScreen(Trip trip) async {
    setState(() {
      _isLoadingBudget = true;
    });

    try {
      Provider.of<BudgetProvider>(context, listen: false);

      // Check if the trip has a budget
      if (trip.hasBudget) {
        // Navigate to expense screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseScreen(
              budgetId: trip.budgetId!,
              tripId: trip.id,
            ),
          ),
        );
      } else {
        // Navigate to select currency screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetScreen(
              tripId: trip.id,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor:  DertamColors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingBudget = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tripId == null) {
      return const Center(child: Text('No trip selected'));
    }

    return StreamBuilder<List<Trip>>(
        stream:
            Provider.of<TripProvider>(context, listen: false).getTripsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final trips = snapshot.data ?? [];
          final trip = trips.firstWhere(
            (t) => t.id == widget.tripId,
            orElse: () => Trip(
              id: widget.tripId!,
              userId: '',
              tripName: 'Trip not found',
              startDate: DateTime.now(),
              endDate: DateTime.now().add(const Duration(days: 1)),
              days: [],
            ),
          );

          return WillPopScope(
            onWillPop: () async => false, // Disable back button
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: trip.days.isEmpty
                  ? const Center(child: Text('No days in this trip'))
                  : _buildItineraryContent(trip),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: _isLoadingBudget
                        ? null
                        : () => _navigateToBudgetScreen(trip),
                    backgroundColor: DertamColors.white,
                    heroTag: 'Budget',
                    shape: const CircleBorder(),
                    child: _isLoadingBudget
                        ? CircularProgressIndicator(color: DertamColors.primary)
                        : Icon(Icons.account_balance_wallet, color: DertamColors.primary),
                        
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: () {
                      if (trip.days.isNotEmpty &&
                          _selectedDayIndex < trip.days.length) {
                        _navigateToSearchPlace(trip.days[_selectedDayIndex]);
                      }
                    },
                    shape: const CircleBorder(),
                    backgroundColor: DertamColors.primary,
                    heroTag: 'add',
                    child: Icon(Icons.add, color: DertamColors.white),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildItineraryContent(Trip trip) {
    // Ensure _selectedDayIndex is within bounds
    if (_selectedDayIndex >= trip.days.length) {
      _selectedDayIndex = 0;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Calendar Icon
            SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.edit_calendar_rounded,
                  color: DertamColors.primary, size: 20),
            ),

            // Date Pills
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    ...List.generate(trip.days.length, (index) {
                      final date = trip.startDate.add(Duration(days: index));
                      final dateStr = DateFormat('EEE d/M').format(date);

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          child: _buildDatePill(
                              dateStr, index == _selectedDayIndex),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Selected Day Content
        if (_selectedDayIndex < trip.days.length)
          _buildDayContent(trip.days[_selectedDayIndex]),
      ],
    );
  }

  void _navigateToSearchPlace(Day day) async {
    final tripProvider = context.read<TripProvider>();
    if (tripProvider.selectedTrip == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPlaceScreen(
          tripId: tripProvider.selectedTrip!.id,
          dayId: day.id,
          onPlaceSelected: (Place place) {
            // This callback will be called when a place is selected
            // The UI will update automatically through the StreamBuilder
          },
        ),
      ),
    );

    // If we got a result back, the place was added successfully
    // The UI will update automatically through the StreamBuilder
  }

  Widget _buildDayContent(Day day) {
    final tripProvider = context.read<TripProvider>();
    final trip = tripProvider.selectedTrip!;
    final date = trip.startDate.add(Duration(days: day.dayNumber - 1));
    final dateStr = DateFormat('EEE d/M').format(date);

    // Store the selected day for use in the delete operation
    _selectedDay = day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Row(
          children: [
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DertamColors.primary,
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),

        const SizedBox(height: 16),

        // Places for this day - Using StreamBuilder for real-time updates
        StreamBuilder<List<Place>>(
          stream: tripProvider.getPlacesForDayStream(
            tripId: trip.id,
            dayId: day.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            final places = snapshot.data ?? [];

            if (places.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No places added to this day yet')),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildPlaceCard(place),
                );
              },
            );
          },
        ),

        // Add a place button
        _buildAddPlaceButton(day),

        const SizedBox(height: 24),

        // Recommended Places
        _buildRecommendedPlacesSection(),
      ],
    );
  }

  Widget _buildDatePill(String date, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? DertamColors.blueSky
            : DertamColors.backgroundAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        date,
        style: TextStyle(
          color: isSelected ? DertamColors.primary : DertamColors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    // Get the current day to use for delete operation
    final currentDay = _selectedDay;

    return Slidable(
      // Enable sliding from left to right (endActionPane for right-to-left)
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _deletePlaceFromTrip(place.id, currentDay!.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFF0D3E4C), size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    place.description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Image
            if (place.imageURL.isNotEmpty)
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(place.imageURL),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) =>
                        const AssetImage('assets/images/placeholder.jpg'),
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPlaceButton(Day day) {
    return GestureDetector(
      onTap: () => _navigateToSearchPlace(day),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Add a place',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.add, color: DertamColors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedPlacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended places',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        // Recommended places content would go here
      ],
    );
  }

  Future<void> _deletePlaceFromTrip(String placeId, String dayId) async {
    try {
      final tripProvider = context.read<TripProvider>();
      final trip = tripProvider.selectedTrip;

      if (trip == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No trip selected'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removing place from trip...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Just call the method and let the stream update the UI
      await tripProvider.removePlaceFromDay(
        dayId: dayId,
        placeId: placeId,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Place removed from trip'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing place: $e'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}