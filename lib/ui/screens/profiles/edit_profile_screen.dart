// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog_button.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProderUserInfo =
        Provider.of<AuthServiceProvider>(context, listen: false);
    _nameController.text = authProderUserInfo.currentUser?.displayName ?? '';
    _emailController.text = authProderUserInfo.currentUser?.email ?? '';
  }

  void _saveProfile() async {
    bool confirm = await _showConfirmationDialog();
    if (confirm) {
      Navigator.pop(context); // Close EditProfileScreen
    }
  }

  //to show the confirmation dialog when the user tries to save the changes
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return DertamDialog(
              title: 'Confirm Save',
              content: 'Are you sure you want to save the changes?',
              actions: [
                DertamDialogButton(
                  onPressed: () => Navigator.pop(context, false),
                  text: 'Cancel',
                  dertamColor: DertamColors.red,
                ),
                DertamDialogButton(
                  onPressed: () => Navigator.pop(context, true),
                  text: 'Save',
                  dertamColor: DertamColors.primary,
                  hasBackground: true,
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // Access the auth provider
    return Consumer<AuthServiceProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: authProvider.currentUser?.photoUrl != null
                      ? NetworkImage(authProvider.currentUser!.photoUrl!)
                          as ImageProvider
                      : const AssetImage('lib/assets/images/avatar.jpg'),
                ),
                const SizedBox(height: 50),
                DertamTextfield(
                  label: 'Name',
                  controller: _nameController,
                  icon: Icons.person,
                ),
                DertamTextfield(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 80),
                SizedBox(
                  width: 200,
                  child: DertamButton(
                    onPressed: _saveProfile,
                    text: 'Save',
                    buttonType: ButtonType.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
