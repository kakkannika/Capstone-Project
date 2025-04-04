// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/dashboard/provider/user_provider.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/screens/auth/login_screen.dart';


class SideMenu extends StatefulWidget {
  final Function(int) onDestinationSelected;
  final int selectedIndex;

  const SideMenu({
    super.key,
    required this.onDestinationSelected,
    required this.selectedIndex,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        return Scaffold(
          backgroundColor: DertamColors.white,
          body: Container(
            margin: EdgeInsets.all(DertamSpacings.m),
            padding: EdgeInsets.all(DertamSpacings.m),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(DertamSpacings.radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: NavigationRail(
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              extended: true,
              backgroundColor: DertamColors.white,
              selectedIconTheme: const IconThemeData(
                color: Colors.white, // Selected icon color is white
              ),
              unselectedIconTheme: IconThemeData(
                color: DertamColors.neutralLight,
              ),
              selectedLabelTextStyle: DertamTextStyles.title.copyWith(
                color: DertamColors.primary,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: DertamTextStyles.title.copyWith(
                color: DertamColors.neutralLight,
              ),
              useIndicator: true,
              indicatorColor:
                  DertamColors.primary, // Make indicator primary color
              leading: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 48,
                      width: 48,
                    ),
                    const SizedBox(height: DertamSpacings.s),
                    Text(
                      'Admin Panel',
                      style: DertamTextStyles.title.copyWith(
                        color: DertamColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DertamSpacings.s),
                    const Divider(),
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  selectedIcon: Container(
                    decoration: BoxDecoration(
                      color: DertamColors.primary,
                    ),
                    child: const Icon(Icons.dashboard, color: Colors.white),
                  ),
                  label: Text('Dashboard', style: DertamTextStyles.title),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  selectedIcon: Container(
                    decoration: BoxDecoration(
                      color: DertamColors.primary,
                    ),
                    child: const Icon(Icons.people, color: Colors.white),
                  ),
                  label: Text('Users', style: DertamTextStyles.title),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(),
                        const SizedBox(height: DertamSpacings.s),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              DertamColors.primary.withOpacity(0.1),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundImage: user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!) as ImageProvider
                                : const AssetImage(
                                    'assets/images/user_profile.jpg'),
                          ),
                        ),
                        const SizedBox(height: DertamSpacings.s),
                        Text(
                          user?.displayName ?? 'Admin',
                          style: DertamTextStyles.title.copyWith(
                            fontWeight: FontWeight.bold,
                            color: DertamColors.black,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: DertamTextStyles.label.copyWith(
                            color: DertamColors.neutralLight,
                          ),
                        ),
                        const SizedBox(height: DertamSpacings.s),
                        TextButton.icon(
                          onPressed: () async {
                            // Show confirmation dialog
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: DertamColors.white,
                                title: const Text('Logout'),
                                content: const Text(
                                    'Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: DertamColors.neutralLight),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(color: DertamColors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              await AuthServiceProvider().signOut(context);
                              if (!context.mounted) return;

                              // Navigate to login screen and remove all previous routes
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>  LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          icon: Icon(
                            Icons.logout,
                            color: DertamColors.primary,
                            size: DertamSize.icon,
                          ),
                          label: Text(
                            'Logout',
                            style: DertamTextStyles.button.copyWith(
                              color: DertamColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: DertamSpacings.m),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}