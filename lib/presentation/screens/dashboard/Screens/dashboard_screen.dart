import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/dashboard/widgets/header.dart';
import 'package:tourism_app/theme/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
          Header(),
          SizedBox(height: DertamSpacings.m),
          Row(
            children: [
              Expanded(
                  flex: 5,
                  child: Container(
                    height: 200,
                    color: Colors.red,
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    height: 200,
                    color: Colors.blue,
                  )),
            ],
          )
        ],
      ),
    ));
  }
}
