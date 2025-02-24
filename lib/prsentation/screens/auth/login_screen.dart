import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/auth/gmail_signup_screen.dart';
import 'package:tourism_app/prsentation/screens/auth/phone_auth_screen.dart';
import 'package:tourism_app/prsentation/screens/home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'package:tourism_app/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                _emailAddress(),
                const SizedBox(height: 20),
                _password(),
                const SizedBox(height: 20),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen()),
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
                _signin(context),
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
                    _googleLoginButton(context),
                    const SizedBox(width: 16),
                    _facebookLoginButton(context),
                    const SizedBox(width: 16),
                    _phoneLoginButton(context),
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
  }

  /// Email Input Field
  Widget _emailAddress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email address',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  /// Password Input Field
  Widget _password() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter your password',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  /// Sign In Button
  Widget _signin(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2F80ED),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        await AuthService().signinEmail(
          email: _emailController.text,
          password: _passwordController.text,
          context: context,
        );
      },
      child: const Text(
        'Sign in',
        style: TextStyle(color: Color.fromARGB(255, 244, 243, 243)),
      ),
    );
  }

  /// Social Login Button

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

Widget _phoneLoginButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
      );
    },
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.asset(
          'lib/assets/images/phone.png',
          height: 24,
        ),
      ),
    ),
  );
}

Widget _facebookLoginButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
     bool isSignedIn = (await AuthService().signInWithFacebook(context)) as bool;
      if (isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in failed!")),
        );
      }
    },
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.asset(
          'lib/assets/images/facebook.png',
          height: 24,
        ),
      ),
    ),
  );
}

Widget _googleLoginButton(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      bool isSignedIn = await AuthService().signInWithGoogle();
      if (isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in failed!")),
        );
      }
    },
    child: Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Image.asset(
          'lib/assets/images/google.png',
          height: 24,
        ),
      ),
    ),
  );
}