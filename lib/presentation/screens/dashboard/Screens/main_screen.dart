import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/dashboard_screen.dart';
import 'package:tourism_app/theme/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: DertamColors.white,
        padding: EdgeInsets.all(DertamSpacings.m),
        child: Row(children: [
          Expanded(flex: 3, child: DashboardScreen()),
        ]),
      ),
    );
  }
}
