import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/main_screen.dart';
import 'package:tourism_app/presentation/screens/dashboard/widgets/header.dart';
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
                itemBuilder: (context, index) => InfoCard(),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Places',
                    style: DertamTextStyles.heading
                        .copyWith(color: DertamColors.textLight),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DertamSpacings.m),
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
        children: [
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: DertamColors.primary,
                  borderRadius: BorderRadius.circular(DertamSpacings.radius),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
