import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/AI%20Chatbot/chat_screen.dart';


void main() {
  runApp(AIChatApp());
}

class AIChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}