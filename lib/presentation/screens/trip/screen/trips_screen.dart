// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/presentation/screens/trip/screen/edit_trip_screen.dart';
import 'package:tourism_app/presentation/screens/trip/screen/start_plan_screen.dart';
import 'package:tourism_app/presentation/screens/trip/screen/trip_planner_screen.dart';
import 'package:tourism_app/presentation/widgets/navigationBar.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/theme/theme.dart';

//this screen is used to show the trips of the user. It has two tabs: upcoming and history. The user can add a new trip by clicking on the floating action button.
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Start listening to trips stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).startListeningToTrips();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Stop listening to trips stream
    Provider.of<TripProvider>(context, listen: false).stopListeningToTrips();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Trips',
          style: TextStyle(
            color: DertamColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: DertamColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: DertamColors.primary,
          unselectedLabelColor: DertamColors.grey,
          indicatorColor: DertamColors.primary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: StreamBuilder<List<Trip>>(
        stream:
            Provider.of<TripProvider>(context, listen: true).getTripsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final trips = snapshot.data ?? [];

          final upcomingTrips = trips.where((trip) {
            return trip.endDate.isAfter(DateTime.now());
          }).toList();

          final pastTrips = trips.where((trip) {
            return trip.endDate.isBefore(DateTime.now());
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming Trips Tab
              upcomingTrips.isEmpty
                  ? _buildEmptyState(
                      'No upcoming trips', 'Ready to go? Plan your next trip now!',showButton: true)
                  : _buildTripsList(upcomingTrips),
              // Past Trips Tab
              pastTrips.isEmpty
                  ? _buildEmptyState(
                      'No completed trips yet!', 'Once you finish a trip, you’ll see it here',showButton: false)
                  : _buildTripsList(pastTrips),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlanNewTripScreen()),
          );
        },
        
        backgroundColor: DertamColors.white,
        shape: const CircleBorder(),
        child: Icon(Icons.add,
            color: DertamColors.primary, size: 30),
      ),
      bottomNavigationBar: const Navigationbar(currentIndex: 1),
    );
  }

  Widget _buildEmptyState(String title, String subtitle,{bool showButton = true}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/images/empty.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DertamSpacings.s-4),
          Text(
            subtitle,
            style: TextStyle(
              color: DertamColors.grey,
            ),
          ),
          //SizedBox(height: DertamSpacings.s-4),
          if (showButton)
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlanNewTripScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: DertamColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Start Planning'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<Trip> trips) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(Trip trip) {
    final numberOfPlaces =
        trip.days.fold<int>(0, (sum, day) => sum + day.places.length);

    final status = trip.startDate.isAfter(DateTime.now())
        ? 'Planning'
        : trip.endDate.isBefore(DateTime.now())
            ? 'Completed'
            : 'Ongoing';

    final daysLeft = trip.startDate.difference(DateTime.now()).inDays;
    final String timeInfo = status == 'Planning'
        ? 'Starts in $daysLeft days'
        : status == 'Completed'
            ? 'Ended ${DateTime.now().difference(trip.endDate).inDays} days ago'
            : '${trip.endDate.difference(DateTime.now()).inDays} days left';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToTripDetails(trip),
        onLongPress: () => _showTripOptions(trip),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: trip.days.isNotEmpty &&
                          trip.days.first.places.isNotEmpty &&
                          trip.days.first.places.first.imageURL.isNotEmpty
                      ? NetworkImage(trip.days.first.places.first.imageURL)
                      : const AssetImage(
                              'lib/assets/place_images/AngKor_wat.jpg')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: DertamColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Trip Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.tripName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: DertamColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                        style: TextStyle(color: DertamColors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place, size: 16, color: DertamColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$numberOfPlaces ${numberOfPlaces == 1 ? 'place' : 'places'} to visit',
                        style: TextStyle(color: DertamColors.grey),
                      ),
                      const Spacer(),
                      Text(
                        timeInfo,
                        style: TextStyle(
                          color: DertamColors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return DertamColors.orange;
      case 'ongoing':
        return DertamColors.primary;
      case 'completed':
        return DertamColors.green;
      default:
        return DertamColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToTripDetails(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPlannerScreen(
          tripId: trip.id,
          tripName: trip.tripName,
          startDate: trip.startDate,
          returnDate: trip.endDate,
          selectedDestinations: const [], // Not needed when viewing existing trip
        ),
      ),
    );
  }

  void _showTripOptions(Trip trip) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF0D3E4C)),
                title: const Text('Edit Trip'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _navigateToEditTrip(trip);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: DertamColors.red),
                title: Text('Delete Trip',
                    style: TextStyle(color: DertamColors.red)),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _showDeleteConfirmation(trip);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEditTrip(Trip trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripScreen(trip: trip),
      ),
    );

    // If the trip was updated successfully, refresh the trips list
    if (result == true) {
      Provider.of<TripProvider>(context, listen: false).startListeningToTrips();
    }
  }

  void _showDeleteConfirmation(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
            'Are you sure you want to delete "${trip.tripName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrip(trip);
            },
            style: TextButton.styleFrom(foregroundColor: DertamColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip(Trip trip) async {
    setState(() {});

    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.deleteTrip(trip.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip deleted successfully'),
            backgroundColor: DertamColors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}
