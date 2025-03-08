import 'package:flutter/material.dart';
import 'package:tourism_app/core/theme.dart';
import 'package:tourism_app/views/profile/widget/edit_profile_image.dart';
import 'package:tourism_app/views/widgets/dertam_button.dart';
import 'package:tourism_app/views/widgets/dertam_dialog.dart';
import 'package:tourism_app/views/widgets/dertam_dialog_botton.dart';
import 'package:tourism_app/views/widgets/dertam_textfield.dart';



class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Kannika KAK');
  final TextEditingController _phoneController = TextEditingController(text: '+855 1234569');
  final TextEditingController _emailController = TextEditingController(text: 'kannika@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');
  
  bool _obscurePassword = true;

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
  ) ?? false;
}

  //to show the dialog to change the profile picture when the user taps on the profile picture in the EditProfileScreen such that the user can choose to take a photo or choose from the gallery
 void _changeProfilePicture() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return DertamDialog(
        title: 'Change Profile Picture',
        centerTitle: true,
        contentWidgets: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.image, color: Colors.green),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(context),
          ),
        ],
        actions: [
          DertamDialogButton(
            onPressed: () => Navigator.pop(context),
            text: 'Cancel',
            dertamColor: DertamColors.red,
          ),
        ],
      );
    },
  );
}
 
 @override
  Widget build(BuildContext context) {
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
            EditProfileImage(
              imagePath: 'lib/assets/images/profile.png',
              onEdit: _changeProfilePicture,
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
            DertamTextfield(
              label: 'Password',
              controller: _passwordController,
              icon: Icons.lock,
              isPassword: true,
              obscureText: _obscurePassword,
              onVisibilityToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
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
  }
}
