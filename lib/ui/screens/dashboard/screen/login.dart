// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/screens/dashboard/provider/user_provider.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';

import '../../../../domain/models/user/user_model.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      print('Starting login process...'); // Debug print

      // Get the user provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Attempt to sign in
      await AuthServiceProvider().signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );

      print('Firebase Auth successful, fetching user data...'); // Debug print

      // After successful sign in, fetch user data including role
      final user = await userProvider.fetchCurrentUser();

      print('User data fetched. Role: ${user?.role}'); // Debug print

      // Hide loading indicator
      if (mounted) {
        Navigator.pop(context); // Remove loading dialog
      }

      if (user != null) {
        // Check user role and show appropriate response
        if (!mounted) return;

        if (user.role == UserRole.admin) {
          print('Navigating to admin dashboard...'); // Debug print
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          print('Regular user attempted to login...'); // Debug print
          // Hide loading indicator if it's still showing
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          showDialog(
            context: context,
            barrierDismissible: false, // User must tap button to close dialog
            builder: (context) => AlertDialog(
              title: Text('Access Denied', style: TextStyle(color: Colors.red)),
              content: const Text(
                'This portal is only accessible to administrators.',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    // Clear the text fields
                    emailController.clear();
                    passwordController.clear();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: DertamColors.primary),
                  ),
                ),
              ],
            ),
          );
          // Sign out the user since they don't have access
          await AuthServiceProvider().signOut(context);
        }
      } else {
        print('User data not found'); // Debug print
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      print('Login error: $e'); // Debug print
      // Hide loading indicator if it's showing
      if (mounted) {
        Navigator.pop(context); // Remove loading dialog
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/background.jpg',
            fit: BoxFit.cover, width: double.infinity, height: double.infinity),
        Center(
          child: Container(
            width: 600,
            height: 475,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: DertamSpacings.m),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey.shade200,
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          DertamTextfield(
                            label: 'Email',
                            controller: emailController,
                            icon: Iconsax.message,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          DertamTextfield(
                            label: 'Password',
                            controller: passwordController,
                            icon: Iconsax.lock,
                            isPassword: true,
                            obscureText: obscurePassword,
                            onVisibilityToggle: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          DertamButton(
                            onPressed: () => handleLogin(context),
                            text: 'Log In',
                            buttonType: ButtonType.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}