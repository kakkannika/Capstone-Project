import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/auth/widget/custome_input_field.dart';
import 'package:tourism_app/services/auth_service.dart';
import 'package:tourism_app/widget/dertam_button.dart';
import 'login_screen.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<EmailRegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Future<void> signup(BuildContext context) async {
    await AuthService().signup(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      confirmPassword: _confirmPasswordController.text,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo
                Center(
                  child: SizedBox(
                    height: 80,
                    child: Image.asset(
                      'lib/assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Register Text
                const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Username TextField
                CustomInputField(
                    controller: _usernameController,
                    hintText: "enter your name"),
                const SizedBox(height: 16),
                // Email TextField
                CustomInputField(
                    controller: _emailController, hintText: "enter your email"),
                const SizedBox(height: 16),
                // Password TextField
                CustomInputField(
                    controller: _passwordController,
                    hintText: "Enter your password",
                    obscureText: true),
                const SizedBox(height: 16),
                // Confirm Password TextField
                CustomInputField(
                    controller: _confirmPasswordController,
                    hintText: "Please enter Confirm Password"),
                const SizedBox(height: 32),
                // Sign Up Button
                DertamButton(
                    onPressed: () {
                      signup(context);
                    },
                    text: 'Signup',
                    buttonType: ButtonType.primary),
                const SizedBox(height: 16),
                // Already have an account text
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Already have an account',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
