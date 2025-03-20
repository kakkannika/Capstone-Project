import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/trips/trips.dart';
import 'package:tourism_app/presentation/screens/auth/reset_password_screen.dart';
import 'package:tourism_app/presentation/screens/trip/screen/trip_planner_screen.dart';
import 'package:tourism_app/providers/auth_provider.dart';
import 'package:tourism_app/presentation/widgets/dertam_tap.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'widget/trips_list.dart';
import 'package:tourism_app/presentation/widgets/dertam_dialog_button.dart';
import 'widget/trips_item.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/presentation/widgets/dertam_dialog.dart';
import 'widget/option_tile.dart';
import 'edit_profile_screen.dart';
import 'setting_screen.dart';
// Import AuthServiceProvider

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Access the auth provider to get current user
    final authProvider = Provider.of<AuthServiceProvider>(context);

    // final tripForCurrentUser =
    //     Provider.of<TripViewModel>(context, listen: false);

    final currentUser = authProvider.currentUser;

    // Get user display name or email
    final userName = currentUser?.displayName ?? 'User';
    final userEmail = currentUser?.email ?? 'No email';

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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: currentUser?.photoUrl != null
                        ? NetworkImage(currentUser!.photoUrl!) as ImageProvider
                        : const AssetImage('lib/assets/images/avatar.jpg'),
                  ),
                  const SizedBox(height: DertamSpacings.m),
                  Text(userName, style: DertamTextStyles.heading),
                  const SizedBox(height: DertamSpacings.s),
                  Text(userEmail),
                  const SizedBox(height: DertamSpacings.m),
                ],
              ),
            ),
            Expanded(
              child: DertamTabs(
                tabs: const ['Trips', 'History'],
                children: [
                  // Trip tap
                  Consumer<TripProvider>(
                    builder: (context, tripProvider, child) {
                      if (tripProvider.error != null) {
                        return Center(
                            child: Text('Error: ${tripProvider.error}'));
                      }
                      final upcommingTrips = tripProvider.trips
                          .where((trip) => trip.endDate.isAfter(DateTime.now()))
                          .toList();

                      if (upcommingTrips.isEmpty) {
                        return Center(
                          child: Text(
                              'No upcomming trips. Please plan your trips with dertam'),
                        );
                      }
                      return TripList(
                        title: 'Trips',
                        trips: upcommingTrips.map((trip) {
                          final numberOfPlaces = trip.days.fold<int>(
                              0, (sum, day) => sum + day.places.length);

                          final status = trip.startDate.isAfter(DateTime.now())
                              ? 'Planning'
                              : 'Ongoing';

                          return TripItem(
                            title: trip.tripName,
                            places:
                                '$numberOfPlaces ${numberOfPlaces == 1 ? 'place' : 'places'}',
                            status: status,
                            imagePath: (trip.days.isNotEmpty &&
                                    trip.days.first.places.isNotEmpty &&
                                    trip.days.first.places.first.imageURL
                                        .isNotEmpty)
                                ? trip.days.first.places.first.imageURL
                                : 'lib/assets/place_images/AngKor_wat.jpg',
                            onTap: () => _goToTripDetails(trip),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  // History Tap
                  Consumer<TripProvider>(
                    builder: (context, tripProvider, child) {
                      if (tripProvider.error != null) {
                        return Center(
                            child: Text('Error: ${tripProvider.error}'));
                      }
                      final completeTrips = tripProvider.trips
                          .where(
                              (trip) => trip.endDate.isBefore(DateTime.now()))
                          .toList();
                      if (completeTrips.isEmpty) {
                        return Center(
                          child: Text('No complete trips yet'),
                        );
                      }
                      return TripList(
                        title: 'History',
                        trips: completeTrips.map((trip) {
                          final numberOfPlaces = trip.days.fold<int>(
                              0, (sum, day) => sum + day.places.length);
                          return TripItem(
                              title: trip.tripName,
                              places:
                                  ' $numberOfPlaces ${numberOfPlaces == 1 ? 'place' : 'places'}',
                              status: 'Completed',
                              imagePath: trip.days.isNotEmpty &&
                                      trip.days.first.places.isNotEmpty &&
                                      trip.days.first.places.first.imageURL
                                          .isNotEmpty
                                  ? trip.days.first.places.first.imageURL
                                  : 'lib/assets/place_images/AngKor.jpg',
                              onTap: () => _goToTripDetails(trip));
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

  // To show logout confirmation dialog
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
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            dertamColor: DertamColors.red,
            hasBackground: true,
          ),
        ],
      ),
    );
  }

  // To show the option to choose such as setting, edit profile or view profile, reset password, logout
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
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen()));
            },
          ),
          OptionTile(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () => _showLogoutConfirmation(context),
          ),
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

  void _logout(BuildContext context) {
    // Get the auth provider and call signOut
    final authProvider =
        Provider.of<AuthServiceProvider>(context, listen: false);
    authProvider.signOut(context);
  }
}
