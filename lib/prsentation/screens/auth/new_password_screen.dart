import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/auth/login_screen.dart';

class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/logo.png',
              height: 100,
            ),
            const SizedBox(height: 30),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter New Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
              ),
            ),
            const SizedBox(height: 20),

            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
              ),
            ),
            const SizedBox(height: 30),

            // Submit button
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
