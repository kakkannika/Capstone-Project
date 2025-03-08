import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/core/theme.dart';
import 'package:tourism_app/providers/auth/auth_provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/models/trip_model/trip.dart';
import 'package:tourism_app/views/profile/settings_screen.dart';
import 'package:tourism_app/views/profile/widget/option_tile.dart';
import 'package:tourism_app/views/profile/widget/profile.dart';
import 'package:tourism_app/views/profile/widget/trips_item.dart';
import 'package:tourism_app/views/profile/widget/trips_list.dart';
import 'package:tourism_app/views/trips_screen/trip_planner_screen.dart';
import 'package:tourism_app/views/widgets/dertam_dialog.dart';
import 'package:tourism_app/views/widgets/dertam_dialog_botton.dart';
import 'package:tourism_app/views/widgets/dertam_tab_bar.dart';
import 'package:tourism_app/views/wrapper.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserTrips();
  }

  Future<void> _loadUserTrips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch trips for the current user
      await Provider.of<TripViewModel>(context, listen: false).fetchTripsForCurrentUser();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading trips: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreOptions(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Consumer<AuthViewModel>(builder: (context, authViewModel, child) {
                    final user=authViewModel.appUser;
                    return Profile(
                      name: '${user?.displayName ?? user?.uid ?? 'Kannika'}',
                      username: user?.uid?? 'kannika',
                      imagePath: 'lib/assets/images/profile.png',
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: DertamTabs(
                tabs: const ['Trips', 'History'],
                children: [
                  // Trips Tab
                  Consumer<TripViewModel>(
                    builder: (context, tripViewModel, child) {
                      if (_isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (tripViewModel.error != null) {
                        return Center(child: Text('Error: ${tripViewModel.error}'));
                      }
                      
                      final upcomingTrips = tripViewModel.trips.where((trip) {
                        // Filter for upcoming or in-progress trips
                        return trip.endDate.isAfter(DateTime.now());
                      }).toList();
                      
                      if (upcomingTrips.isEmpty) {
                        return const Center(
                          child: Text('No upcoming trips. Plan a new trip!'),
                        );
                      }
                      
                      return TripList(
                        title: 'Trips',
                        trips: upcomingTrips.map((trip) {
                          final numberOfPlaces = trip.days.fold<int>(
                            0, 
                            (sum, day) => sum + day.places.length
                          );
                          
                          final status = trip.startDate.isAfter(DateTime.now()) 
                              ? 'Planning' 
                              : 'Ongoing';
                          
                          return TripItem(
                            title: trip.tripName,
                            places: '$numberOfPlaces ${numberOfPlaces == 1 ? 'place' : 'places'}',
                            status: status,
                            imagePath: trip.days.isNotEmpty && trip.days.first.places.isNotEmpty && 
                                      trip.days.first.places.first.imageUrls.isNotEmpty
                                ? trip.days.first.places.first.imageUrls.first
                                : 'lib/assets/place_images/AngKor_wat.jpg',
                            onTap: () => _goToTripDetails(trip),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  
                  // History Tab
                  Consumer<TripViewModel>(
                    builder: (context, tripViewModel, child) {
                      if (_isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (tripViewModel.error != null) {
                        return Center(child: Text('Error: ${tripViewModel.error}'));
                      }
                      
                      final completedTrips = tripViewModel.trips.where((trip) {
                        // Filter for completed trips
                        return trip.endDate.isBefore(DateTime.now());
                      }).toList();
                      
                      if (completedTrips.isEmpty) {
                        return const Center(
                          child: Text('No completed trips yet.'),
                        );
                      }
                      
                      return TripList(
                        title: 'History',
                        trips: completedTrips.map((trip) {
                          final numberOfPlaces = trip.days.fold<int>(
                            0, 
                            (sum, day) => sum + day.places.length
                          );
                          
                          return TripItem(
                            title: trip.tripName,
                            places: '$numberOfPlaces ${numberOfPlaces == 1 ? 'place' : 'places'}',
                            status: 'Completed',
                            imagePath: trip.days.isNotEmpty && trip.days.first.places.isNotEmpty && 
                                      trip.days.first.places.first.imageUrls.isNotEmpty
                                ? trip.days.first.places.first.imageUrls.first
                                : 'lib/assets/place_images/AngKor.jpg',
                            onTap: () => _goToTripDetails(trip),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //to show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DertamDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        actions: [
          DertamDialogButton(
            onPressed: () => Navigator.pop(context),
            text: 'Cancel',
            dertamColor: DertamColors.primary,
          ),
          DertamDialogButton(
            text: 'Logout',
            onPressed: () async {
              try {
                final auth = Provider.of<AuthViewModel>(context, listen: false);
                await auth.signOut();

                // Navigate to the Wrapper which will handle redirecting to login
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Wrapper()),
                    (route) => false);
              } catch (e) {
                // Handle any sign-out errors
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error signing out: ${e.toString()}")),
                );
              }
            },
            dertamColor: DertamColors.red,
            hasBackground: true,
          ),
        ],
      ),
    );
  }

  //to show the option to choose such as ,setting edit profile or view profile reset password,logout
  void _showMoreOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DertamDialog(
        title: 'More Options',
        contentWidgets: [
          OptionTile(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          OptionTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          OptionTile(
            icon: Icons.lock_outline,
            title: 'Reset Password',
            onTap: () {
              // Navigator.pop(context);
              // _resetPassword(context);
            },
          ),
          OptionTile(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () => _showLogoutConfirmation(context),
          )
        ],
        actions: const [],
      ),
    );
  }

  void _goToTripDetails(Trip trip) {
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
}
