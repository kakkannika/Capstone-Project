// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
<<<<<<< HEAD:lib/presentation/screens/trip/screen/trips_screen.dart
import 'package:tourism_app/presentation/screens/trip/screen/edit_trip_screen.dart';
import 'package:tourism_app/presentation/screens/trip/screen/start_plan_screen.dart';
import 'package:tourism_app/presentation/screens/trip/screen/trip_planner_screen.dart';
import 'package:tourism_app/presentation/widgets/navigationBar.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/theme/theme.dart';

//this screen is used to show the trips of the user. It has two tabs: upcoming and history. The user can add a new trip by clicking on the floating action button.
class TripsScreen extends StatefulWidget {
=======
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/screens/trip/screen/edit_trip_screen.dart';
import 'package:tourism_app/ui/screens/trip/screen/start_plan_screen.dart';
import 'package:tourism_app/ui/screens/trip/screen/widget/trip_planner_screen.dart';
import 'package:tourism_app/ui/widgets/navigationBar.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';

class TripsScreen extends StatelessWidget {
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/trips_screen.dart
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'My Trips',
            style: TextStyle(
              color: DertamColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: DertamColors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: const Color(0xFF0D3E4C),
            unselectedLabelColor: DertamColors.grey,
            indicatorColor: Color(0xFF0D3E4C),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TripsBody(),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 20, right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3), // Shadow color
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(2, 4), // Changes position of shadow
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PlanNewTripScreen()),
              );
            },
            backgroundColor: DertamColors.primary,
            shape: CircleBorder(),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        bottomNavigationBar: const Navigationbar(currentIndex: 1),
      ),
    );
  }
}

class TripsBody extends StatelessWidget {
  const TripsBody({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD:lib/presentation/screens/trip/screen/trips_screen.dart
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
=======
    return StreamBuilder<List<Trip>>(
      stream: Provider.of<TripProvider>(context, listen: true).getTripsStream(),
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
          children: [
            // Upcoming Trips Tab
            upcomingTrips.isEmpty
                ? const EmptyState(
                    title: 'No upcoming trips',
                    subtitle: 'Plan a new trip to get started!',
                    isPastTrips: false,
                  )
                : TripsList(trips: upcomingTrips),
            // Past Trips Tab
            pastTrips.isEmpty
                ? const EmptyState(
                    title: 'No past trips',
                    subtitle: 'Your completed trips will appear here.',
                    isPastTrips: true,
                  )
                : TripsList(trips: pastTrips),
          ],
        );
      },
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/trips_screen.dart
    );
  }
}

<<<<<<< HEAD:lib/presentation/screens/trip/screen/trips_screen.dart
  Widget _buildEmptyState(String title, String subtitle,{bool showButton = true}) {
=======
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  // Add a new parameter to determine if it's the past trips tab
  final bool isPastTrips;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.isPastTrips = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/trips_screen.dart
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
<<<<<<< HEAD:lib/presentation/screens/trip/screen/trips_screen.dart
            'lib/assets/images/empty.png',
=======
            'assets/images/empty.png',
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/trips_screen.dart
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
<<<<<<< HEAD:lib/presentation/screens/trip/screen/trips_screen.dart
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
=======
          const SizedBox(height: 24),
          // Only show the button if it's not the past trips tab
          if (!isPastTrips)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PlanNewTripScreen()),
                );
              },
              
              child: Text(
                'Plan a Trip',
                style: TextStyle(color: DertamColors.primary,fontSize: 25),
              ),
            ),
        ],
      ),
    );
  }
}

class TripsList extends StatelessWidget {
  final List<Trip> trips;

  const TripsList({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return TripCard(
          trip: trip,
          onTap: (trip) => _navigateToTripDetails(context, trip),
          onLongPress: (trip) => _showTripOptions(context, trip),
        );
      },
    );
  }

  void _navigateToTripDetails(BuildContext context, Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPlannerScreen(
          tripId: trip.id,
          tripName: trip.tripName,
          startDate: trip.startDate,
          returnDate: trip.endDate,
          selectedDestinations: const [],
        ),
      ),
    );
  }

  void _showTripOptions(BuildContext context, Trip trip) {
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
                  Navigator.pop(context);
                  _navigateToEditTrip(context, trip);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: DertamColors.red),
                title: Text('Delete Trip',
                    style: TextStyle(color: DertamColors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, trip);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEditTrip(BuildContext context, Trip trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripScreen(trip: trip),
      ),
    );

    if (result == true) {
      Provider.of<TripProvider>(context, listen: false).startListeningToTrips();
    }
  }

  void _showDeleteConfirmation(BuildContext context, Trip trip) {
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
              _deleteTrip(context, trip);
            },
            style: TextButton.styleFrom(foregroundColor: DertamColors.red),
            child: const Text('Delete'),
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/trips_screen.dart
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip(BuildContext context, Trip trip) async {
    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      await tripProvider.deleteTrip(trip.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Trip deleted successfully'),
          backgroundColor: DertamColors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting trip: $e'),
          backgroundColor: DertamColors.red,
        ),
      );
    }
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;
  final Function(Trip) onTap;
  final Function(Trip) onLongPress;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: () => onTap(trip),
        onLongPress: () => onLongPress(trip),
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
                      : const AssetImage('assets/place_images/AngKor_wat.jpg')
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
<<<<<<< HEAD:lib/presentation/screens/trip/screen/trips_screen.dart
        return DertamColors.primary;
=======
        return DertamColors.green;
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/trips_screen.dart
      case 'completed':
        return DertamColors.green;
      default:
        return DertamColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
<<<<<<< HEAD:lib/presentation/screens/trip/screen/trips_screen.dart

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
=======
>>>>>>> 9ac13a8b16be95e2a2cd5381761493e898ac72d3:lib/ui/screens/trip/trips_screen.dart
}
