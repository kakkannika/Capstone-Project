import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/profiles/widget/setting_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SettingItem(
            icon: Icons.person,
            title: 'Account Settings',
            onTap: () {}, // Navigate to account settings
          ),
          SettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {}, // Navigate to notifications settings
          ),
          SettingItem(
            icon: Icons.lock,
            title: 'Privacy & Security',
            onTap: () {}, // Navigate to privacy settings
          ),
          SettingItem(
            icon: Icons.palette,
            title: 'App Preferences',
            onTap: () {}, // Navigate to preferences
          ),
          SettingItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {}, // Navigate to help
          ),
          // const Divider(),
          // SettingItem(
          //   icon: Icons.logout,
          //   title: 'Logout',
          //   onTap: () {}, // Handle logout
          //   isDestructive: true,
          // ),
        ],
      ),
    );
  }

  
}