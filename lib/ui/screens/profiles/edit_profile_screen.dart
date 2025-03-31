// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog_button.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _selectedImage; // To store the selected image file

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProderUserInfo =
        Provider.of<AuthServiceProvider>(context, listen: false);

    _nameController.text = authProderUserInfo.currentUser?.displayName ?? '';
    _emailController.text = authProderUserInfo.currentUser?.email ?? '';
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      throw ('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    final authProvider =
        Provider.of<AuthServiceProvider>(context, listen: false);

    try {
      // Show a loading indicator while updating
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await authProvider.uploadProfilePhoto(_selectedImage!);
      }
      // Update the user's profile
      await authProvider.updateUserProfile(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: photoUrl, // Pass the new photo URL if available
      );

      // Close the loading indicator
      Navigator.pop(context);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Close the EditProfileScreen
      Navigator.pop(context);
    } catch (error) {
      // Close the loading indicator
      Navigator.pop(context);

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
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
            title: Text(
              'Edit Profile',
              style: TextStyle(
                  color: DertamColors.primary, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: DertamColors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage, // Open the image picker when tapped
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : (authProvider.currentUser?.photoUrl != null
                            ? NetworkImage(authProvider.currentUser!.photoUrl!)
                            : const AssetImage('lib/assets/images/avatar.jpg')),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.camera_alt,
                          color: DertamColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
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
