import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/widgets/custome_input_field.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/repositories/firebase/auth_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthServiceProvider>(
      builder: (context, authService, child) {
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
                        controller: _emailController,
                        hintText: "enter your email"),
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
                        onPressed: () async {
                          await authService.signUpWithEmail(
                              email: _emailController.text,
                              password: _passwordController.text,
                              username: _usernameController.text,
                              confirmPassword: _confirmPasswordController.text,
                              context: context);
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
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
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
      },
    );
  }
}
