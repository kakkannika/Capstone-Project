import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/trip_plan/auth/get_start_screen.dart';
import 'package:tourism_app/prsentation/screens/trip_plan/auth/login_screen.dart';
import 'package:tourism_app/prsentation/screens/trip_plan/home/home_screen.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    
      title: 'Tourism App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}