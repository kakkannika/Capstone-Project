import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart'; // Import the register screen

class LoginScreen extends StatelessWidget {
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
          // Content inside the center
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo at the top
                  Image.asset(
                    'lib/assets/images/Logo.png',
                    height: 120, 
                  ),
                  const  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8), 
                    ),
                  ),
                 const  SizedBox(height: 20),

                  // Password text field
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                 const  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child:const  Text(
                        'Forgot your password?',
                        style: TextStyle(color: Color.fromARGB(255, 106, 7, 205)),
                      ),
                    ),
                  ),
                 const SizedBox(height: 20),

                  // Sign In button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, 
                      padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Handle sign in logic here
                    },
                    child: const Text('Sign In', style:TextStyle(fontSize: 18,color: Colors.white)),
                  ),
                 const  SizedBox(height: 20),
                  const Text("Or continue with"),
                 const  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Facebook button)
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white, 
                         child: Image.asset(
                          'lib/assets/images/facebook.png', 
                          color: Colors.blue,
                          height: 24, 
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // Google button (Circle with white background and Google icon)
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white, 
                        child: Image.asset(
                          'lib/assets/images/google.png', 
                          height: 24, 
                        ),
                      ),
                       const SizedBox(width: 20),
                      
                      // Google button (Circle with white background and Google icon)
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
                  const SizedBox(height: 20),

                  // Register link
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
