import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E3C72), // Dark Blue
                  Color(0xFF2A5298), // Medium Blue
                  Color(0xFF56CCF2), // Light Blue
                  Color(0xFF6A9FE9), // Very light Blue
                  Color(0xFFFFFFFF), // White
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content inside the center
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(  // Wrap the Column inside a SingleChildScrollView to make it scrollable
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo at the top
                    Image.asset(
                      'lib/assets/images/Logo.png', 
                      height: 120,
                    ),
                    const SizedBox(height: 10),

                    // Register Text under the logo
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Text color
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Name text field with updated design
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Color(0x80FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Address text field with updated design
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Color(0x80FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mobile Number text field with updated design
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        filled: true,
                        fillColor: Color(0x80FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password text field with updated design
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                        fillColor: Color(0x80FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password text field with updated design
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                        fillColor: Color(0x80FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign Up button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, 
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), 
                        ),
                      ),
                      onPressed: () {
                        // Handle sign up logic here
                      },
                      child: const Text('SIGN UP', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 20),

                    // Social login buttons
                    const Text("Or continue with"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Facebook button (Circle with Facebook logo)
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white, 
                          child: Image.asset(
                            'lib/assets/images/facebook.png', 
                            height: 24, 
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 20), 
                        
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white, 
                          child: Image.asset(
                            'lib/assets/images/google.png', 
                            height: 24, 
                          ),
                        ),
                        const SizedBox(width: 20),

                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white, 
                          child: Image.asset(
                            'lib/assets/images/phone.png', 
                            height: 24, 
                          ),
                        ),
                      ],
                    ),
                    
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
