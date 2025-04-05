import 'package:flutter/material.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/screens/profiles/widget/setting_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new)),
        centerTitle: true,
        title: Text('Settings'),
        backgroundColor: DertamColors.white,
      ),
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
        ],
      ),
    );
  }
}
