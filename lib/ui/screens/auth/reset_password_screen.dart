// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthServiceProvider>(
      builder: (context, authService, child) {
        return Scaffold(
            body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              // Wrap with Form
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                      ),
                    ),
                    SizedBox(height: DertamSpacings.m),
                    Text(
                      'Forgot Password?',
                      style: DertamTextStyles.heading.copyWith(
                        color: DertamColors.black,
                      ),
                    ),
                    SizedBox(height: DertamSpacings.s),
                    Text(
                      'Select your preferred method to reset your password.',
                      textAlign: TextAlign.center,
                      style: DertamTextStyles.body.copyWith(
                        color: DertamColors.black.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: DertamSpacings.l),
                    //Email field
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
                    SizedBox(height: DertamSpacings.l),
                    DertamButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            bool success = await authService.resetPassword(
                              _emailController.text,
                            );
                            
                            // Show success message
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password reset link sent to your email',
                                    style: DertamTextStyles.body.copyWith(
                                      color: DertamColors.white,
                                    ),
                                  ),
                                  backgroundColor: DertamColors.green,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(DertamSpacings.m),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to send reset link: ${e.toString()}',
                                  style: DertamTextStyles.body.copyWith(
                                    color: DertamColors.white,
                                  ),
                                ),
                                backgroundColor: DertamColors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(DertamSpacings.m),
                              ),
                            );
                          }
                        }
                      },
                      text: 'Send',
                      buttonType: ButtonType.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      },
    );
  }
}