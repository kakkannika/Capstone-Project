// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/screens/auth/gmail_signup_screen.dart';
import 'package:tourism_app/ui/screens/home/home_page.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscureTextNotifier = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthServiceProvider>(
      builder: (context, authService, child) {
        return Scaffold(
            resizeToAvoidBottomInset: true, // Prevent keyboard overflow
            body: SafeArea(
              child: SingleChildScrollView(
                // Enables scrolling when the keyboard appears
                child: Form(
                  // Add Form widget here
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // Logo
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: DertamColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading logo: $error');
                                    return Center(
                                      child: Text(
                                        'DERTAM',
                                        style: DertamTextStyles.heading.copyWith(
                                          color: DertamColors.primary,
                                          fontSize: 24,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: DertamSpacings.m),
                        Center(
                          child: Text(
                            'Login',
                            style: DertamTextStyles.heading.copyWith(
                              color: DertamColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: DertamSpacings.m),
                        // Email field with validation
                        DertamTextfield(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          borderColor: DertamColors.greyLight,
                          focusedBorderColor: DertamColors.primary,
                          textColor: DertamColors.neutralDark,
                        ),

                        // password field and forgot password section with:
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscureTextNotifier,
                          builder: (context, obscureText, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min, // Add this
                              children: [
                                DertamTextfield(
                                  controller: _passwordController,
                                  label: 'Password',
                                  isPassword: true,
                                  obscureText: obscureText,
                                  onVisibilityToggle: () {
                                    _obscureTextNotifier.value = !obscureText;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  borderColor: DertamColors.greyLight,
                                  focusedBorderColor: DertamColors.primary,
                                  textColor: DertamColors.neutralDark,
                                ),
                                Transform.translate(
                                  // Add this wrapper
                                  offset: const Offset(
                                      0, -8), // Move up by 8 pixels
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      alignment: Alignment.centerRight,
                                    ),
                                    child: Text(
                                      'Forgot your password?',
                                      style: DertamTextStyles.body.copyWith(
                                        color: DertamColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: DertamSpacings.m),
                        // Sign in button
                        DertamButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool success = await authService.signInWithEmail(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              
                              // Force navigation on success
                              if (success) {
                                // Check isAuthenticated again to be sure
                                if (authService.isAuthenticated) {
                                  // Replace the entire navigation stack with the home screen
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    (route) => false, // Remove all previous routes
                                  );
                                }
                              }
                            }
                          },
                          text: "Sign in",
                          buttonType: ButtonType.primary,
                        ),
                        SizedBox(height: DertamSpacings.s),

                        // OR continue with
                        Center(
                          child: Text(
                            'Or continue with',
                            style: DertamTextStyles.body.copyWith(
                              color: DertamColors.neutralLight,
                            ),
                          ),
                        ),
                        SizedBox(height: DertamSpacings.s),

                        // Social login buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton(
                                onTap: () async {
                                  bool success = await authService.signInWithGoogle();
                                  if (success) {
                                    // Force navigation on successful Google sign in
                                    if (authService.isAuthenticated) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                                        (route) => false, // Remove all previous routes
                                      );
                                    }
                                  }
                                },
                                imagePath: 'assets/images/google.png',
                                debugLabel: 'Google icon'),
                            //SizedBox(height: DertamSpacings.m),
                            // SocialLoginButton(
                            //     onTap: () => authService.signInWithFacebook(context),
                            //     imagePath: 'lib/assets/images/facebook.png'),
                            // SizedBox(height: DertamSpacings.m),
                            // SocialLoginButton(
                            //     onTap: () => handlePhoneLogin(context),
                            //     imagePath: 'lib/assets/images/phone.png')
                          ],
                        ),

                        // Register link
                        _signup(context),
                      ],
                    ),
                  ),
                ),
              ),
            ));
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
          text: TextSpan(
            text: "Don't have an account? ",
            style: DertamTextStyles.body.copyWith(
              color: DertamColors.neutralLight,
            ),
            children: [
              TextSpan(
                text: 'Register',
                style: DertamTextStyles.body.copyWith(
                  color: DertamColors.primary,
                ),
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
  final String debugLabel;

  const SocialLoginButton({
    super.key,
    required this.onTap,
    required this.imagePath,
    required this.debugLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: DertamColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: DertamColors.greyLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: DertamColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(DertamSpacings.s - 4),
          child: Builder(
            builder: (context) {
              // For Google icon specifically, provide a text fallback
              if (debugLabel == 'Google icon') {
                return Image.asset(
                  imagePath,
                  height: DertamSize.icon - 8,
                  width: DertamSize.icon - 8,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading $debugLabel image: $error');
                    // Google icon fallback as text "G"
                    return Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: DertamColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    );
                  },
                );
              }
              
              // Default image loading with generic icon fallback
              return Image.asset(
                imagePath,
                height: DertamSize.icon - 8,
                width: DertamSize.icon - 8,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading $debugLabel image: $error');
                  return Icon(Icons.link, color: DertamColors.primary);
                },
              );
            }
          ),
        ),
      ),
    );
  }
}