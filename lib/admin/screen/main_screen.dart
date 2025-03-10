import 'package:flutter/material.dart';
import 'package:tourism_app/admin/screen/dashboard_screen.dart';
import 'package:tourism_app/admin/test/place_crud_service_test.dart';
import 'package:tourism_app/admin/widget/side_menu.dart';

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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Prevents horizontal overflow
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Side Menu with a fixed width
              SizedBox(
                width: 280, // Set a defined width
                child: SideMenu(
                  currentScreen: _currentScreen,
                  onScreenChanged: _setScreen,
                ),
              ),
              // Main content section
              Flexible(
                fit: FlexFit.tight, // Allows it to take available space
                child: IndexedStack(
                  index: _getScreenIndex(),
                  children: [
                    DashboardScreen(screenType: ScreenType.dashboard),
                    AddPlaceTestScreen(screenType: ScreenType.destination),
                    // You can add more screens here if needed (e.g., users, notifications, etc.)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enum to manage screen switching
enum ScreenType {
  dashboard,
  destination,
  users,
  notifications,
  expenses,
  settings,
}
