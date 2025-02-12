import 'dart:math'; // Import this to use Random
import 'package:flutter/material.dart';
import 'login_screen.dart';

class GetStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background with a Starry effect
          Container(
            decoration:  const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF085794), // Deep blue
                  Color(0xFF17649F), // Medium blue
                  Color(0xFF206CA6), // Light blue
                  Color(0xFF74B5E3), // Very light blue
                  Color(0xFFFFFFFF), // White
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: StarrySkyPainter(),
            ),
          ),
         Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Image.asset(
                  'lib/assets/images/Logo.png', 
                  height: 200, 
                ),
                const SizedBox(height: 20),
                const Text(
                  "Let's Explore New Destinations",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Find Your Dream Destination With Us",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
               const  SizedBox(height: 40),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, 
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>LoginScreen()),
                        );
                      
                    },
                    child: const Text('GET START', style:TextStyle(fontSize: 18,color: Colors.white)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class StarrySkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7);
    final random = Random();

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5; // random star 

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
