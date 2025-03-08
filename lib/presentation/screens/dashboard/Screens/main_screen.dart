import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/dashboard_screen.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/destination_screen.dart';
import 'package:tourism_app/presentation/screens/dashboard/widgets/side_menu.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ScreenType _currentScreen = ScreenType.dashboard;

  void _setScreen(ScreenType screenType) {
    setState(() {
      _currentScreen = screenType;
    });
  }

  int _getScreenIndex() {
    return _currentScreen.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simplified side menu that just calls _setScreen
            Expanded(
              child: SideMenu(
                currentScreen: _currentScreen,
                onScreenChanged: _setScreen,
              ),
            ),
            // Using IndexedStack to maintain state of all screens
            Expanded(
              flex: 5,
              child: IndexedStack(
                index: _getScreenIndex(),
                children: [
                  DashboardScreen(),
                  DestinationScreen(), // Settings screen
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ScreenType {
  dashboard,
  destination,
  users,
  notifications,
  expenses,
  settings,
}
