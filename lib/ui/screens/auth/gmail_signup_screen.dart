import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';
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
  final ValueNotifier<bool> _passwordVisibilityNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _confirmPasswordVisibilityNotifier = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthServiceProvider>(
      builder: (context, authService, child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Form( 
                  key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                      ),
                    ),
                    SizedBox(height: DertamSpacings.m),
                    // Register Text
                    Center(
                      child: Text(
                        'Register',
                        style: DertamTextStyles.heading.copyWith(
                          color: DertamColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: DertamSpacings.xl),
                    // Username TextField
                     DertamTextfield(
                        controller: _usernameController,
                        label: "Full Name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        borderColor: DertamColors.greyLight,
                        focusedBorderColor: DertamColors.primary,
                        textColor: DertamColors.neutralDark,
                      ),
                      
                    // Email TextField
                    DertamTextfield(
                        controller: _emailController,
                        label: "Email",
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
                 
                    // Password TextField
                    ValueListenableBuilder<bool>(
                      valueListenable: _passwordVisibilityNotifier,
                      builder: (context, obscureText, _) {
                        return DertamTextfield(
                          controller: _passwordController,
                          label: "Password",
                          isPassword: true,
                          obscureText: obscureText,
                          onVisibilityToggle: () {
                            _passwordVisibilityNotifier.value = !obscureText;
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
                        );
                      },
                    ),
                
                    // Confirm Password TextField
                     ValueListenableBuilder<bool>(
                      valueListenable: _confirmPasswordVisibilityNotifier,
                      builder: (context, obscureText, _) {
                        return DertamTextfield(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          isPassword: true,
                          obscureText: obscureText,
                          onVisibilityToggle: () {
                            _confirmPasswordVisibilityNotifier.value = !obscureText;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          borderColor: DertamColors.greyLight,
                          focusedBorderColor: DertamColors.primary,
                          textColor: DertamColors.neutralDark,
                        );
                      },
                    ),
                    SizedBox(height: DertamSpacings.xl),
                    // Sign Up Button
                    DertamButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await authService.signUpWithEmail(
                              email: _emailController.text,
                              password: _passwordController.text,
                              username: _usernameController.text,
                              confirmPassword: _confirmPasswordController.text,
                            );
                            
                            // Navigate to login screen only after successful signup
                            if (success) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            }
                          }
                        },
                        text: 'Sign up',
                        buttonType: ButtonType.primary,
                      ),
                    SizedBox(height: DertamSpacings.s),
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
                        child: Text(
                          'Already have an account',
                          style: DertamTextStyles.body.copyWith(
                          color: DertamColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          ),
        );
      },
    );
  }
}