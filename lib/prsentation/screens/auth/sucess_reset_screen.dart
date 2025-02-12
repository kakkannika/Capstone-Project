import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/auth/new_password_screen.dart';

class SuccessResetEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Show a dialog immediately
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('You will be redirected to the New Password page.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => NewPasswordScreen()), 
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Icon(
              Icons.thumb_up,
              size: 50,
              color: Colors.blue,
            ),
             SizedBox(height: 20),
             Text(
              'Thank you.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 10),
             Text(
              'You will be redirected to the login page...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
             SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
