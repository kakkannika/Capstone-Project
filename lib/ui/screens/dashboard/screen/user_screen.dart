// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/domain/models/user/user_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tourism_app/ui/screens/dashboard/provider/user_provider.dart';
import 'package:tourism_app/ui/screens/dashboard/widget/user_data_table.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Future<void> _showCreateUserDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController displayNameController = TextEditingController();
    bool obscurePassword = true;
    UserRole selectedRole = UserRole.user;
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: DertamColors.white,
              title: Text(
                'Create New User',
                style: DertamTextStyles.heading.copyWith(
                  color: DertamColors.primary,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DertamTextfield(
                        label: 'Display Name',
                        controller: displayNameController,
                        icon: Iconsax.user,
                      ),
                      const SizedBox(height: DertamSpacings.m),
                      DertamTextfield(
                        label: 'Email',
                        controller: emailController,
                        icon: Iconsax.message,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: DertamSpacings.m),
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
                      ),
                      const SizedBox(height: DertamSpacings.m),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: DertamColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: DertamColors.neutralLight,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UserRole>(
                            value: selectedRole,
                            isExpanded: true,
                            dropdownColor: DertamColors.white,
                            icon: const Icon(Iconsax.arrow_down_1),
                            items: UserRole.values.map((UserRole role) {
                              return DropdownMenuItem<UserRole>(
                                value: role,
                                child: Text(
                                  role == UserRole.admin ? 'Admin' : 'User',
                                  style: DertamTextStyles.body,
                                ),
                              );
                            }).toList(),
                            onChanged: (UserRole? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedRole = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                DertamButton(
                  onPressed: () {
                    if (isLoading) return;

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

                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    userProvider
                        .createAdminUser(
                      email: emailController.text,
                      password: passwordController.text,
                      displayName: displayNameController.text,
                      role: selectedRole,
                    )
                        .then((_) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('User created successfully')),
                      );
                    }).catchError((e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to create user: ${e.toString()}')),
                      );
                    }).whenComplete(() {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                  text: isLoading ? 'Creating...' : 'Create',
                  buttonType: ButtonType.primary,
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.white,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                margin: EdgeInsets.all(DertamSpacings.m),
                padding: EdgeInsets.all(DertamSpacings.m),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(DertamSpacings.radius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Spacer(),
                    // // Search Bar
                    // Container(
                    //   width: 300,
                    //   height: 40,
                    //   padding: EdgeInsets.only(top: 5),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey[100],
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: TextField(
                    //     decoration: InputDecoration(
                    //       hintText: 'Search...',
                    //       prefixIcon: Icon(Icons.search),
                    //       border: InputBorder.none,
                    //       contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: DertamSpacings.m),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(DertamSpacings.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Users Table
                      Container(
                        padding: EdgeInsets.all(DertamSpacings.m),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(DertamSpacings.radius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Users',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showCreateUserDialog(context),
                                  icon: Icon(Icons.add),
                                  label: Text('Add New User'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: DertamColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: DertamSpacings.m),
                            UsersDataTable(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}