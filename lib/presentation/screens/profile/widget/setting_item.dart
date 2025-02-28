import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/theme/theme.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isDestructive ? DertamColors.red : DertamColors.primary,
      ),
      title: Text(
        title, 
        style: TextStyle(
          color: isDestructive ? DertamColors.red : DertamColors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}