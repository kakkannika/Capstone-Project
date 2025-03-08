import 'package:flutter/material.dart';
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
    final double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: 280, // Set a fixed width or use constraints
      constraints: BoxConstraints(
        minHeight: screenHeight,
        maxHeight: double.infinity,
      ),
      color: DertamColors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(child: Image.asset('lib/assets/images/logo.png')),
            ListTile(
              selected: currentScreen == ScreenType.dashboard,
              selectedTileColor: DertamColors.primary.withOpacity(0.1),
              onTap: () => onScreenChanged(ScreenType.dashboard),
              horizontalTitleGap: 16.0,
              leading: Icon(
                Icons.dashboard_outlined,
                color: currentScreen == ScreenType.dashboard
                    ? DertamColors.primary
                    : DertamColors.iconLight,
              ),
              title: Text('Dashboard',
                  style: DertamTextStyles.body.copyWith(
                    color: currentScreen == ScreenType.dashboard
                        ? DertamColors.primary
                        : DertamColors.neutralLighter,
                  )),
            ),
            ListTile(
              selected: currentScreen == ScreenType.destination,
              selectedTileColor: DertamColors.primary.withOpacity(0.1),
              onTap: () => onScreenChanged(ScreenType.destination),
              horizontalTitleGap: 16.0,
              leading: Icon(
                Icons.location_on_outlined,
                color: currentScreen == ScreenType.destination
                    ? DertamColors.primary
                    : DertamColors.iconLight,
              ),
              title: Text('Destinations',
                  style: DertamTextStyles.body.copyWith(
                    color: currentScreen == ScreenType.destination
                        ? DertamColors.primary
                        : DertamColors.neutralLighter,
                  )),
            ),
            ListTile(
              onTap: () => onScreenChanged(ScreenType.users),
              horizontalTitleGap: 16.0,
              leading: Icon(Icons.people_alt_outlined,
                  color: DertamColors.iconLight),
              title: Text('Users',
                  style: DertamTextStyles.body
                      .copyWith(color: DertamColors.neutralLighter)),
            ),
            ListTile(
              onTap: () => onScreenChanged(ScreenType.notifications),
              horizontalTitleGap: 16.0,
              leading: Icon(Icons.notifications_outlined,
                  color: DertamColors.iconLight),
              title: Text('Notifications',
                  style: DertamTextStyles.body
                      .copyWith(color: DertamColors.neutralLighter)),
            ),
            ListTile(
              onTap: () => onScreenChanged(ScreenType.expenses),
              horizontalTitleGap: 16.0,
              leading:
                  Icon(Icons.money_outlined, color: DertamColors.iconLight),
              title: Text('Expenses',
                  style: DertamTextStyles.body
                      .copyWith(color: DertamColors.neutralLighter)),
            ),
            ListTile(
              onTap: () => onScreenChanged(ScreenType.settings),
              horizontalTitleGap: 16.0,
              leading:
                  Icon(Icons.settings_outlined, color: DertamColors.iconLight),
              title: Text('Settings',
                  style: DertamTextStyles.body
                      .copyWith(color: DertamColors.neutralLighter)),
            ),
          ],
        ),
      ),
    );
  }
}
