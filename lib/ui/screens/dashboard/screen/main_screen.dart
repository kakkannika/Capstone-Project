import 'package:flutter/material.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/screens/dashboard/screen/dashboard_screen.dart';
import 'package:tourism_app/ui/screens/dashboard/screen/user_screen.dart';
import 'package:tourism_app/ui/screens/dashboard/widget/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const UsersScreen(),
  ];

  void _handleDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: DertamColors.white,
        padding: EdgeInsets.all(DertamSpacings.m),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SideMenu(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _handleDestinationSelected,
              ),
            ),
            Expanded(
              flex: 8,
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}