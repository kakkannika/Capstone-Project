// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/screens/auth/gmail_signup_screen.dart';
import 'package:tourism_app/presentation/widgets/custome_input_field.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/providers/auth_provider.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Consumer<AuthServiceProvider>(
      builder: (context, authService, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true, // Prevent keyboard overflow
          body: SafeArea(
            child: SingleChildScrollView(
              // Enables scrolling when the keyboard appears
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    // Logo
                    Center(
                      child: Image.asset(
                        'lib/assets/images/logo.png',
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Email field
                    CustomInputField(
                      controller: _emailController,
                      hintText: 'Enter your email address',
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text(
                          'Forgot your password?',
                          style: TextStyle(
                            color: Color(0xFF2F80ED),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sign in button
                    DertamButton(
                      onPressed: () => authService.signInWithEmail(
                          email: _emailController.text,
                          password: _passwordController.text,
                          context: context),
                      text: "Sign in",
                      buttonType: ButtonType.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ), // Example of a custom shape
                    ),
                    const SizedBox(height: 24),

                    // OR continue with
                    const Center(
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Social login buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialLoginButton(
                            onTap: () => authService.signInWithGoogle(context),
                            imagePath: 'lib/assets/images/google.png'),
                        const SizedBox(width: 16),
                        // SocialLoginButton(
                        //     onTap: () => authService.signInWithFacebook(context),
                        //     imagePath: 'lib/assets/images/facebook.png'),
                        const SizedBox(width: 16),
                        // SocialLoginButton(
                        //     onTap: () => handlePhoneLogin(context),
                        //     imagePath: 'lib/assets/images/phone.png')
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Register link
                    _signup(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sign Up Link
  Widget _signup(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EmailRegisterScreen()),
          );
        },
        child: RichText(
          text: const TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.black54),
            children: [
              TextSpan(
                text: 'Register',
                style: TextStyle(color: Color(0xFF2F80ED)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Social Login Button
class SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final String imagePath;

  const SocialLoginButton({
    super.key,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            height: 24,
          ),
        ),
      ),
    );
  }
}
