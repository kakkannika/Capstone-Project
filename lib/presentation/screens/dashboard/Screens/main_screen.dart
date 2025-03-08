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
            // Give the side menu a more specific width constraint
            Container(
              width: 280, // Or use a responsive approach
              child: SideMenu(
                currentScreen: _currentScreen,
                onScreenChanged: _setScreen,
              ),
            ),
            // Main content
            Expanded(
              child: IndexedStack(
                index: _getScreenIndex(),
                children: [
                  DashboardScreen(
                    screenType: ScreenType.dashboard,
                  ),
                  DestinationScreen(
                    screenType: ScreenType.destination,
                  ), // Placeholder for settings
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
