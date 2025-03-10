import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/repositories/firebase/auth_service.dart';
import 'package:tourism_app/presentation/widgets/dertam_tap.dart';
import 'widget/trips_list.dart';
import 'package:tourism_app/presentation/widgets/dertam_dialog_button.dart';
import 'widget/trips_item.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/presentation/widgets/dertam_dialog.dart';
import 'widget/option_tile.dart';
import 'edit_profile_screen.dart';
import 'setting_screen.dart';
// Import AuthServiceProvider

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the auth provider to get current user
    final authProvider = Provider.of<AuthServiceProvider>(context);
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
                  TripList(
                    title: 'Trips',
                    trips: [
                      TripItem(
                        title: 'Trip to Siem Reap',
                        places: '1 place',
                        status: 'Planning',
                        imagePath: 'lib/assets/place_images/AngKor_wat.jpg',
                        onTap: _goToTripDetails,
                      ),
                      TripItem(
                        title: 'Trip to Bali',
                        places: '2 places',
                        status: 'Upcoming',
                        imagePath: 'lib/assets/place_images/AngKor.jpg',
                        onTap: _goToTripDetails,
                      ),
                    ],
                  ),
                  TripList(
                    title: 'History',
                    trips: [
                      TripItem(
                        title: 'Kampot Trip',
                        places: '3 places',
                        status: 'Completed',
                        imagePath: 'lib/assets/place_images/AngKor.jpg',
                        onTap: _goToTripDetails,
                      ),
                      TripItem(
                        title: 'Koh Rong Tour',
                        places: '2 places',
                        status: 'Completed',
                        imagePath: 'lib/assets/place_images/AngKor_wat.jpg',
                        onTap: _goToTripDetails,
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
            onTap: () {
              // Navigate to reset password screen or show reset password dialog
              // Use the authProvider to reset password if you implement this
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

  void _goToTripDetails() => debugPrint('Navigate to Trip Details');

  void _logout(BuildContext context) {
    // Get the auth provider and call signOut
    final authProvider =
        Provider.of<AuthServiceProvider>(context, listen: false);
    authProvider.signOut(context);
  }
}
