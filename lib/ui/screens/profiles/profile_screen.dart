// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/screens/auth/reset_password_screen.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog_button.dart';
import 'package:tourism_app/ui/widgets/navigationBar.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'edit_profile_screen.dart';
import 'setting_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return DertamDialog(
              title: 'Confirm Logout',
              content: 'Are you sure you want to logout?',
              actions: [
                DertamDialogButton(
                  onPressed: () => Navigator.pop(context, false),
                  text: 'Cancel',
                  dertamColor: DertamColors.grey,
                ),
                DertamDialogButton(
                  onPressed: () => Navigator.pop(context, true),
                  text: 'Logout',
                  dertamColor: DertamColors.red,
                  hasBackground: true,
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServiceProvider>(context);
    final currentUser = authProvider.currentUser;
    final userName = currentUser?.displayName ?? 'Username';
    final userEmail = currentUser?.email ?? 'ggwp@gmil.com';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'User Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DertamColors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          color: DertamColors.white,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: currentUser?.photoUrl != null
                        ? NetworkImage(currentUser!.photoUrl!) as ImageProvider
                        : const AssetImage('assets/images/avatar.jpg'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: DertamTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: DertamColors.blueSky.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.edit_outlined, color: Colors.blue),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.lock_outline, color: Colors.blue),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: Colors.blue),
                      title: const Text('Help'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Navigate to help screen
                      },
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.settings_outlined, color: Colors.blue),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Log out',
                        style: TextStyle(color: Colors.red),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Navigationbar(
        currentIndex: 3,
      ),
    );
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await _showLogoutConfirmationDialog(context);
    if (shouldLogout) {
      final authProvider =
          Provider.of<AuthServiceProvider>(context, listen: false);
      authProvider.signOut(context);
    }
  }
}