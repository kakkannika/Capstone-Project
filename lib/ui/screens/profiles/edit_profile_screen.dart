// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog_button.dart';
import 'package:tourism_app/ui/widgets/dertam_dialog.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/widgets/dertam_textfield.dart';
import 'package:tourism_app/ui/widgets/dertam_button.dart';
import 'package:tourism_app/utils/profile_cache.dart';
import 'package:tourism_app/models/user/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadLocalProfileImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  // Load user data from the Provider after dependencies are initialized
  void _loadUserData() {
    final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null) {
      setState(() {
        _nameController.text = currentUser.displayName ?? '';
        _emailController.text = currentUser.email;
        _currentPhotoUrl = currentUser.photoUrl;
      });
    }
  }

  // Try to load locally cached profile image
  Future<void> _loadLocalProfileImage() async {
    try {
      final localImage = await ProfileCache.getProfileImage();
      if (localImage != null && mounted) {
        setState(() {
          _selectedImage = localImage;
        });
      }
    } catch (e) {
      print('Error loading cached profile image: $e');
    }
  }

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );
      
      if (pickedImage != null && mounted) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  // Method for capturing photo directly from the camera
  Future<void> _takeCameraPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        setState(() {
          _selectedImage = File(photo.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error taking photo: $e');
    }
  }

  // Show options to choose image source
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(context);
                _takeCameraPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Save the profile
  void _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Name cannot be empty');
      return;
    }

    // Show confirmation dialog
    final bool confirm = await showDialog<bool>(
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

    if (!confirm || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth provider only when needed
      final authProvider = Provider.of<AuthServiceProvider>(context, listen: false);
      
      // Update the profile with name and image
      await authProvider.updateUserProfile(
        displayName: _nameController.text.trim(),
        profileImage: _selectedImage,
      );

      if (!mounted) return;
      
      _showSnackBar('Profile updated successfully');
      
      // Return success to previous screen
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error updating profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Updating profile...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: DertamColors.primary.withOpacity(0.5), width: 2),
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                              : (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: _currentPhotoUrl!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                      errorWidget: (context, url, error) => Image.asset(
                                        'assets/images/avatar.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/avatar.jpg',
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: DertamColors.primary, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          onPressed: _showImageSourceOptions,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
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
                    enabled: false,
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
