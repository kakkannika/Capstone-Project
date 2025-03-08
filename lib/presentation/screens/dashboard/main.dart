import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/destination_screen.dart';
import 'package:tourism_app/presentation/screens/dashboard/Screens/main_screen.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tourism App Admin Panel',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DestinationScreen(),
    );
  }
}
