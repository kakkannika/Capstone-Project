import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/screens/budget/select_currency_screen.dart';
import 'package:tourism_app/presentation/screens/auth/get_start_screen.dart';
import 'package:tourism_app/presentation/screens/question/question_screen.dart';

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
      home: QuestionScreen(),
    );
  }
}
