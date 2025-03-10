// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tourism_app/admin/screen/main_screen.dart';
import 'package:tourism_app/admin/widget/header.dart';

import 'package:tourism_app/theme/theme.dart';

class DashboardScreen extends StatefulWidget {
  final ScreenType screenType;
  const DashboardScreen({super.key, required this.screenType});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DertamSpacings.m),
        child: Column(
          children: [
            Header(
              currentScreen: widget.screenType,
            ),
            SizedBox(height: DertamSpacings.m),
            SizedBox(
              height: 500,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: DertamSpacings.m,
                  mainAxisSpacing: DertamSpacings.m,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: DertamColors.white,
                    borderRadius: BorderRadius.circular(DertamSpacings.radius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                ),
              ),
            ),
            SizedBox(height: DertamSpacings.m),
            Container(
              padding: EdgeInsets.all(DertamSpacings.m),
              width: double.infinity,
              decoration: BoxDecoration(
                color: DertamColors.white,
                borderRadius: BorderRadius.circular(DertamSpacings.radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [Text('')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}