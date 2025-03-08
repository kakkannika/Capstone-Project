import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/destination_screen.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/main_screen.dart';
import 'package:tourism_app/theme/theme.dart';

class SideMenu extends StatelessWidget {
  final void Function(ScreenType screenType) onScreenChanged;
  final ScreenType currentScreen;

  const SideMenu({
    super.key,
    required this.onScreenChanged,
    required this.currentScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DertamColors.white,
      child: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        child: SingleChildScrollView(
          child: Column(
            children: [
              DrawerHeader(child: Image.asset('lib/assets/images/logo.png')),
              ListTile(
                onTap: () {},
                horizontalTitleGap: 16.0,
                leading: Icon(Icons.dashboard_outlined,
                    color: DertamColors.iconLight),
                title: Text('Dashboard',
                    style: DertamTextStyles.body
                        .copyWith(color: DertamColors.neutralLighter)),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DestinationScreen()),
                  );
                },
                horizontalTitleGap: 16.0,
                leading: Icon(Icons.location_on_outlined,
                    color: DertamColors.iconLight),
                title: Text('Destinations',
                    style: DertamTextStyles.body
                        .copyWith(color: DertamColors.neutralLighter)),
              ),
              ListTile(
                onTap: () {},
                horizontalTitleGap: 16.0,
                leading: Icon(Icons.people_alt_outlined,
                    color: DertamColors.iconLight),
                title: Text('Users',
                    style: DertamTextStyles.body
                        .copyWith(color: DertamColors.neutralLighter)),
              ),
              ListTile(
                onTap: () {},
                horizontalTitleGap: 16.0,
                leading: Icon(Icons.bar_chart_outlined,
                    color: DertamColors.iconLight),
                title: Text('Notifications',
                    style: DertamTextStyles.body
                        .copyWith(color: DertamColors.neutralLighter)),
              ),
              ListTile(
                onTap: () {},
                horizontalTitleGap: 16.0,
                leading:
                    Icon(Icons.edit_outlined, color: DertamColors.iconLight),
                title: Text('Expenses & Budget',
                    style: DertamTextStyles.body
                        .copyWith(color: DertamColors.neutralLighter)),
              ),
              ListTile(
                onTap: () {},
                horizontalTitleGap: 16.0,
                leading: Icon(Icons.settings_outlined,
                    color: DertamColors.iconLight),
                title: Text('Settings',
                    style: DertamTextStyles.body
                        .copyWith(color: DertamColors.neutralLighter)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
