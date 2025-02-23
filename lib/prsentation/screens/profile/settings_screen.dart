import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSettingItem(
            icon: Icons.person,
            title: 'Account Settings',
            onTap: () {}, // Navigate to account settings
          ),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {}, // Navigate to notifications settings
          ),
          _buildSettingItem(
            icon: Icons.lock,
            title: 'Privacy & Security',
            onTap: () {}, // Navigate to privacy settings
          ),
          _buildSettingItem(
            icon: Icons.palette,
            title: 'App Preferences',
            onTap: () {}, // Navigate to preferences
          ),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {}, // Navigate to help
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {}, // Handle logout
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.blue),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.black)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
