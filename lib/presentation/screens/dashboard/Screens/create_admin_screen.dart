import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/presentation/widgets/dertam_button.dart';
import 'package:tourism_app/presentation/widgets/dertam_textfield.dart';
import 'package:tourism_app/providers/user_provider.dart';
import 'package:tourism_app/theme/theme.dart';

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.createAdminUser(
        email: emailController.text,
        displayName: displayNameController.text,
        uid: '',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin user created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create admin: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Admin User'),
        backgroundColor: DertamColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(DertamSpacings.l),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(DertamSpacings.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create New Admin',
                    style: DertamTextStyles.heading.copyWith(
                      color: DertamColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DertamSpacings.l),
                  DertamTextfield(
                    label: 'Display Name',
                    controller: displayNameController,
                    icon: Icons.person,
                  ),
                  const SizedBox(height: DertamSpacings.m),
                  DertamTextfield(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: DertamSpacings.m),
                  DertamTextfield(
                    label: 'Password',
                    controller: passwordController,
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: DertamSpacings.l),
                  DertamButton(
                    onPressed: isLoading
                        ? () {}
                        : () {
                            _createAdmin();
                          },
                    text: isLoading ? 'Creating...' : 'Create Admin',
                    buttonType: ButtonType.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
